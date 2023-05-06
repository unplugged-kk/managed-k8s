---
Title: GKE Persistent Disks Preexisting PD
Description: Use Google Disks Preexisting PD for Kubernetes Workloads
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
- Use the **pre-existing Persistent Disk** created in previous demo.
- As part of this demo, we are going to provision the **Persistent Volume (PV)** manually. We call this as Static Provisioning. 


## S2: List Kubernetes Storage Classes in GKE Cluster
```t
# List Storage Classes
kubectl get sc
```

## S3: persistent-volume.yaml
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: preexisting-pd
spec:
  storageClassName: standard-rwo
  capacity:
    storage: 8Gi
  accessModes:
    - ReadWriteOnce
  claimRef:
    namespace: default
    name: mysql-pv-claim
  gcePersistentDisk:
    pdName: preexisting-pd
    fsType: ext4
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
  storageClassName: standard-rwo
  resources: 
    requests:
      storage: 8Gi
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
- Search for `8GB` Persistent Disk
- **Observation:** You should see the disk type **In Use By** updated and bound to **gke-kishore-k8s-private--default-pool-10c9aa69-t5j6**



## S8: Access Application
```t
# List Services
kubectl get svc

# Access Application
http://<ExternalIP-from-get-service-output>
Username: admin101
Password: password101

Observation:
1. You should see admin102 already present.
2. This is because in previous demo, we already created admin102 and that data disk we have mounted here using "Static Provisioning PV" concept.
```

## S9: Clean-Up
```t
# Delete Kubernetes Objects
kubectl delete -f kube-manifests/

# List PVC
kubectl get pvc

# List PV
kubectl get pv

# Delete Persistent Disk: preexisting-pd
1. "preexisting-pd" will not get deleted automatically
2. We should manually delete it 
3. We should observe that its "In Use By" field is empty (Not associated to anything)
4. Go to Compute Engine -> Disks -> preexisting-pd -> DELETE 
```

