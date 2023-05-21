#!/bin/bash

# Prompt for the GCP project ID
read -p "Enter your GCP project ID: " PROJECT_ID

# Prompt for the GKE cluster name
read -p "Enter your GKE cluster name: " CLUSTER_NAME

# Set the desired node count for scaling
DESIRED_NODE_COUNT_UP=1
DESIRED_NODE_COUNT_DOWN=0

# Scale up the cluster
scale_up() {
  echo "Scaling up the GKE cluster..."
  gcloud container clusters resize $CLUSTER_NAME --num-nodes=$DESIRED_NODE_COUNT_UP --project=$PROJECT_ID --region=us-central1
}

# Scale down the cluster
scale_down() {
  echo "Scaling down the GKE cluster..."
  gcloud container clusters resize $CLUSTER_NAME --num-nodes=$DESIRED_NODE_COUNT_DOWN --project=$PROJECT_ID --region=us-central1
}

# Check the argument to determine the action
if [ "$1" == "up" ]; then
  scale_up
elif [ "$1" == "down" ]; then
  scale_down
else
  echo "Usage: ./scale_cluster.sh [up|down]"
  exit 1
fi
