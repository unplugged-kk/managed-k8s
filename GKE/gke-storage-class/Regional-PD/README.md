---
Title: GKE Persistent Disks - Use Regional PD
Description: Use Google Disks Regional PD for Kubernetes Workloads
---

## S0: Pre-requisites
1. Verify if GKE Cluster is created
2. Verify if kubeconfig for kubectl is configured in your local terminal
```t
# Configure Cluster
1. Use The scripts in private-cluster to provision a custom vpc and a K8S cluster
```
3. Feature: Compute Engine persistent disk CSI Driver
  - Verify the Feature **Compute Engine persistent disk CSI Driver** enabled in GKE Cluster. 
  - This is required for mounting the Google Compute Engine Persistent Disks to Kubernetes Workloads in GKE Cluster.


## S1: Introduction
- Use Regional Persistent Disks

## S2: List Kubernetes Storage Classes in GKE Cluster
```t
# List Storage Classes
kubectl get sc
```

## S3: storage-class.yaml
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: regionalpd-storageclass
provisioner: pd.csi.storage.gke.io
parameters:
  #type: pd-standard # Note: To use regional persistent disks of type pd-standard, set the PersistentVolumeClaim.storage attribute to 200Gi or higher. If you need a smaller persistent disk, use pd-ssd instead of pd-standard.
  type: pd-ssd 
  replication-type: regional-pd
volumeBindingMode: WaitForFirstConsumer
allowedTopologies:
- matchLabelExpressions:
  - key: topology.gke.io/zone
    values:
    - us-central1-c
    - us-central1-b

## Important Note - Regional PD 
# If using a regional cluster, you can leave allowedTopologies unspecified. If you do this, when you create a Pod that consumes a PersistentVolumeClaim which uses this StorageClass a regional persistent disk is provisioned with two zones. One zone is the same as the zone that the Pod is scheduled in. The other zone is randomly picked from the zones available to the cluster.
# When using a zonal cluster, allowedTopologies must be set.    

# STORAGE CLASS 
# 1. A StorageClass provides a way for administrators 
# to describe the "classes" of storage they offer.
# 2. Here we are offering GCP PD Storage for GKE Cluster
```

## S4: persistent-volume-claim.yaml
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pv-claim
spec: 
  accessModes:
    - ReadWriteOnce
  storageClassName: regionalpd-storageclass
  resources: 
    requests:
      storage: 4Gi
```

## S5: Other Kubernetes YAML Manifests
- No changes to other Kubernetes YAML Manifests
- They are same as previous section
- UserManagement-ConfigMap.yaml
- mysql-deployment.yaml
- mysql-clusterip-service.yaml
- UserMgmtWebApp-Deployment.yaml
- UserMgmtWebApp-LoadBalancer-Service.yaml


## S6: Deploy kube-manifests
```t
# Deploy Kubernetes Manifests
kubectl apply -f kube-manifests/

# List Storage Class
kubectl get sc

# List PVC
kubectl get pvc

# List PV
kubectl get pv

# List ConfigMaps
kubectl get configmap

# List Deployments
kubectl get deploy

# List Pods
kubectl get pods

# List Services
kubectl get svc

# Verify Pod Logs
kubectl get pods
kubectl logs -f <USERMGMT-POD-NAME>
kubectl logs -f usermgmt-webapp-6ff7d7d849-7lrg5
```

## S7: Verify Persistent Disks
- Go to Compute Engine -> Storage -> Disks
- Search for `4GB` Persistent Disk
- **Observation:** Review the below items
  - **Zones:** us-central1-b, us-central1-c
  - **Type:** Regional SSD persistent disk
  - **In use by:** gke-standard-cluster-1-default-pool-db7b638f-j5lk



## S8: Access Application
```t
# List Services
kubectl get svc

# Access Application
http://<ExternalIP-from-get-service-output>
Username: admin101
Password: password101
```

## S9: Clean-Up
```t
# Delete Kubernetes Objects
kubectl delete -f kube-manifests/

# Verify if PD is deleted
Go to Compute Engine -> Disks -> Search for 4GB Regional SSD persistent disk.
It should be deleted. 
```



## References 
- [Regional PD](https://cloud.google.com/kubernetes-engine/docs/how-to/persistent-volumes/regional-pd)