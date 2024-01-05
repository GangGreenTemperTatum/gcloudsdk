#!/bin/bash
# Define the path to the text lists
project_list="./project.txt"
projects_with_compute_list="./projects_with_compute.txt"

echo -e "Enumerate all GCP projects...\n"
# Execute the gcloud command to list projects and store the output in the project list
gcloud projects list --format="value(projectId)" --sort-by=projectId > "$project_list"

# Check if the project list exists
if [ ! -f "$project_list" ]; then
  echo "Project list not found: $project_list"
  exit 1
fi

echo -e "Starting the first phase of the script... This will loop through all GCP projects and check if the Compute API engine is enabled. Successful matches will print to stdout and projects_with_compute.txt, unsuccessful matches will be ignored. Ensure GCP permissions are set correctly to allow the gcloud commands work for script to run.\n"

# Loop through each project in the project list
while read -r project; do
  # Run the gcloud services list command for the current project
  gcloud services list --enabled --project="$project" | grep "compute.googleapis.com" 2>/dev/null
  if [ $? -eq 0 ]; then
    echo "$project" >> "$compute_project"
    echo "Adding $project to $projects_with_compute_list as it has 'compute.googleapis.com' enabled"
  fi
done < "$project_list"

# Add an echo statement before the second loop
echo -e "Starting the second phase of the script and dumping external IPs.Successful matches will print to stdout and get_ips_against_project_match.log, unsuccessful matches will print to stderr and no_ips_against_projects.log\n"

# Loop through each project in the projects_with_compute_list against the list of IP addresses
while read -r compute_project; do
  gcloud compute addresses list --project="$compute_project" 2>/dev/null)
  if [ $? -eq 0 ]; then
    echo "$output" >> cloud_project_ips.log
    echo "IPs found for $compute_project"
  else
    echo "No IPs found for $compute_project"
  fi
done < "$compute_project"

echo -e "Script completed...Now time to run some recon and footprinting\n" && ls -halt | grep 'ips'
