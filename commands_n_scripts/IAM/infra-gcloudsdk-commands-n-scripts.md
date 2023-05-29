# Infrastructure [`gcloudsdk`](https://cloud.google.com/sdk/) Commands and Scripts

## Additional Resources:

- TBC

## **VM (Virtual Machines)**:

- Print the Virtual Machine(s) infrastructure within your repository
- - Use the available "Displayed Columns" from the GCP UI to determine column names
- - A good way to check for "open SSH" and obscure firewall rules assigned to `externalIp`

```
gcloud compute instances list --project=$PROJECT_ID --format="csv(name,status,kind,externalIp,creationTimestamp,zone.basename(),machineType,scheduling.provisioningModel)"
```

- 

```
```

- 

```
```

## **IAM (Identity Access Management)**

- To use this in automated tasks you'd like convert that table() format to a `yaml` or `json` or csv etc.

- List all buckets in `$PROJECT_ID` and their versioning status:

```
gcloud storage buckets list --format="table(name,versioning)" --project=$PROJECT_ID
```

- List buckets that have versions:

```
gcloud storage buckets list --format="table(name,versioning)" --project=$PROJECT_ID --filter="versioning.enabled=true"
```

- List buckets that have lifecycle policies and are versioned

```
gcloud storage buckets list --format="table(name,versioning,lifecycle.rule[])" --project=$PROJECT_ID --filter="versioning.enabled=true"
```

- 

```
```

- 

```
```

- 

```
```


- 

```
```

- 

```
```

- 

```
```
