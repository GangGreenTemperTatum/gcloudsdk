#!/bin/bash

## Dependencies:
### gcloud sdk - https://cloud.google.com/sdk/docs/install-sdk
### jq - https://formulae.brew.sh/formula/jq

# This script is used to offboard an employee from GCP projects.
# Usage:
# chmod +x ./offboard_employee.sh && ./offboard_employee.sh

# Define the timestamp variable
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# Define the log file
LOG_FILE="${TIMESTAMP}-subdomain_enum-script.log"

# Redirect stdout and stderr to the log file and the terminal
exec > >(tee -a "$LOG_FILE") 2>&1

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
    echo -e "{RED}Error: $1 is not installed, check the script usage notes to proceed with installation" >&2
    exit 1
  fi
}

check_command_installed gcloud
check_command_installed jq

# enter the employee email in the terminal prompt
read -p "Enter the employee email to offboard: " EMPLOYEE_EMAIL
echo -e "${BOLD_YELLOW}$(date +"%Y-%m-%d %H:%M:%S"): Receieved input of ${BOLD_WHITE}$EMPLOYEE_EMAIL${RESET}${BOLD_YELLOW}.. please wait\n"
echo -e "${BOLD_YELLOW}$(date +"%Y-%m-%d %H:%M:%S"): Enumerating gcloud projects for user: ${BOLD_WHITE}$EMPLOYEE_EMAIL${RESET}${BOLD_YELLOW}.. please wait\n"

# print the project details and owners (optional)
# echo -e "${PURPLE}name|projectId|projectnumber|parentId|lifecycleState|owners"

# gather a list of projects under the organization
for project in $(gcloud projects list --format="value(projectId)" --sort-by=projectId)
do
  echo -e "${BOLD_YELLOW}Checking project: ${WHITE}$project${RESET}"
  
  # Get IAM policy and check if the user is an owner
  if gcloud projects get-iam-policy $project --flatten="bindings[].members" --format="json" | grep -q "\"user:$EMPLOYEE_EMAIL\""; then
    echo -e "${RED}Employee is a project owner of $project. Taking necessary actions..${RESET}"
    echo -e "${BOLD_RED}Added project details to list..${RESET}"
  else
    echo -e "${GREEN}Employee is not a project owner of $project. Enumerating next project in the list..${RESET}"
  fi
done

echo -e "\n${BOLD_YELLOW}Script execution completed. See the log file at ${WHITE}$LOG_FILE for more details${RESET}\n"