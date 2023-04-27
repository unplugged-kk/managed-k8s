#!/bin/bash
set -x

function usage() {
    echo "Usage: $0 <project_id>"
    echo "Example: $0 my-gcp-project"
    exit 1
}

if [[ $# -ne 1 ]]; then
    usage
fi

# Get the project ID from the argument
PROJECT_ID="$1"

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null
then
    echo "Error: gcloud is not installed. Please install gcloud and try again."
    exit
fi

# Enable the required APIs
gcloud services enable \
  compute.googleapis.com \
  container.googleapis.com \
  containerregistry.googleapis.com \
  cloudbuild.googleapis.com \
  dns.googleapis.com \
  logging.googleapis.com \
  monitoring.googleapis.com \
  storage-api.googleapis.com \
  storage-component.googleapis.com \
  --project="$PROJECT_ID"

# Set the VPC name and IP range
VPC_NAME="kishore-kube-vpc"
IP_RANGE="10.0.0.0/16"

# Create the VPC network
gcloud compute networks create "$VPC_NAME" --project="$PROJECT_ID" --subnet-mode=custom

# Create 3 subnets in the VPC with different IP ranges
gcloud compute networks subnets create "$VPC_NAME-subnet-1" --project="$PROJECT_ID" --network="$VPC_NAME" --range="10.0.1.0/24" --region=us-central1
gcloud compute networks subnets create "$VPC_NAME-subnet-2" --project="$PROJECT_ID" --network="$VPC_NAME" --range="10.0.2.0/24" --region=us-central1
gcloud compute networks subnets create "$VPC_NAME-subnet-3" --project="$PROJECT_ID" --network="$VPC_NAME" --range="10.0.3.0/24" --region=us-central1

# Create firewall rules to allow internal traffic and SSH access
gcloud compute firewall-rules create allow-internal --network="$VPC_NAME" --allow=ALL --source-ranges="$IP_RANGE"
gcloud compute firewall-rules create allow-ssh --network="$VPC_NAME" --allow=tcp:22 --source-ranges="$IP_RANGE"


# Enable Private Google Access for the subnets
gcloud compute networks subnets update "$VPC_NAME-subnet-1" --project="$PROJECT_ID" --region=us-central1 --enable-private-ip-google-access
gcloud compute networks subnets update "$VPC_NAME-subnet-2" --project="$PROJECT_ID" --region=us-central1 --enable-private-ip-google-access
gcloud compute networks subnets update "$VPC_NAME-subnet-3" --project="$PROJECT_ID" --region=us-central1 --enable-private-ip-google-access

# Cloud NAT
gcloud compute routers create nat-router --project="$PROJECT_ID" --network="$VPC_NAME" --region=us-central1
gcloud compute routers nats create nat-config --router=nat-router --project="$PROJECT_ID" --auto-allocate-nat-external-ips --nat-all-subnet-ip-ranges --region=us-central1

# Print the VPC details
echo "VPC created:"
gcloud compute networks describe $VPC_NAME --project=$PROJECT_ID
