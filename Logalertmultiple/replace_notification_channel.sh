#!/bin/bash

# Define the display names or IDs of the notification channels to be used
required_channels=(
    "ACT-MS-alerts"
    "personal mail"
)

# Initialize an empty array to store the channel IDs
channel_ids=()

# Fetch the notification channels for each required display name
for display_name in "${required_channels[@]}"
do
    # Run the gcloud command and store the output in a variable
    channel_id=$(gcloud beta monitoring channels list --format="value(name)" --filter="displayName=\"$display_name\"")

    # Check if the channel_id is not empty and add it to the array
    if [ -n "$channel_id" ]; then
        channel_ids+=("$channel_id")
    fi
done

# Check if we have exactly two channel IDs
if [ ${#channel_ids[@]} -ne 2 ]; then
    echo "Error: Exactly two notification channels must be found for the specified display names."
    exit 1
fi

# Extract the channel IDs
channel_id=${channel_ids[0]}
channel_id_1=${channel_ids[1]}

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
    # Replace the placeholders in each YAML file with the channel IDs
    sed -i "s|\$(cat output.txt)|$channel_id|g" "$file"
    sed -i "s|\$(cat output1.txt)|$channel_id_1|g" "$file"
    echo "Updated YAML file: $file"
done

echo "All YAML files updated with channel IDs: $channel_id and $channel_id_1"

