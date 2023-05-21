#!/bin/bash

set -x

echo -n "Enter Sandbox Project ID "
read PROJECT_ID

CLUSTER_NAME="kishore-cicd-cloudnative-cluster"
CLUSTER_VERSION="1.26.2-gke.1000"
MACHINE_TYPE="e2-small"
DISK_SIZE="20"
NUM_NODES="1"
GKE_REGION="us-central1"

# Setup Zone 

gcloud config set compute/region $GKE_REGION

# Enable Services

gcloud services enable container.googleapis.com storage.googleapis.com anthos.googleapis.com anthosgke.googleapis.com cloud.googleapis.com cloudresourcemanager.googleapis.com containerregistry.googleapis.com file.googleapis.com ; gcloud services list --enabled

# Create Testing Cluster

gcloud beta container --project $PROJECT_ID clusters create $CLUSTER_NAME --no-enable-basic-auth --cluster-version $CLUSTER_VERSION --release-channel "regular" --machine-type $MACHINE_TYPE --image-type "COS_CONTAINERD" --disk-type "pd-balanced" --disk-size $DISK_SIZE --metadata disable-legacy-endpoints=true --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" --num-nodes $NUM_NODES --logging=SYSTEM,WORKLOAD --monitoring=SYSTEM --enable-ip-alias --network "projects/$PROJECT_ID/global/networks/default" --subnetwork "projects/$PROJECT_ID/regions/$GKE_REGION/subnetworks/default" --no-enable-intra-node-visibility --default-max-pods-per-node "110" --enable-dataplane-v2 --no-enable-master-authorized-networks --addons HorizontalPodAutoscaling,HttpLoadBalancing,GcePersistentDiskCsiDriver --enable-autoupgrade --enable-autorepair --max-surge-upgrade 1 --max-unavailable-upgrade 0 --workload-pool "$PROJECT_ID.svc.id.goog" --enable-shielded-nodes --node-locations "$GKE_REGION-a","$GKE_REGION-b","$GKE_REGION-c"

# Configure kubeconfig for kubectl

gcloud container clusters get-credentials $CLUSTER_NAME --region $GKE_REGION --project $PROJECT_ID

# Verify Kubernetes Worker Nodes
sleep 5 && kubectl get nodes

# Verify System Pod in kube-system Namespace
sleep 5 && kubectl -n kube-system get pods

# Verify kubeconfig file
cat $HOME/.kube/config
