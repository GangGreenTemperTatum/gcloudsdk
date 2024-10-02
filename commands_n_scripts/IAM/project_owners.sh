#!/bin/bash

## Dependencies:
### gcloud sdk - https://cloud.google.com/sdk/docs/install-sdk
### jq - https://formulae.brew.sh/formula/jq

# This script is used to print gcloud project owners.
# Usage:
# chmod +x ./project_owners.sh && ./project_owners.sh

set -eo pipefail

BOLD_WHITE='\033[1;37m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BOLD_RED='\033[1;31m'
RED='\033[0;31m'
BOLD_YELLOW='\033[1;33m'
RESET='\033[0m' # No Color

function check_command_installed {
  if ! [ -x "$(command -v $1)" ]; then
    echo "-e ${RED}Error: $1 is not installed, check the script usage notes to proceed with installation" >&2
    exit 1
  fi
}

check_command_installed gcloud
check_command_installed jq

# Define the current TIMESTAMP variable
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# enter the employee email in the terminal prompt
echo -e "${BOLD_YELLOW}$(date +"%Y-%m-%d %H:%M:%S"): Enumerating gcloud projects.. please wait\n"
echo -e "${PURPLE}name|projectId|projectnumber|parentId|lifecycleState|owners"

# Initialize an empty array to store user emails
USER_EMAILS=()

# Initialize CSV file
CSV_FILE="gcloud_project_owners_${TIMESTAMP}.csv"
echo "name,projectId,projectNumber,parentId,lifecycleState,owners" > "$CSV_FILE"

# gather a list of projects under the organization
for project in $(gcloud projects list --format="value(projectId)" --sort-by=projectId)
do
    PROJECT_DETAILS=$(gcloud projects describe $project --format="value[separator='|'](name,projectId,projectNumber,parent.id,lifecycleState)")
    IAM_POLICY=$(gcloud projects get-iam-policy $project --format=json)

    # Check if bindings array is not null
    if [ "$(echo "$IAM_POLICY" | jq -r '.bindings')" == "null" ]; then
        echo -e "${RED}$project has no IAM bindings${RESET}"
        continue
    fi

    OWNERS=$(echo "$IAM_POLICY" | jq -r '.bindings[] | select(.role == "roles/owner") | .members[]' | tr '\n' ',')

    if [ -z "$OWNERS" ]; then
        echo -e "${RED}$project has no owners${RESET}"
        continue
    fi

    echo -e "${CYAN}$PROJECT_DETAILS|$OWNERS${RESET}"

    # Append project details to CSV file
    echo "$PROJECT_DETAILS|$OWNERS" | tr '|' ',' >> "$CSV_FILE"

    # Extract user emails and add them to the USER_EMAILS array
    echo -e "${BOLD_WHITE}Extracting user emails from projects.. please wait${RESET}"
    EMAILS=$(echo "$IAM_POLICY" | jq -r '.bindings[] | select(.role == "roles/owner") | .members[]' | grep '^user:')
    for email in $EMAILS; do
        USER_EMAILS+=("${email#user:}")
    done
done

# Remove duplicate emails
USER_EMAILS=($(echo "${USER_EMAILS[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

# Print the list of user emails
echo -e "${BOLD_WHITE}List of user emails:${RESET}"
for email in "${USER_EMAILS[@]}"; do
    echo -e "${GREEN}$email${RESET}"
done

echo -e "\n${BOLD_YELLOW}Script execution completed.${RESET}"
echo -e "${BOLD_WHITE}Project details have been saved to ${CSV_FILE}${RESET}"