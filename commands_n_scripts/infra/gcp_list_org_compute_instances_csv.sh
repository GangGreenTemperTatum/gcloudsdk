#!/bin/bash

# Specify the output file
output_file="compute_instance_output.csv"

# Get a list of project names
project_names=$(gcloud projects list --format="value(projectId)")

# Print CSV header to stdout
echo "Project,Instance,Zone,MachineType,Status,InternalIP,ExternalIP"

# Iterate through each project
for project_name in $project_names
do
    # Check if Compute Engine API is enabled for the project
    api_status=$(gcloud services list --project=$project_name --format="value(config.name)" | grep "compute.googleapis.com")

    if [ -n "$api_status" ]; then
        # Get a detailed list of compute instances for each project in CSV format
        gcloud compute instances list --project=$project_name --format="csv[no-heading](project,name,zone,machineType,status,INTERNAL_IP,EXTERNAL_IP)" | \
        while IFS=, read -r project instance zone machine_type status internal_ip external_ip
        do
            # Print the CSV data to stdout
            # Print $project_name var as in gcloud compute list, the project is not natively printed
            echo "$project_name,$instance,$zone,$machine_type,$status,$internal_ip,$external_ip"
        done
    fi
done > "$output_file"

echo "Results also saved to $output_file"
