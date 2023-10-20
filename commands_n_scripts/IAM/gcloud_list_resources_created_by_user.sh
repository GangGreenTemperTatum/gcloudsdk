#!/bin/bash

# Specify the user's email address you want to search for
target_user_email="user@example.com"

# List all projects
projects=$(gcloud projects list --format="value(projectId)")

# Loop through each project
for project in $projects; do
  echo "Project: $project"
  
  # List resources created by the target user in the project
  resources=$(gcloud deployment-manager deployments list --project="$project" --format="value(name)")
  if [ -n "$resources" ]; then
    echo "Deployments:"
    echo "$resources"
  fi
  
  resources=$(gcloud compute instances list --project="$project" --format="value(name)")
  if [ -n "$resources" ]; then
    echo "VM Instances:"
    echo "$resources"
  fi
  
  # You can add more resource types and commands as needed
  
  # Insert additional resource checks here for other resource types
  
  echo
done
