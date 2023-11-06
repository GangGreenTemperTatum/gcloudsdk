#!/bin/bash

echo -e "[GangGreenTemperTatum](https://github.com/GangGreenTemperTatum)\nA shell blue-team focused script to identify any potential dangling IPs in a GCP organization by enumerating through a list of DNS records and checking if the IP is in use by any project in the organization."

# Define the path to the text lists
project_list="./project.txt"
ip_list="./ip.txt"
projects_with_compute_list="./projects_with_compute.txt"

echo -e "cat the DNS record file and grep for IPs to output to ip.txt\n"
# Execute a cat with ipv4-compatible grep to output a list of IPs and store the output in the IP list
cat ~/git/x/y/z/dns/record.tf | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" >> "./ip.txt"

echo -e "Enumerate all GCP projects...\n"
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

echo -e "Starting the first phase of the script... This will loop through all GCP projects and check if the Compute API engine is enabled. Successful matches will print to stdout and projects_with_compute.txt, unsuccessful matches will be ignored. Ensure GCP permissions are set correctly to allow the gcloud commands work for script to run.\n"

# Loop through each project in the project list
while read -r project; do
  # Run the gcloud services list command for the current project
  gcloud services list --enabled --project="$project" | grep "compute.googleapis.com" 2>/dev/null
  if [ $? -eq 0 ]; then
    echo "$project" >> "$projects_with_compute_list"
    echo "Adding $project to $projects_with_compute_list as it has 'compute.googleapis.com' enabled"
  fi
done < "$project_list"

# Add an echo statement before the second loop
echo -e "Starting the second phase of the script... Successful matches will print to stdout and check_ips_against_project_match.log, unsuccessful matches will print to stderr and check_ips_against_projects_no_match.log\n"

# Loop through each project in the projects_with_compute_list against the list of IP addresses
while read -r project; do
  # Loop through each IP in the IP list
  while read -r ip; do
    # Run the gcloud command with the current project and IP, responding with "N" to the gcloud prompt if the Compute API engine is not enabled
    output=$(gcloud compute addresses list --project="$project" | grep "$ip" 2>/dev/null)
    if [ -n "$output" ]; then
      echo -e "IP found - Project: $project, IP: $ip\n" | tee -a check_ips_against_project_match.log
    else
      echo -e "IP not found - Project: $project, IP: $ip\n" 2>./error.log 1>./check_ips_against_projects_no_match.log
    fi
  done < "$ip_list"
done < "$projects_with_compute_list"
