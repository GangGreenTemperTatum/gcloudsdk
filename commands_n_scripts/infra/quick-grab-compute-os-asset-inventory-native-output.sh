gcloud compute instances os-inventory list-instances --format="value(name,zone,project)" | 
grep "instance" | 
while read name zone; do \
   gcloud compute instances os-inventory describe $name --zone $zone --format="csv[no-heading,separator=' '](SystemInformation.Hostname, SystemInformation.ShortName, SystemInformation.LongName)" ; \
done
