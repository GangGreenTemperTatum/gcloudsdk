#!/bin/bash

# Specify the output file
output_file="compute_instance_output.txt"

# Get a list of project names
project_names=$(gcloud projects list --format="value(projectId)")

# Iterate through each project
for project_name in $project_names
do
    echo "Project: $project_name"

    # Check if Compute Engine API is enabled for the project
    api_status=$(gcloud services list --project=$project_name --format="value(config.name)" | grep "compute.googleapis.com")

    if [ -n "$api_status" ]; then
        echo "  Compute Engine API is enabled."

        # Get a detailed list of compute instances for each project
        instance_list=$(gcloud compute instances list --project=$project_name --format="table[box,title=ComputeInstances](name,zone,machineType,status,INTERNAL_IP,EXTERNAL_IP)")

        # Check if there are any instances in the project
        if [ -n "$instance_list" ]; then
            echo -e "    Compute Instances:\n$instance_list"

            # Redirect the output to the specified file
            echo -e "\nProject: $project_name\nCompute Instances:\n$instance_list\n------------------------" >> "$output_file"
        else
            echo "    No compute instances found in this project."
        fi
    else
        echo "  Compute Engine API is not enabled for this project."
    fi

    echo "------------------------"
done

echo "Results also saved to $output_file"
