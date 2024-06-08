#!/bin/bash

# Array of YAML files
yaml_files=(
  "AssignResourceToBillingAccount.yaml"
  "Delete_Service_account_key.yaml"
  "Firewall_Update.yaml"
  "Instance_Insert.yaml"
  "Set_IAM.yaml"
  "Create_Service_account_Key.yaml"
  "IAM_Action.yaml"
  "Label_modification.yaml"
  "delete_protection.yaml"
  "Disk_deletion.yaml"
  "Instance_Delete.yaml"
  "Service_Account_Creation.yaml"
  "Set_IAM.yaml"
)

# Iterate over each YAML file and create a deployment
for yaml_file in "${yaml_files[@]}"
do
  # Extract the deployment name from the YAML filename (without extension)
  deployment_name=$(echo "$yaml_file" | sed 's/.yaml$//' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g' | sed 's/^-*\|-*$//g')

  # Create deployment
  gcloud deployment-manager deployments create "$deployment_name" --config "$yaml_file"

  # Wait for a brief moment
  sleep 7

  # Delete deployment (with ABANDON policy) immediately after creation
  gcloud deployment-manager deployments delete "$deployment_name" --delete-policy=ABANDON --quiet
done

