#!/bin/bash

# Function to search for a bucket across all projects using gcloud
search_bucket() {
    echo "Enter the bucket name to search:"
    read bucket_name

    # Search for the bucket across all projects
    projects=$(gcloud projects list --format="value(projectId)")

    if [ -n "$projects" ]; then
        echo "Searching for bucket '$bucket_name' in projects:"

        found=false

        for project in $projects; do
            result=$(gsutil ls -p "$project" 2>/dev/null | grep -q "$bucket_name" && echo "Found in project $project" && found=true)
            if [ -n "$result" ]; then
                echo "$result"
            else
                echo "Bucket '$bucket_name' not found in project $project"
            fi
        done

        if [ "$found" = false ]; then
            echo "Bucket '$bucket_name' not found in any projects."
        fi
    else
        echo "No projects found."
    fi
}

# Main script execution
echo "Choose an option:"
echo "1. Search for a bucket across all projects"
echo "2. Exit"
read option

case $option in
    1)
        search_bucket
        ;;
    2)
        echo "Exiting script."
        ;;
    *)
        echo "Invalid option. Exiting script."
        ;;
esac
