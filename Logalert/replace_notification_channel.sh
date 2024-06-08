#!/bin/bash

# Run the gcloud command and store the output in output.txt
gcloud beta monitoring channels list --format="value(name)" > output.txt

# Read the content of output.txt
channel_id=$(cat output.txt)

# Array of YAML files
yaml_files=(
    "AssignResourceToBillingAccount.yaml"
    "Disk_deletion.yaml"
    "Instance_Insert.yaml"
    "Create_Service_account_Key.yaml"
    "Firewall_Update.yaml"
    "Label_modification.yaml"
    "delete_protection.yaml"
    "IAM_Action.yaml"
    "Delete_Service_account_key.yaml"
    "Instance_Delete.yaml"
    "Set_IAM.yaml"
    "Service_Account_Creation.yaml"
)

# Update each YAML file
for file in "${yaml_files[@]}"
do
    # Replace the placeholder in each YAML file with the channel ID
    sed -i "s|\$(cat output.txt)|$channel_id|g" "$file"
    echo "Updated YAML file: $file"
done

echo "All YAML files updated with channel ID: $channel_id"

