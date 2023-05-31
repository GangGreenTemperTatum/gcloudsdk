# Run with:
## chmod +x ./list_roles_associated_with_account.sh
## ./list_roles_associated_with_account.sh <project-id> <principle>

[ $# -gt 1 ] || {
  echo "$0 [project] [service account]";
  exit 1;
}
[ $# -eq 3 ] && opts="$3" || opts=""
gcloud projects get-iam-policy $opts $1  \
--flatten="bindings[].members" \
--format='table(bindings.role)' \
--filter="bindings.members:$2"
