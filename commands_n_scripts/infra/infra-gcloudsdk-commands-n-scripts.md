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

- The gcloud compute instances list command has the EXTERNAL_IP  field as some sort of internal shorthand for a deeper field in the yaml structure.
- - To get the list of all potential deeper fields to `--filter` or `--format`, you can do something like this on a particular instance:

`gcloud --format=flattened compute instances list --project=$PROJECT_ID --filter="name=instance-1"`

- But the "shortcut" `EXTERNAL_IP` field, cannot be "excepted" as seen it as a direct result for the `gcloud compute instances list` command... but you can filter on it, so, like:

`gcloud compute instances list --project=$PROJECT_ID --filter="EXTERNAL_IP:*" --format="csv[no-heading](name,status,kind,EXTERNAL_IP,creationTimestamp,zone.basename(),machineType,scheduling.provisioningModel)"`

- You can also use the deeper field `networkInterfaces[0].accessConfigs[0].natIP`, for example:

`gcloud compute instances list --project=$PROJECT_ID --filter="networkInterfaces.accessConfigs.type=ONE_TO_ONE_NAT" --format="csv[no-heading](name,status,kind,networkInterfaces[0].accessConfigs[0].natIP,creationTimestamp,zone.basename(),machineType,scheduling.provisioningModel)"`

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
