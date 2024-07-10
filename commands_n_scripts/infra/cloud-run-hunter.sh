#!/bin/bash

read -p "Enter the service hash (from Cloud Run URL): " SERVICE_HASH

PROJECTS=$(gcloud projects list --format="value(projectId)")

for PROJECT in $PROJECTS; do
    gcloud config set project $PROJECT >/dev/null 2>&1
    if gcloud services list --project=$PROJECT --enabled | grep -q "run.googleapis.com"; then
        gcloud run services list --platform=managed --format="value(metadata.name)" --filter="metadata.name:$SERVICE_HASH" --project=$PROJECT | grep -q $SERVICE_HASH && echo "Found in project $PROJECT"
    else
        echo "Run API not enabled for project $PROJECT"
    fi
done
