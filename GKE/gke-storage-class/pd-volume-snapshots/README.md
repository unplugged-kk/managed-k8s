---
Title: GKE Persistent Disks - Volume Snapshots and Restore
Description: Use Google Disks Volume Snapshots and Restore Concepts applied for Kubernetes Workloads
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
1. Deploy UMS WebApp with `kube-manifests`
2. Create new User (admin102, admin103)
3. Create Volume Snapshot Kubernetes Objects and Deploy them
4. Delete User (admin102, admin103)
5. Deploy PVC Restore `Volume-Restore`
6. Verify if after restore 2 more users what we deleted got restored in our UMS App
7. Clean Up (kubectl delete -R -f <Folder>)

## S2:  Kubernetes YAML Manifests
- **Project Folder:** kube-manifests
- No changes to Kubernetes YAML Manifests, same as Section `existing-SC-standard-rwo`
- persistent-volume-claim.yaml
- UserManagement-ConfigMap.yaml
- mysql-deployment.yaml
- mysql-clusterip-service.yaml
- UserMgmtWebApp-Deployment.yaml
- UserMgmtWebApp-LoadBalancer-Service.yaml

## S3: Deploy kube-manifests
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

## S4: Verify Persistent Disks
- Go to Compute Engine -> Storage -> Disks
- Search for `4GB` Persistent Disk
- **Observation:** Review the below items
  - **Zones:** us-central1-c
  - **Type:** Balanced persistent disk
  - **In use by:** gke-standard-cluster-1-default-pool-db7b638f-j5lk

## S5: Access Application
```t
# List Services
kubectl get svc

# Access Application
http://<ExternalIP-from-get-service-output>
Username: admin101
Password: password101

# Create New User admin102
Username: admin102
Password: password102
First Name: fname102
Last Name: lname102
Email Address: admin102@kishorekumar.today  
Social Security Address: ssn102

# Create New User admin103
Username: admin103
Password: password103
First Name: fname103
Last Name: lname103
Email Address: admin103@kishorekumar.today  
Social Security Address: ssn103
```

## S6: Volume-Snapshot: Create Volume Snapshots
- **Project Folder:** Volume-Snapshot
### S6-01: VolumeSnapshotClass.yaml
```yaml
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshotClass
metadata:
  name: my-snapshotclass
driver: pd.csi.storage.gke.io
deletionPolicy: Delete
#parameters: 
#  storage-locations: us-east2

# Optional Note: 
# To use a custom storage location, add a storage-locations parameter to the snapshot class. 
# To use this parameter, your clusters must use version 1.21 or later.
```
### S6-02: VolumeSnapshot.yaml
```yaml
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: my-snapshot1
spec:
  volumeSnapshotClassName: my-snapshotclass
  source:
    persistentVolumeClaimName: mysql-pv-claim
```
### S6-03: Deploy Volume Snapshot Kubernetes Manifests
```t
# Deploy Volume Snapshot Kubernetes Manifests
kubectl apply -f Volume-Snapshot/

# List VolumeSnapshotClass
kubectl get volumesnapshotclass

# Describe VolumeSnapshotClass
kubectl describe volumesnapshotclass my-snapshotclass

# List VolumeSnapshot
kubectl get volumesnapshot

# Describe VolumeSnapshot
kubectl describe volumesnapshot my-snapshot1

# Verify the Snapshots
Go to Compute Engine -> Storage -> Snapshots
Observation:
1. You should find the new snapshot created
2. Review the "Creation Time"
3. Review the "Disk Size: 4GB"
```

## S7: Delete users admin102, admin103
```t
# List Services
kubectl get svc

# Access Application
http://<ExternalIP-from-get-service-output>
Username: admin101
Password: password101

# Delete Users
admin102
admin103
```


## S8: Volume-Restore: Create Volume Restore
- **Project Folder:** Volume-Restore
### S8-01: restore-pvc.yaml
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-restore
spec:
  dataSource:
    name: my-snapshot1
    kind: VolumeSnapshot
    apiGroup: snapshot.storage.k8s.io
  storageClassName: standard-rwo
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 4Gi
```
### S8-02: mysql-deployment.yaml
- Update Claim Name from `claimName: mysql-pv-claim` to `claimName: pvc-restore` 
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql
spec: 
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  strategy:
    type: Recreate 
  template: 
    metadata: 
      labels: 
        app: mysql
    spec: 
      containers:
        - name: mysql
          image: mysql:5.6
          env:
            - name: MYSQL_ROOT_PASSWORD
              value: dbpassword11
          ports:
            - containerPort: 3306
              name: mysql    
          volumeMounts:
            - name: mysql-persistent-storage
              mountPath: /var/lib/mysql    
            - name: usermanagement-dbcreation-script
              mountPath: /docker-entrypoint-initdb.d #https://hub.docker.com/_/mysql Refer Initializing a fresh instance                                        
      volumes: 
        - name: mysql-persistent-storage
          persistentVolumeClaim:
            #claimName: mysql-pv-claim
            claimName: pvc-restore
        - name: usermanagement-dbcreation-script
          configMap:
            name: usermanagement-dbcreation-script
```
### S8-03: Deploy Volume Restore Kubernetes Manifests
```t
# Deploy Volume Restore Kubernetes Manifests
kubectl apply -f Volume-Restore/

# List PVC
kubectl get pvc

# List PV
kubectl get pv

# List Pods
kubectl get pods

# Restart Deployments (Optional - If ERRORS)
kubectl rollout restart deployment mysql
kubectl rollout restart deployment usermgmt-webapp

# Review Persistent Disk
1. Go to Compute Engine -> Storage -> Disks
2. You should find a new "Balanced persistent disk" created as part of new PVC "pvc-restore"
3. To get the exact Disk name for "pvc-restore" PVC run command "kubectl get pvc"


# Access Application
http://<ExternalIP-from-get-service-output>
Username: admin101
Password: password101
Observation:
1. You should find admin102, admin103 present
2. That proves, we have restored the MySQL Data using VolumeSnapshots and PVC
```

## S9: Clean-Up
```t
# Delete All (Disks, Snapshots)
kubectl delete -f kube-manifests -f Volume-Snapshot -f Volume-Restore

# List PVC
kubectl get pvc

# List PV
kubectl get pv

# List VolumeSnapshotClass
kubectl get volumesnapshotclass

# List VolumeSnapshot
kubectl get volumesnapshot

# Verify Persistent Disks
1. Go to Compute Engine -> Storage -> Disks -> REFRESH
2. Two disks created as part of this demo is deleted

# Verify Disk Snapshots
1. Go to Compute Engine -> Storage -> Snapshots -> REFRESH
2. There should not be any snapshot which we created as part of this demo. 
```


