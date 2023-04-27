---
title: GKE Headless Service
description: Implement GCP Google Kubernetes Engine GKE Headless Service
---

## S1: Introduction
- Implement Kubernetes ClusterIP and Headless Service

## S2: kubernetes-deployment.yaml
```yaml
apiVersion: apps/v1
kind: Deployment 
metadata: 
  name: kkapp1-deployment
spec: 
  replicas: 4
  selector:
    matchLabels:
      app: kkapp1
  template:  
    metadata: 
      name: kkapp1-pod
      labels: 
        app: kkapp1  
    spec:
      containers: # List
        - name: kkapp1-container
          image: us-docker.pkg.dev/google-samples/containers/gke/hello-app:2.0
          ports: 
            - containerPort: 8080  
        
```

## S3: kubernetes-clusterip-service.yaml
```yaml
apiVersion: v1
kind: Service 
metadata:
  name: kkapp1-cip-service
spec:
  type: ClusterIP 
  selector:
    app: kkapp1
  ports: 
    - name: http
      port: 80 
      targetPort: 8080 
      
```

## S4: kubernetes-headless-service.yaml
- Add `spec.clusterIP: None`
###  VERY IMPORTANT NODE
1. When using Headless Service, we should use both the  "Service Port and Target Port" same. 
2. Headless Service directly sends traffic to Pod with Pod IP and Container Port. 
3. DNS resolution directly happens from headless service to Pod IP.

```yaml
apiVersion: v1
kind: Service 
metadata:
  name: kkapp1-headless-service
spec:
  clusterIP: None
  selector:
    app: kkapp1
  ports: 
    - name: http
      port: 8080 # Service Port
      targetPort: 8080 # Container Port

```

## S5: Deply Kubernetes Manifests
```t
# Deploy Kubernetes Manifests
kubectl apply -f manifests/

# List Deployments
kubectl get deploy

# List Pods
kubectl get pods
kubectl get pods -o wide
Observation: make a note of Pod IP

# List Services
kubectl get svc
Observation: 
1. "CLUSTER-IP" will be "NONE" for Headless Service

## Sample 
cloud_user_p_39753d24@cloudshell:~/managed-k8s (playground-s-11-91018021)$ ls
DOCKER  GKE
cloud_user_p_39753d24@cloudshell:~/managed-k8s (playground-s-11-91018021)$ cd GKE/regional-cluster/
cloud_user_p_39753d24@cloudshell:~/managed-k8s/GKE/regional-cluster (playground-s-11-91018021)$ ls
create-cluster.sh  headless-service  manifests  README.md  sceenshots
cloud_user_p_39753d24@cloudshell:~/managed-k8s/GKE/regional-cluster (playground-s-11-91018021)$ cd headless-service/
cloud_user_p_39753d24@cloudshell:~/managed-k8s/GKE/regional-cluster/headless-service (playground-s-11-91018021)$ ls
manifests
cloud_user_p_39753d24@cloudshell:~/managed-k8s/GKE/regional-cluster/headless-service (playground-s-11-91018021)$ kubectl apply -f manifests/
pod/curl-pod created
service/kkapp1-cip-service created
deployment.apps/kkapp1-deployment created
service/kkapp1-headless-service created
cloud_user_p_39753d24@cloudshell:~/managed-k8s/GKE/regional-cluster/headless-service (playground-s-11-91018021)$ kubectl get svc
NAME                      TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)    AGE
kkapp1-cip-service        ClusterIP   10.80.1.244   <none>        80/TCP     25s
kkapp1-headless-service   ClusterIP   None          <none>        8080/TCP   24s
kubernetes                ClusterIP   10.80.0.1     <none>        443/TCP    26m
cloud_user_p_39753d24@cloudshell:~/managed-k8s/GKE/regional-cluster/headless-service (playground-s-11-91018021)$

```


## S6: Review Curl Kubernetes Manifests
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: curl-pod
spec:
  containers:
  - name: curl
    image: curlimages/curl 
    command: [ "sleep", "600" ]
```

## S7: Deply Curl-pod and Verify ClusterIP and Headless Services
```t
# Deploy curl-pod
kubectl apply -f curl-pod.yml

# List Services
kubectl get svc

# GKE Cluster Kubernetes Service Full DNS Name format
<svc>.<ns>.svc.cluster.local

# Will open up a terminal session into the container
kubectl exec -it curl-pod -- sh

# ClusterIP Service: nslookup and curl Test
nslookup kkapp1-cip-service.default.svc.cluster.local
curl kkapp1-cip-service.default.svc.cluster.local

### ClusterIP Service nslookup Output
nslookup kkapp1-cip-service.default.svc.cluster.local
Server:         10.80.0.10
Address:        10.80.0.10:53


Name:   kkapp1-cip-service.default.svc.cluster.local
Address: 10.80.1.244

$ curl kkapp1-cip-service.default.svc.cluster.local
Hello, world!
Version: 2.0.0
Hostname: kkapp1-deployment-588bd6ccd6-m7gvz


# Headless Service: nslookup and curl Test
nslookup kkapp1-headless-service.default.svc.cluster.local
curl kkapp1-headless-service.default.svc.cluster.local:8080
Observation:
1. There is no specific IP for Headless Service
2. It will be directly dns resolved to Pod IP
3. That said we should use the same port as Container Port for Headless Service

### Headless Service nslookup Output
$ nslookup kkapp1-headless-service.default.svc.cluster.local
Server:         10.80.0.10
Address:        10.80.0.10:53

Name:   kkapp1-headless-service.default.svc.cluster.local
Address: 10.76.2.6
Name:   kkapp1-headless-service.default.svc.cluster.local
Address: 10.76.0.10
Name:   kkapp1-headless-service.default.svc.cluster.local
Address: 10.76.1.4
Name:   kkapp1-headless-service.default.svc.cluster.local
Address: 10.76.2.5


$ curl kkapp1-headless-service.default.svc.cluster.local:8080
Hello, world!
Version: 2.0.0
Hostname: kkapp1-deployment-588bd6ccd6-vtw9t
$ curl kkapp1-headless-service.default.svc.cluster.local:8080
Hello, world!
Version: 2.0.0
Hostname: kkapp1-deployment-588bd6ccd6-l922h
$ curl kkapp1-headless-service.default.svc.cluster.local:8080
Hello, world!
Version: 2.0.0
Hostname: kkapp1-deployment-588bd6ccd6-856lx
$ curl kkapp1-headless-service.default.svc.cluster.local:8080
Hello, world!
Version: 2.0.0
Hostname: kkapp1-deployment-588bd6ccd6-m7gvz

```

## S8: CleanUp
```t
# Delete Kubernetes Resources
kubectl delete -f manifests/*


