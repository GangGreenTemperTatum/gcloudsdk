file_path="./projects_with_compute.txt"

# Check if the file exists
if [ ! -f "$file_path" ]; then
    echo "File $file_path not found."
    exit 1
fi

# Iterate over each line in the file and execute the command
while IFS= read -r compute_project || [[ -n "$compute_project" ]]; do
    command="gcloud compute addresses list --global --project=\"$compute_project\""
    echo "Executing: $command"
    eval "$command"
done < "$file_path"
