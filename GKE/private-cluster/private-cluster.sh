#!/bin/bash

# Prompt for the project ID
echo -n "Enter Sandbox Project ID: "
read PROJECT_ID

# Prompt for custom VPC
echo -n "Enter custom VPC name (leave empty for default): "
read CUSTOM_VPC

# Set the cluster name, version, machine type, disk size, number of nodes, and region
CLUSTER_NAME="kishore-k8-private-cluster"
CLUSTER_VERSION="1.25.7-gke.1000"
MACHINE_TYPE="e2-small"
DISK_SIZE="20"
NUM_NODES="1"
GKE_REGION="us-central1"
MAX_PODS="110"

# Use default VPC and subnetwork if custom values are not provided
if [ -z "$CUSTOM_VPC" ]; then
  CUSTOM_VPC="default"
  CUSTOM_SUBNET="default"
else
  CUSTOM_SUBNET="${CUSTOM_VPC}-subnet-1"
fi

# Enable the required APIs
gcloud services enable \
  compute.googleapis.com \
  container.googleapis.com \
  containerregistry.googleapis.com \
  cloudbuild.googleapis.com \
  file.googleapis.com \
  --project=$PROJECT_ID

# Create the private GKE cluster with the given parameters
gcloud beta container --project $PROJECT_ID clusters create $CLUSTER_NAME \
  --region $GKE_REGION \
  --no-enable-basic-auth \
  --cluster-version $CLUSTER_VERSION \
  --release-channel "regular" \
  --machine-type $MACHINE_TYPE \
  --image-type "COS_CONTAINERD" \
  --disk-type "pd-balanced" \
  --disk-size $DISK_SIZE \
  --metadata disable-legacy-endpoints=true \
  --scopes "https://www.googleapis.com/auth/cloud-platform" \
  --max-pods-per-node $MAX_PODS \
  --num-nodes $NUM_NODES \
  --logging=SYSTEM,WORKLOAD \
  --monitoring=SYSTEM \
  --enable-private-nodes \
  --master-ipv4-cidr "172.16.0.0/28" \
  --enable-master-global-access \
  --enable-ip-alias \
  --network "projects/$PROJECT_ID/global/networks/$CUSTOM_VPC" \
  --subnetwork "projects/$PROJECT_ID/regions/$GKE_REGION/subnetworks/$CUSTOM_SUBNET" \
  --no-enable-intra-node-visibility \
  --default-max-pods-per-node $MAX_PODS \
  --enable-dataplane-v2 \
  --no-enable-master-authorized-networks \
  --addons HorizontalPodAutoscaling,HttpLoadBalancing,NodeLocalDNS,GcePersistentDiskCsiDriver,BackupRestore,GcpFilestoreCsiDriver \
  --enable-autoupgrade \
  --enable-autorepair \
  --max-surge-upgrade 1 \
  --max-unavailable-upgrade 0 \
  --enable-vertical-pod-autoscaling \
  --workload-pool "$PROJECT_ID.svc.id.goog" \
  --enable-shielded-nodes \
  --enable-image-streaming

# Configure kubectl to use the new cluster
gcloud container clusters get-credentials $CLUSTER_NAME --region $GKE_REGION --project $PROJECT_ID

# Verify Kubernetes worker nodes
sleep 5 && kubectl get nodes

# Verify system pods in kube-system namespace
sleep 5 && kubectl -n kube-system get pods

# Verify kubeconfig file
cat $HOME/.kube/config
