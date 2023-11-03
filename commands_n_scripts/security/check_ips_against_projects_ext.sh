#!/bin/bash

# [GangGreenTemperTatum](https://github.com/GangGreenTemperTatum)
# A shell blue-team focused script to identify any potential dangling IPs in a GCP organization by enumerating through a list of DNS records and checking if the IP is in use by any project in the organization.

# Define the path to the text lists
project_list="./project.txt"
ip_list="./ip.txt"
projects_with_compute_list="./projects_with_compute.txt"

# Execute a cat with ipv4-compatible grep to output a list of IPs and store the output in the IP list
cat ~/git/x/y/z/dns/record.tf | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" >> "./ip.txt"

# Execute the gcloud command to list projects and store the output in the project list
gcloud projects list --format="value(projectId)" --sort-by=projectId > "$project_list"

# Check if the project list exists
if [ ! -f "$project_list" ]; then
  echo "Project list not found: $project_list"
  exit 1
fi

if [ ! -f "$ip_list" ]; then
  echo "IP list not found: $ip_list"
  exit 1
fi

# Loop through each project in the project list
while read -r project_list; do
  # Run the gcloud services list command for the current project
  gcloud services list --enabled --project="$project" | grep "compute.googleapis.com" 2>/dev/null
  if [ $? -eq 0 ]; then
    echo "$project" >> "$projects_with_compute_list"
    echo "adding $project to $projects_with_compute_list as it has 'compute.googleapis.com' enabled"
  fi
done < "$project_list"

# Loop through each project in the project list
while read -r projects_with_compute_list; do
  # Loop through each IP in the IP list
  while read -r ip; do
    # Run the gcloud command with the current project and IP, responding with "N" to the gcloud prompt if the Compute API engine is not enabled
    output=$(gcloud compute addresses list --project="$project" | grep "$ip" 2>/dev/null)
    if [ -n "$output" ]; then
      echo "IP found - Project: $project, IP: $ip"
    else
      echo "IP not found - Project: $project, IP: $ip"
    fi
  done < "$ip_list"
done < "$project_list"
