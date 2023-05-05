#!/bin/bash

echo "name|projectId|projectnumber|parentId|lifecycleState|owners|billingEnabled|billingAccountName"

for project in $(gcloud projects list --format="value(projectId)" --sort-by=projectId)
do
        PROJECT_DETAILS=$(gcloud projects describe $project --format="value[separator='|'](name,projectId,projectNumber,parent.id,lifecycleState)")
        OWNERS=$(gcloud projects get-iam-policy $project --flatten="bindings[].members[]" --format=json |jq -c '.[] | select(.bindings.role| . and contains("roles/owner")) | .bindings.members' | tr '\n' ',')
        BILLING_DETAILS=$(gcloud beta billing projects describe $project --format="value[separator='|'](billingEnabled,billingAccountName)")

        echo "$PROJECT_DETAILS|$OWNERS|$BILLING_DETAILS"
done
