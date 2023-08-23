#!/bin/bash

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
echo "Timestamp: $TIMESTAMP"

echo "name|projectId|projectnumber|parentId|lifecycleState|owners|billingEnabled|billingAccountName"

for project in $(gcloud projects list --format="value(projectId)" --sort-by=projectId --filter='Generate AppScript v001')
do
        PROJECT_DETAILS=$(gcloud projects describe $project --format="value[separator='|'](projectId,projectNumber,parent.id,lifecycleState)")
        OWNERS=$(gcloud projects get-iam-policy $project --flatten="bindings[].members[]" --format=json |jq -c '.[] | select(.bindings.role| . and contains("roles/owner")) | .bindings.members' | tr '\n' ',')
        BILLING_DETAILS=$(gcloud beta billing projects describe $project --format="value[separator='|'](billingEnabled,billingAccountName)")

        echo "$PROJECT_DETAILS|$OWNERS|$BILLING_DETAILS"
done

# % for i in `cat GenerateAppScriptIDs.txt`; do gcloud projects describe ${i}; done`
# % gcloud projects list --format="value(projectId)" --sort-by=projectId --filter='Generate AppScript v001' > GenerateAppScriptIDs.txt
# % for i in `cat GenerateAppScriptIDs.txt`; do gcloud projects delete ${i}; done`
# Follow-up
# for i in `cat GenerateAppScriptIDs.txt`; do gcloud projects describe ${i}; done | grep lifecycleState
