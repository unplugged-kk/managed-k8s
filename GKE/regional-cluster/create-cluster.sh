#!/bin/bash

echo -n "Enter Sandbox Project ID "
read PROJECT_ID

# Setup Zone 

gcloud config set compute/region us-central1

# Enable Services

gcloud services enable container.googleapis.com storage.googleapis.com anthos.googleapis.com anthosgke.googleapis.com cloud.googleapis.com cloudresourcemanager.googleapis.com containerregistry.googleapis.com file.googleapis.com ; gcloud services list --enabled

# Create Testing Cluster

gcloud beta container --project $PROJECT_ID clusters create "kishore-public-cluster-1" --no-enable-basic-auth --cluster-version "1.25.7-gke.1000" --release-channel "regular" --machine-type "e2-small" --image-type "COS_CONTAINERD" --disk-type "pd-balanced" --disk-size "20" --metadata disable-legacy-endpoints=true --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" --num-nodes "1" --logging=SYSTEM,WORKLOAD --monitoring=SYSTEM --enable-ip-alias --network "projects/$PROJECT_ID/global/networks/default" --subnetwork "projects/$PROJECT_ID/regions/us-central1/subnetworks/default" --no-enable-intra-node-visibility --default-max-pods-per-node "110" --enable-dataplane-v2 --no-enable-master-authorized-networks --addons HorizontalPodAutoscaling,HttpLoadBalancing,GcePersistentDiskCsiDriver --enable-autoupgrade --enable-autorepair --max-surge-upgrade 1 --max-unavailable-upgrade 0 --workload-pool "$PROJECT_ID.svc.id.goog" --enable-shielded-nodes --node-locations "us-central1-a","us-central1-b","us-central1-c"
