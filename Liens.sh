#!/bin/bash

# Fetch the current project
current_project=$(gcloud config get-value project)

# Check if current project is set
if [ -z "$current_project" ]; then
    echo "Error: Current project is not set. Please set a project using 'gcloud config set project PROJECT_ID'."
    exit 1
fi

echo "Current project: $current_project"

# List existing liens
existing_liens=$(gcloud alpha resource-manager liens list)

# Check if any liens exist
if [ -n "$existing_liens" ]; then
    echo "Existing liens:"
    echo "$existing_liens"
    exit 0  # Exit successfully as liens are already enabled
fi

# No liens found, enabling liens
echo "No existing liens found, enabling liens..."
gcloud alpha resource-manager liens create \
  --project="$current_project" \
  --restrictions=resourcemanager.projects.delete \
  --reason="This project is protected by a lien" \
  --origin=Deletion_protection

