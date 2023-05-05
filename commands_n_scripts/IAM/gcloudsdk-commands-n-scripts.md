# IAM [`gcloudsdk`](https://cloud.google.com/sdk/) Commands and Scripts

## Additional Resources:

- [GCP: List members of all groups in an organization using gcloud CLI, output to BigQuery](https://stackoverflow.com/questions/68761353/gcp-list-members-of-all-groups-in-an-organization-using-gcloud-cli-output-to-b)
- [gcloud beta iam](https://cloud.google.com/sdk/gcloud/reference/beta/iam)

* From the gcloud command line, here's how to get a group/member list from bash: (substitute your org ID:)

- List the org:

`gcloud organizations list`

- List all group ID's per-org:

`gcloud identity groups search --organization=<ORG-ID> --labels="cloudidentity.googleapis.com/groups.discussion_forum" --format "value[delimiter='\\n'](groups.groupKey.id)"`

- List members in a group

`gcloud identity groups memberships list --group-email=$groupid --format "value(preferredMemberKey.id)"`

- List members in a group (static ID)

`gcloud identity groups memberships list --group-email=<group@comany.org>`

`gcloud identity groups memberships list --group-email=<group@comany.org> --format "value(preferredMemberKey.id)"`

- List owners in a group (static ID)

`gcloud identity groups memberships list --group-email=<group@comany.org>`

`gcloud identity groups memberships list --group-email=<group@comany.org> --format "value(preferredMemberKey.id)" --filter='OWNER'`

- Iterate all organization groups, then print those groups including printing the member ID's:

`gcloud identity groups search --organization=<ORG-ID> --labels="cloudidentity.googleapis.com/groups.discussion_forum" --format "value[delimiter='\\n'](groups.groupKey.id)" | while read groupid; do echo "GROUP: $groupid"; gcloud identity groups memberships list --group-email=$groupid --format "value(preferredMemberKey.id)" | ts " "; done`

- Iterate all organization groups, then print those groups including printing the member ID's for OWNERS only:

`gcloud identity groups search --organization=<ORG-ID> --labels="cloudidentity.googleapis.com/groups.discussion_forum" --format "value[delimiter='\\n'](groups.groupKey.id)" | while read groupid; do echo "GROUP: $groupid"; gcloud identity groups memberships list --group-email=$groupid --format "value(preferredMemberKey.id)" --filter='OWNER' | ts " "; done`

- List IAM principles per-org that have the role of owner

`gcloud organizations get-iam-policy <org-ID> --flatten=bindings --filter='bindings.role~owner AND bindings.members~group'`

- List IAM principles per-project that have the role of owner
  - Those are just regex filters looking to any role with owner in it and any member that has group as the prefix which all actual groups will have

`gcloud projects get-iam-policy <project-id> --flatten=bindings --filter='bindings.role~owner AND bindings.members~group'`

- List permissions assigned to IAM role

`gcloud iam roles describe roles/<role>`
