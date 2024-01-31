`$ gcloud projects list --format="value(projectId)" --sort-by=projectId > project.txt`

## Grab a list of roles, per-project that a service account has available:

`gcloud projects get-iam-policy <project> --format=json | jq '.bindings[] | select(.members[] | contains("serviceAccount:<SA>")) | .role'`
