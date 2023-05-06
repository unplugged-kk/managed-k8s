---
Title: GKE Persistent Disks Existing StorageClass premium-rwo
Description: Use existing storageclass premium-rwo in Kubernetes Workloads
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

- Use the predefined Storage class `premium-rwo`
- By default, dynamically provisioned PersistentVolumes use the default StorageClass and are backed by `standard hard disks`. 
- If you need faster SSDs, you can use the `premium-rwo` storage class from the Compute Engine persistent disk CSI Driver to provision your volumes. 
- This can be done by setting the storageClassName field to `premium-rwo` in your PersistentVolumeClaim 
- `premium-rwo Storage Class` will provision `SSD Persistent Disk`

## S2: List Kubernetes Storage Classes in GKE Cluster
```t
# List Storage Classes
kubectl get sc
```

## S3: persistent-volume-claim.yaml
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pv-claim
spec: 
  accessModes:
    - ReadWriteOnce
  storageClassName: premium-rwo 
  resources: 
    requests:
      storage: 4Gi
```

## S4: Other Kubernetes YAML Manifests
- No changes to other Kubernetes YAML Manifests
- They are same as previous section
1. persistent-volume-claim.yaml
2. UserManagement-ConfigMap.yaml
3. mysql-deployment.yaml
4. mysql-clusterip-service.yaml
5. UserMgmtWebApp-Deployment.yaml
6. UserMgmtWebApp-LoadBalancer-Service.yaml

## S5: Deploy kube-manifests
```t
# Deploy Kubernetes Manifests
kubectl apply -f kube-manifests/

# List Storage Classes
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

## S6: Verify Persistent Disks
- Go to Compute Engine -> Storage -> Disks
- Search for `4GB` Persistent Disk
- **Observation:** You should see the disk type as **SSD persistent disk**


## S7: Access Application
```t
# List Services
kubectl get svc

# Access Application
http://<ExternalIP-from-get-service-output>
Username: admin101
Password: password101
```

## S8: Clean-Up
```t
# Delete kube-manifests
kubectl delete -f kube-manifests/
```

## Reference
- [Using the Compute Engine persistent disk CSI Driver](https://cloud.google.com/kubernetes-engine/docs/how-to/persistent-volumes/gce-pd-csi-driver)