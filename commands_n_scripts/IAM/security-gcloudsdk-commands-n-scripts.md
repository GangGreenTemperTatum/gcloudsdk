# Security [`gcloudsdk`](https://cloud.google.com/sdk/) Commands and Scripts

## Additional Resources:

- TBC

# **CloudArmor WAF (Web Application Firewall)**:

- Gather and list all WAF Security Policies per the project in question:

`gcloud compute security-policies list --project=$PROJECT_ID`

- Get all WAF rules and advanced configuration per the WAF Security Policy:
- - Can `grep | X` for `logLevel` etc
- - Append `grep | advancedOptionsConfig -A 10 -B 2`

`gcloud compute security-policies describe <security-policy-name> --project=$PROJECT_ID`
