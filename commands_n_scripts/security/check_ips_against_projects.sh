#!/bin/bash

# [GangGreenTemperTatum](https://github.com/GangGreenTemperTatum)
# A shell blue-team focused script to identify any potential dangling IPs in a GCP organization by enumerating through a list of DNS records and checking if the IP is in use by any project in the organization.

# Define the path to the text files
project_file="project.txt"
ip_file="ip.txt"

# Execute a cat with ipv4-compatible grep to output a list of IPs and store the output in the IP file
cat ~/git/x/y/z/dns/record.tf | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" >> "./ip.txt"

# Execute the gcloud command to list projects and store the output in the project file
gcloud projects list --format="value(projectId)" --sort-by=projectId >> "./project.txt"

# Check if the project file exists
if [ ! -f "$project_file" ]; then
  echo "Project file not found: $project_file"
  exit 1
fi

if [ ! -f "$ip_file" ]; then
  echo "IP file not found: $ip_file"
  exit 1
fi

# Loop through each project in the project file
while read -r project; do
  # Loop through each IP in the IP file
  while read -r ip; do
    # Run the gcloud command with the current project and IP, responding with "N" to the gcloud prompt if the Compute API engine is not enabled
    output=$(gcloud compute addresses list --project="$project" | grep "$ip" 2>/dev/null)
    if [ -n "$output" ]; then
      echo "IP found - Project: $project, IP: $ip"#!/bin/bash

# Define the path to the text files
project_file="project.txt"
ip_file="ip.txt"

# Execute a cat with ipv4-compatible grep to output a list of IPs and store the output in the IP file
cat ~/git/infra/terraform/organization/cloudflare/dns/record.tf | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" >> "./ip.txt"

# Execute the gcloud command to list projects and store the output in the project file
gcloud projects list --format="value(projectId)" --sort-by=projectId >> "./project.txt"

# Check if the project file exists
if [ ! -f "$project_file" ]; then
  echo "Project file not found: $project_file"
  exit 1
fi

if [ ! -f "$ip_file" ]; then
  echo "IP file not found: $ip_file"
  exit 1
fi

# Loop through each project in the project file
while read -r project; do
  # Loop through each IP in the IP file
  while read -r ip; do
    # Run the gcloud command with the current project and IP, responding with "N" to the gcloud prompt if the Compute API engine is not enabled
    output=$(gcloud compute addresses list --project="$project" | grep "$ip" 2>/dev/null)
    if [ -n "$output" ]; then
      echo "IP found - Project: $project, IP: $ip"
    else
      echo "IP not found - Project: $project, IP: $ip" #>> "./ip_not_found.txt" 2>/dev/null
    fi
  done < "$ip_file"
done < "$project_file"

    else
      echo "IP not found - Project: $project, IP: $ip" #>> "./ip_not_found.txt" 2>/dev/null
    fi
  done < "$ip_file"
done < "$project_file"
