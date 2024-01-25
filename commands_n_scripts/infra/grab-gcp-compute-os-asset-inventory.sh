#!/bin/bash

# Get project ID from user input
read -p "Enter your project ID: " project_id

# Get the list of VMs and store it in a file
gcloud compute instances os-inventory list-instances --project="$project_id" --format="value(NAME, ZONE)" > vms_list.txt

# Check if the file is not empty before proceeding
if [ -s vms_list.txt ]; then

    # Iterate through each VM and run the describe command
    while IFS= read -r vm_info; do
        # Parse VM name and zone from the line
        vm_name=$(echo "$vm_info" | awk '{print $1}')
        zone=$(echo "$vm_info" | awk '{print $2}')

        # Run the describe command for each VM with the --zone flag
        gcloud compute instances os-inventory describe "$vm_name" --project="$project_id" --zone="$zone" --format json | jq '.SystemInformation | { Hostname, ShortName, LongName }' | jq #2>&1 | tee vm_inventory_info.txt # && > "$vm_name"_info.txt

        # --format json | jq '.SystemInformation | { Hostname, ShortName, LongName }' -> Working jq with no CSV flatter format
        # --format json | jq '.SystemInformation | [ .Hostname, .ShortName, .LongName ] | @csv' -> Example with flatter csv format output
        # | jq -c '.SystemInformation | { Hostname, ShortName, LongName }' | grep "debian" | jq -r `
        #> "$vm_name"_info.txt

        # Extract and print the required values to stdout
        hostname=$(grep 'Hostname:' "$vm_name"_info.txt | awk '{print $2}')
        shortname=$(grep 'ShortName:' "$vm_name"_info.txt | awk '{print $2}')
        longname=$(grep 'LongName:' "$vm_name"_info.txt | awk '{$1=""; print $0}' | sed -e 's/^[ \t]*//')

        echo "VM: $vm_name"
        echo "Hostname: $hostname"
        echo "ShortName: $shortname"
        echo "LongName: $longname"
        echo "-----------------------------------------"

        # Save the values to a file
        echo "VM: $vm_name" >> values.txt
        echo "Hostname: $hostname" >> values.txt
        echo "ShortName: $shortname" >> values.txt
        echo "LongName: $longname" >> values.txt
        echo "-----------------------------------------" >> values.txt

    done < vms_list.txt

    echo "Script executed successfully. Results saved in values.txt."

else
    echo "No VMs found. Please check your project ID or make sure there are VMs in the project."
fi

# Clean up temporary files
rm vms_list.txt
