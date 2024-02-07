#!/bin/bash -e
#
# Initiallize Terraform directories and files for a new project
#
repo_root="$(git rev-parse --show-toplevel)"
seed_project_path="terraform/projects/seed-project"

[ -d "${repo_root}/${seed_project_path}" ] || {
  echo "Can't find the seed-project dir!"
  exit 101
}

[ $# -eq 2 ] && {
  provider_path=$2
} || {
  echo "Usage: $0 [project-name-no-spaces] [aws or gcp]"
  exit 103
}
[ -d "${repo_root}/${seed_project_path}/${provider_path}" ] || {
  echo "Can't find the provider path: ${repo_root}/${seed_project_path}/${provider_path}"
  exit 102
}

project_name=${1//_/-}
project_seed_dir="${repo_root}/${seed_project_path}/${provider_path}/modules/${project_name}"
project_dir="${repo_root}/terraform/projects/${provider_path}/${project_name}"

mkdir -p "${project_dir}"

[ -d "${project_seed_dir}" ] && {
  echo "${project_seed_dir} already exists. Skilling creating ${project_seed_dir}"
} || cp -a "${repo_root}"/${seed_project_path}/${provider_path}/modules/PROJECT_NAME "${project_seed_dir}"

grep -rlI "PROJECT-NAME" "${project_seed_dir}" | xargs -I{} sed -i '' 's/PROJECT-NAME/'$project_name'/g' "{}"
grep -rlI "PROJECT_NAME" "${project_seed_dir}" | xargs -I{} sed -i '' 's/PROJECT_NAME/'${project_name//-/_}'/g' "{}"

grep -rlI "${project_name}" "${repo_root}"/${seed_project_path}/${provider_path}/main.tf && {
  echo "${project_name} seems to already exist in ${repo_root}/${seed_project_path}/main.tf"
  echo "Skipping adding the ${project_name} module sourcing the new project."
} || cat <<EOT >>"${repo_root}"/${seed_project_path}/${provider_path}/main.tf
module "${project_name//-/_}" {
  source = "./modules/${project_name}"
}

EOT

echo "Creating the project var file $project_dir/.project_vars..."
cat <<EOF >>$project_dir/.project_vars
workload_identity_provider=
service_account=
project=${project_name}
EOF

echo "Creating the TF backend config..."
cat <<EOF >>$project_dir/backend.tf
terraform {
  backend "gcs" {
    bucket = "terraform_state_common"
    prefix = "${project_name//-/_}/tfstate"
  }
}
EOF

echo "Creating TF versions files..."
TERRAFORM_VERSION="$(<"${repo_root}/.terraform-version")"
cat <<EOF >>$project_dir/versions.tf
terraform {
  required_version = "${TERRAFORM_VERSION}"
  required_providers {
  }
}
EOF

cat <<EOF >>$project_dir/.terraform.lock.hcl
# This file is maintained automatically by "terraform init".
# Manual edits may be lost in future updates.
EOF
