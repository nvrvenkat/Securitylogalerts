#!/bin/bash

# Define variables
DISPLAY_NAME="ACT-MS-alerts"
DESCRIPTION="Notification channel for ACT-MS alerts"
EMAIL_ADDRESS="venkatraman.nagarajan@ankercloud.com"

# Create the notification channel
gcloud beta monitoring channels create \
    --display-name="$DISPLAY_NAME" \
    --description="$DESCRIPTION" \
    --type=email \
    --channel-labels="email_address=$EMAIL_ADDRESS"

# Wait for a brief moment
sleep 7

# Create Deployment Manager deployment
gcloud deployment-manager deployments create logalert --config log_metric.yaml

# Wait for a brief moment
sleep 12

# Deleting Deployment Manager deployment
gcloud deployment-manager deployments delete logalert --delete-policy=ABANDON --quiet

