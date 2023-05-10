---
Title: GCP Google Kubernetes Engine GKE Ingress Basics
Description: Implement GCP Google Kubernetes Engine GKE Ingress Basics
---
## Step0: Pre-requisites
1. Verify if GKE Cluster is created
2. Verify if kubeconfig for kubectl is configured in your local terminal
```t
# Configure Cluster
1. Use The scripts in private-cluster to provision a custom vpc and a K8S cluster
```

## Step1: Introduction
- Learn Ingress Basics
- [Ingress Diagram Reference](https://cloud.google.com/kubernetes-engine/docs/concepts/ingress#ingress_to_resource_mappings)

## Step2: Verify HTTP Load Balancing enabled for your GKE Cluster
- Go to Kubernetes Engine -> kishore-k8s-private-cluster -> DETAILS tab -> Networking
- Verify `HTTP Load Balancing: Enabled` 


## Step3: Kubernetes Deployment: Nginx-App3-Deployment-and-NodePortService.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app3-nginx-deployment
  labels:
    app: app3-nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app3-nginx
  template:
    metadata:
      labels:
        app: app3-nginx
    spec:
      containers:
        - name: app3-nginx
          image: unpluggedkk/kubenginx:v3
          ports:
            - containerPort: 80
```

## Step4: Kubernetes NodePort Service: Nginx-App3-Deployment-and-NodePortService.yaml
```yaml
apiVersion: v1
kind: Service
metadata:
  name: app3-nginx-nodeport-service
  labels:
    app: app3-nginx
  annotations:
spec:
  type: NodePort
  selector:
    app: app3-nginx
  ports:
    - port: 80
      targetPort: 80
```

## Step5: ingress-basic.yaml
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-basics
  annotations:
    # If the class annotation is not specified it defaults to "gce".
    # gce: external load balancer
    # gce-internal: internal load balancer
    kubernetes.io/ingress.class: "gce"  
spec:
  defaultBackend:
    service:
      name: app3-nginx-nodeport-service
      port:
        number: 80                   
```

## Step6: Deploy kube-manifests and Verify
```t
# Deploy kube-manifests
kubectl apply -f kube-manifests/

# List Deployments
kubectl get deploy

# List Pods
kubectl get pods

# List Services
kubectl get svc

# List Ingress
kubectl get ingress
Observation:
1. Wait for ADDRESS field to populate the Public IP Address

# Describe Ingress 
kubectl describe ingress ingress-basics

# Access Application
http://<ADDRESS-FIELD-FROM-GET-INGRESS-OUTPUT>
Important Note:
1. If you get 502 error, wait for 2 to 3 mins and retry. 
2. It takes time to create load balancer on GCP.
```

## Step7: Verify Load Balancer
- Go to Load Balancing -> Click on Load balancer
### Load Balancer View 
- DETAILS Tab
  - Frontend
  - Host and Path Rules
  - Backend Services
  - Health Checks
- MONITORING TAB
- CACHING TAB 
### Load Balancer Components View
- FORWARDING RULES
- TARGET PROXIES
- BACKEND SERVICES
- BACKEND BUCKETS
- CERTIFICATES
- TARGET POOLS

## Step8: Clean-Up
```t
# Delete Kubernetes Resources
kubectl delete -f kube-manifests

# Verify if load balancer got deleted
Go to Load Balancing -> Should not see any load balancers
```

## GKE Ingress References
- [Ingress Features](https://cloud.google.com/kubernetes-engine/docs/how-to/ingress-features)
-[Ingress Concepts](https://cloud.google.com/kubernetes-engine/docs/concepts/ingress)
- [Service Networking](https://cloud.google.com/kubernetes-engine/docs/concepts/service-networking)