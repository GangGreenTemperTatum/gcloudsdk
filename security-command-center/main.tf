locals {
  pubsub_topic          = "scc_notifications"
  project               = "X"
  zipped_cloud_function = "/tmp/scc_cloud_function.zip"
  uploaded_archive_name = "scc_notifications_to_slack.py.zip"
  bucket                = "x_cloud_functions"
  service_account       = "svc-prod-scc-function-invoker"
}

// Get Terraform Encryption Key
data "google_kms_key_ring" "cicd" {
  name     = "cicd"
  location = "global"
  project  = "X"
}

data "google_kms_crypto_key" "terraform" {
  name     = "terraform"
  key_ring = data.google_kms_key_ring.cicd.id
}

data "google_kms_crypto_key_version" "terraform" {
  crypto_key = data.google_kms_crypto_key.terraform.id
}


// Slack Token
data "google_kms_secret_asymmetric" "scc_notifications_slack_token" {
  crypto_key_version = data.google_kms_crypto_key_version.terraform.id
  crc32              = "34485812"
  ciphertext         = <<EOT
    X=
    EOT
  provider           = google-beta
}

resource "google_secret_manager_secret" "scc_notifications_slack_token" {
  secret_id = "scc-notifications-slack-token"
  project   = local.project
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "scc_notifications_slack_token" {
  secret      = google_secret_manager_secret.scc_notifications_slack_token.id
  secret_data = data.google_kms_secret_asymmetric.scc_notifications_slack_token.plaintext
}


// Service Account
resource "google_service_account" "service_account" {
  account_id   = local.service_account
  display_name = local.service_account
  project      = local.project
  description  = "Used to invoke SCC cloud function in ${local.project}"
}

resource "google_project_iam_member" "service_account_invoker" {
  role       = "roles/cloudfunctions.invoker"
  project    = local.project
  member     = "serviceAccount:${local.service_account}@${local.project}.iam.gserviceaccount.com"
  depends_on = [google_service_account.service_account]
}

resource "google_project_iam_member" "service_account_decrypter" {
  role       = "roles/cloudkms.cryptoKeyDecrypter"
  project    = "x"
  member     = "serviceAccount:${local.service_account}@${local.project}.iam.gserviceaccount.com"
  depends_on = [google_service_account.service_account]
}

resource "google_project_iam_member" "service_account_secret_accessor" {
  role       = "roles/secretmanager.secretAccessor"
  project    = "X-cd"
  member     = "serviceAccount:${local.service_account}@${local.project}.iam.gserviceaccount.com"
  depends_on = [google_service_account.service_account]
}

resource "google_project_iam_member" "service_account_kms_viewer" {
  role       = "roles/cloudkms.viewer"
  project    = "X-cd"
  member     = "serviceAccount:${local.service_account}@${local.project}.iam.gserviceaccount.com"
  depends_on = [google_service_account.service_account]
}

resource "google_service_account_iam_member" "cf_sa_mixer" {
  service_account_id = google_service_account.service_account.id
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:svc-terraform-infra-scc@X-cd.iam.gserviceaccount.com"
  depends_on         = [google_service_account.service_account]
}

// PubSub
resource "google_pubsub_topic" "scc_notification" {
  name    = local.pubsub_topic
  project = local.project
}

// Cloud Function
data "archive_file" "notification_cloud_function" {
  type             = "zip"
  source_dir       = "${path.module}/cloud_function/"
  output_file_mode = "0666"
  output_path      = local.zipped_cloud_function
}

resource "google_storage_bucket_object" "archive" {
  name   = "scc_notifications/${data.archive_file.notification_cloud_function.output_md5}/${local.uploaded_archive_name}"
  bucket = local.bucket
  source = local.zipped_cloud_function
}

resource "google_cloudfunctions_function" "notification_function" {
  name        = "scc_notifications"
  description = "Sends SCC notifications from a PubSub to Slack"
  runtime     = "python39"
  project     = local.project
  region      = "us-central1"

  available_memory_mb   = 128
  ingress_settings      = "ALLOW_INTERNAL_ONLY"
  source_archive_bucket = local.bucket
  source_archive_object = google_storage_bucket_object.archive.name
  service_account_email = "${local.service_account}@${local.project}.iam.gserviceaccount.com"
  event_trigger {
    event_type = "providers/cloud.pubsub/eventTypes/topic.publish"
    resource   = "projects/${local.project}/topics/${local.pubsub_topic}"
  }
  environment_variables = {
    SECRET_NAME = google_secret_manager_secret_version.scc_notifications_slack_token.id
  }

  timeout     = 60
  entry_point = "send_slack_chat_notification"
  depends_on = [
    google_service_account_iam_member.cf_sa_mixer,
    google_storage_bucket_object.archive
  ]
}

# IAM entry for a single user to invoke the function
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.notification_function.project
  region         = google_cloudfunctions_function.notification_function.region
  cloud_function = google_cloudfunctions_function.notification_function.name

  role   = "roles/cloudfunctions.invoker"
  member = "serviceAccount:${local.service_account}@${local.project}.iam.gserviceaccount.com"
}

// Notifications
resource "google_scc_notification_config" "scc_public_unspecified_notification" {
  config_id    = "scc_all_sev_notifications"
  organization = "<ID>"
  description  = "Unspecified severity notification!"
  pubsub_topic = google_pubsub_topic.scc_notification.id

  streaming_config {
    filter = "severity = \"CRITICAL\" OR severity = \"HIGH\" OR severity = \"MEDIUM\" OR severity = \"LOW\" OR severity = \"\" AND state = \"ACTIVE\" AND NOT mute = \"MUTED\""
  }
}
