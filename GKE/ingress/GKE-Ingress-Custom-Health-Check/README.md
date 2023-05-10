---
Title: GCP Google Kubernetes Engine Ingress Custom Health Check
Description: Implement GCP Google Kubernetes Engine GKE Ingress Custom Health Checks using Readiness Probes 
---
## S0: Pre-requisites
1. Verify if GKE Cluster is created
2. Verify if kubeconfig for kubectl is configured in your local terminal
```t
# Configure Cluster
1. Use The scripts in private-cluster to provision a custom vpc and a K8S cluster
```


## S1: Introduction
- Ingress Context Path based Routing
- Ingress Custom Health Checks for each application using Kubernetes Readiness Probes
  - **App1 Health Check Path:** /app1/index.html
  - **App2 Health Check Path:** /app2/index.html
  - **App3 Health Check Path:** /index.html


## S2: Nginx-App1-Deployment-and-NodePortService.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app1-nginx-deployment
  labels:
    app: app1-nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app1-nginx
  template:
    metadata:
      labels:
        app: app1-nginx
    spec:
      containers:
        - name: app1-nginx
          image: unpluggedkk/kubenginx:v1
          ports:
            - containerPort: 80
          # Readiness Probe (https://cloud.google.com/kubernetes-engine/docs/concepts/ingress#def_inf_hc)             
          readinessProbe:
            httpGet:
              scheme: HTTP
              path: /app1/index.html
              port: 80
            initialDelaySeconds: 10
            periodSeconds: 15
            timeoutSeconds: 5       
```

## S3: Nginx-App2-Deployment-and-NodePortService.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app2-nginx-deployment
  labels:
    app: app2-nginx 
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app2-nginx
  template:
    metadata:
      labels:
        app: app2-nginx
    spec:
      containers:
        - name: app2-nginx
          image: unpluggedkk/kubenginx:v2
          ports:
            - containerPort: 80
          # Readiness Probe (https://cloud.google.com/kubernetes-engine/docs/concepts/ingress#def_inf_hc)             
          readinessProbe:
            httpGet:
              scheme: HTTP
              path: /app2/index.html
              port: 80
            initialDelaySeconds: 10
            periodSeconds: 15
            timeoutSeconds: 5   
```

## S4: Nginx-App3-Deployment-and-NodePortService.yaml
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
          # Readiness Probe (https://cloud.google.com/kubernetes-engine/docs/concepts/ingress#def_inf_hc)            
          readinessProbe:
            httpGet:
              scheme: HTTP
              path: /index.html
              port: 80
            initialDelaySeconds: 10
            periodSeconds: 15
            timeoutSeconds: 5     
```

## S5: Ingress-Custom-Healthcheck.yaml
- NO CHANGES FROM CONTEXT PATH ROUTING DEMO other than Ingress Service name `ingress-custom-healthcheck`
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-custom-healthcheck
  annotations:
    # External Load Balancer
    kubernetes.io/ingress.class: "gce"  
spec: 
  defaultBackend:
    service:
      name: app3-nginx-nodeport-service
      port:
        number: 80                            
  rules:
    - http:
        paths:           
          - path: /app1
            pathType: Prefix
            backend:
              service:
                name: app1-nginx-nodeport-service
                port: 
                  number: 80
          - path: /app2
            pathType: Prefix
            backend:
              service:
                name: app2-nginx-nodeport-service
                port: 
                  number: 80
#          - path: /
#            pathType: Prefix
#            backend:
#              service:
#                name: app3-nginx-nodeport-service
#                port: 
#                  number: 80                     
             
```


## S6: Deploy kube-manifests and verify
```t
# Deploy Kubernetes manifests
kubectl apply -f kube-manifests

# List Pods
kubectl get pods

# List Services
kubectl get svc

# List Ingress Load Balancers
kubectl get ingress

# Describe Ingress and view Rules
kubectl describe ingress ingress-custom-healthcheck
```

## S7: Verify Health Checks
- Go to Load Balancing -> Click on LB
- DETAILS TAB
  - Backend services -> First Backend -> Click on Health Check Link
- OR
- Go to Compute Engine -> Instance Groups -> Health Checks
- Review all 3 Health Checks and their Paths  
  - **App1 Health Check Path:** /app1/index.html
  - **App2 Health Check Path:** /app2/index.html
  - **App3 Health Check Path:** /index.html


## S8: Access Application
```t
# Important Note
Wait for 2 to 3 minutes for the Load Balancer to completely create and ready for use else we will get HTTP 502 errors

# Access Application
http://<ADDRESS-FIELD-FROM-GET-INGRESS-OUTPUT>/app1/index.html
http://<ADDRESS-FIELD-FROM-GET-INGRESS-OUTPUT>/app2/index.html
http://<ADDRESS-FIELD-FROM-GET-INGRESS-OUTPUT>/
```

## S9: Clean Up
```t
# Delete Kubernetes Resources
kubectl delete -f kube-manifests

# Verify Load Balancer Deleted
Go to Network Services -> Load Balancing -> No Load balancers should be present
```

## References
- [GKE Ingress Healthchecks](https://cloud.google.com/kubernetes-engine/docs/concepts/ingress#health_checks)