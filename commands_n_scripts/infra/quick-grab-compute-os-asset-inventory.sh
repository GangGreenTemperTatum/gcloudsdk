gcloud compute instances os-inventory list-instances --format="value(name,zone)" | 
grep "instance" | 
while read name zone; do \
   gcloud compute instances os-inventory describe $name --zone $zone --format json | jq '.SystemInformation | { Hostname, ShortName, LongName }' ; \
done
