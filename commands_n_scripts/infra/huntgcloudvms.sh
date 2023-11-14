#!/bin/bash

# Iterate through all GCP projects
for project_id in $(gcloud projects list --format="value(projectId)"); do

    # Check if Compute Engine API is enabled for the project
    api_status=$(gcloud services list --project=$project_id --format="value(NAME)" | grep "compute.googleapis.com")

    if [ -n "$api_status" ]; then
        # List compute VM in the project and grep for the name "my-vm"
        echo "Project: $project_id"
        gcloud compute instances list --project=$project_id --format="json(name)" | jq -r '.[]' | grep -i "my-vm"
    else
        echo "Compute Engine API is not enabled for project: $project_id"
    fi

done
