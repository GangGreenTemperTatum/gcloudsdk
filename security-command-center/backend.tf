terraform {
  backend "gcs" {
    bucket = "X_terraform_state_common"
    prefix = "X_security_command_center/tfstate"
  }
}
