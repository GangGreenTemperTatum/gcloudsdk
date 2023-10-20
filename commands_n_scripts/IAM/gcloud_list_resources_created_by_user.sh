#!/bin/bash

# Set the user's email address you want to search for
target_user_email="user@example.com"

# Set the project ID
project_id="your-project-id"

# Set the resource type (e.g., "gce_instance" for Compute Engine VM instances)
resource_type="gce_instance"

# Fetch Cloud Audit Logs for the specified project
logs=$(gcloud logging read "protoPayload.authenticationInfo.principalEmail=${target_user_email} AND protoPayload.resourceName:${resource_type}" \
  --project="$project_id" \
  --format="value(protoPayload.serviceName, protoPayload.methodName, protoPayload.request, protoPayload.resourceName)")

# Loop through the log entries
while IFS= read -r log_entry; do
  echo "Resource Created by $target_user_email:"
  echo "$log_entry"
  echo
done <<< "$logs"
