#!/bin/bash

# Get project ID
PROJECT_ID=$(gcloud config get-value project)

# Check if project ID is retrieved successfully
if [ -z "$PROJECT_ID" ]; then
    echo "Error: Unable to retrieve project ID. Please make sure you are authenticated."
    exit 1
fi

# Define other variables
ZONE="asia-south1-a"
MACHINE_TYPE="e2-micro"
DISK_NAME="logtest"
IMAGE="projects/debian-cloud/global/images/debian-12-bookworm-v20240515"
DISK_TYPE="projects/${PROJECT_ID}/zones/${ZONE}/diskTypes/pd-balanced"
DISK_SIZE="10"
LABELS="goog-ec-src=vm_add-gcloud"

# Create instance
gcloud compute instances create $DISK_NAME \
    --project=$PROJECT_ID \
    --zone=$ZONE \
    --machine-type=$MACHINE_TYPE \
    --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default,no-address \
    --maintenance-policy=MIGRATE \
    --provisioning-model=STANDARD \
    --no-service-account \
    --no-scopes \
    --create-disk=auto-delete=yes,boot=yes,device-name=$DISK_NAME,image=$IMAGE,mode=rw,size=$DISK_SIZE,type=$DISK_TYPE \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --labels=$LABELS \
    --reservation-affinity=any \
    --deletion-protection

# Check if the instance creation was successful
if [ $? -eq 0 ]; then
    echo "Instance $DISK_NAME created successfully."
else
    echo "Error: Instance creation failed."
fi

# Wait for 12 seconds
sleep 12

# Create additional disk
gcloud compute disks create logtestad \
  --size=10GB \
  --type=pd-balanced \
  --zone=asia-south1-a \
  --project=$PROJECT_ID \
  --quiet

# Wait for 5 seconds
sleep 5

# Create firewall rule
gcloud compute firewall-rules create logtest \
    --network="default" \
    --priority=1000 \
    --direction="ingress" \
    --action="allow" \
    --rules="all" \
    --source-ranges="0.0.0.0/0" \
    --no-disabled \
    --no-enable-logging \
    --quiet

# Wait for 5 seconds
sleep 5

# Update instance
gcloud compute instances update logtest --no-deletion-protection --zone=asia-south1-a --quiet

# Wait for 5 seconds
sleep 5

# Update firewall rule
gcloud compute firewall-rules update logtest --rules=tcp:22 --quiet

# Wait for 5 seconds
sleep 5

# Add labels to instance
gcloud compute instances add-labels logtest --project=$PROJECT_ID --zone=asia-south1-a --labels=environment=test --quiet

gcloud compute firewall-rules delete logtest --quiet

# Wait for 5 seconds
sleep 5

# Delete additional disk
gcloud compute disks delete logtestad --zone=asia-south1-a --project=$PROJECT_ID --quiet

# Wait for 5 seconds
sleep 5

# Delete instance
gcloud compute instances delete logtest --zone=asia-south1-a --project=$PROJECT_ID --quiet


# Create the service account
gcloud iam service-accounts create logtest \
  --description="logtest" \
  --display-name="logtest"
  
# Sleep for 5 seconds
sleep 5

# Use the project value in the gcloud command to create a key for the service account
gcloud iam service-accounts keys create test \
    --iam-account=logtest@"$PROJECT_ID".iam.gserviceaccount.com

# Sleep for 5 seconds
sleep 10

# Use the project value in the gcloud command to list all keys for the service account
KEYS=$(gcloud iam service-accounts keys list --iam-account=logtest@"$PROJECT_ID".iam.gserviceaccount.com --format="value(name)")

# Loop through each key and delete it
for KEY in $KEYS; do
    gcloud iam service-accounts keys delete "$KEY" --iam-account=logtest@"$PROJECT_ID".iam.gserviceaccount.com --quiet
done

# Sleep for 5 seconds
sleep 10

# Delete the service account
gcloud iam service-accounts delete logtest@"$PROJECT_ID".iam.gserviceaccount.com --quiet
