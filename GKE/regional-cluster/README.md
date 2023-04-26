## READ ME ##
# Install gcloud cli : on Linux / Mac

curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-420.0.0-linux-x86_64.tar.gz
tar -xzvf google-cloud-cli-420.0.0-linux-x86_64.tar.gz
./google-cloud-sdk/install.sh
./google-cloud-sdk/bin/gcloud init

# Install kubectl 

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
chmod +x kubectl
mkdir -p ~/.local/bin
mv ./kubectl ~/.local/bin/kubectl

Verify : 
kubectl version --client

# Setup Zone 

gcloud config set compute/region us-central1

# Enable Services

gcloud services enable container.googleapis.com storage.googleapis.com anthos.googleapis.com anthosgke.googleapis.com cloud.googleapis.com cloudresourcemanager.googleapis.com containerregistry.googleapis.com file.googleapis.com ; gcloud services list --enabled

# Use script to create cluster

 GKE/regional-cluster/create-cluster.sh

# CLI Commands to create cluster :

gcloud beta container --project "devsecopskishore2023jan" clusters create "kishore-public-cluster-1" --no-enable-basic-auth --cluster-version "1.25.7-gke.1000" --release-channel "regular" --machine-type "e2-small" --image-type "COS_CONTAINERD" --disk-type "pd-balanced" --disk-size "20" --metadata disable-legacy-endpoints=true --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" --num-nodes "1" --logging=SYSTEM,WORKLOAD --monitoring=SYSTEM --enable-ip-alias --network "projects/devsecopskishore2023jan/global/networks/default" --subnetwork "projects/devsecopskishore2023jan/regions/us-central1/subnetworks/default" --no-enable-intra-node-visibility --default-max-pods-per-node "110" --enable-dataplane-v2 --no-enable-master-authorized-networks --addons HorizontalPodAutoscaling,HttpLoadBalancing,GcePersistentDiskCsiDriver --enable-autoupgrade --enable-autorepair --max-surge-upgrade 1 --max-unavailable-upgrade 0 --workload-pool "devsecopskishore2023jan.svc.id.goog" --enable-shielded-nodes --node-locations "us-central1-a","us-central1-b","us-central1-c"

# Verification: 


# Verify gke-gcloud-auth-plugin Installation (if not installed, install it)
gke-gcloud-auth-plugin --version 

# Install Kubectl authentication plugin for GKE
sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin

# Verify gke-gcloud-auth-plugin Installation
gke-gcloud-auth-plugin --version 

# Configure kubeconfig for kubectl
gcloud container clusters get-credentials <CLUSTER-NAME> --region <REGION> --project <PROJECT-NAME>
gcloud container clusters get-credentials kishore-public-cluster-1 --region us-central1 --project devsecopskishore2023jan

# Run kubectl with the new plugin prior to the release of v1.25
vi ~/.bashrc
USE_GKE_GCLOUD_AUTH_PLUGIN=True

# Reload the environment value
source ~/.bashrc

# Check if Environment variable loaded in Terminal
echo $USE_GKE_GCLOUD_AUTH_PLUGIN

# Verify kubectl version
kubectl version --short

# Install kubectl (if not installed)
gcloud components install kubectl

# Configure kubectl
gcloud container clusters get-credentials <CLUSTER-NAME> --zone <ZONE> --project <PROJECT-ID>
gcloud container clusters get-credentials kishore-public-cluster-1 --zone us-central1-c --project devsecopskishore2023jan

# Verify Kubernetes Worker Nodes
kubectl get nodes

# Verify System Pod in kube-system Namespace
kubectl -n kube-system get pods

# Verify kubeconfig file
cat $HOME/.kube/config
kubectl config view

# Sample Deployment 

❯ kubectl apply -f regional-cluster/manifests/
deployment.apps/myapp1-deployment created
service/myapp1-lb-service created

 
❯ kubectl get deploy
NAME                READY   UP-TO-DATE   AVAILABLE   AGE
myapp1-deployment   2/2     2            2           62s

❯ kubectl get svc
NAME                TYPE           CLUSTER-IP   EXTERNAL-IP     PORT(S)        AGE
kubernetes          ClusterIP      10.80.0.1    <none>          443/TCP        47m
myapp1-lb-service   LoadBalancer   10.80.6.12   34.173.80.156   80:32686/TCP   68s

❯ curl 34.173.80.156
Hello, world!
Version: 1.0.0
Hostname: myapp1-deployment-7d49894b88-wxrwm

❯ kubectl delete -f regional-cluster/manifests/
deployment.apps "myapp1-deployment" deleted
service "myapp1-lb-service" deleted

### Imperative commands

## Get Worker Nodes Status
- Verify if kubernetes worker nodes are ready. 
```t
# Configure kubeconfig for kubectl
gcloud container clusters get-credentials <CLUSTER-NAME> --region <REGION> --project <PROJECT-NAME>
gcloud container clusters get-credentials kishore-public-cluster-1 --zone us-central1-c --project devsecopskishore2023jan

# Get Worker Node Status
kubectl get nodes

# Get Worker Node Status with wide option
kubectl get nodes -o wide
```

## Create a Pod
- Create a Pod
```t
# Template
kubectl run <desired-pod-name> --image <Container-Image> 

# Replace Pod Name, Container Image
kubectl run my-first-pod --image unpluggedkk/kubenginx:v2
```  

## List Pods
- Get the list of pods
```t
# List Pods
kubectl get pods

# Alias name for pods is po
kubectl get po
```

## List Pods with wide option
- List pods with wide option which also provide Node information on which Pod is running
```t
# List Pods with Wide Option
kubectl get pods -o wide
```

## What happened in the backgroup when above command is run?
1. Kubernetes created a pod
2. Pulled the docker image from docker hub
3. Created the container in the pod
4. Started the container present in the pod

## Describe Pod
- Describe the POD, primarily required during troubleshooting. 
- Events shown will be of a great help during troubleshooting. 
```t
# To get list of pod names
kubectl get pods

# Describe the Pod
kubectl describe pod <Pod-Name>
kubectl describe pod my-first-pod 
Observation:
1. Review Events - thats the key for troubleshooting, understanding what happened
```

## Access Application
- Currently we can access this application only inside worker nodes. 
- To access it externally, we need to create a **NodePort or Load Balancer Service**. 
- **Services** is one very very important concept in Kubernetes. 

## Delete Pod
```t
# To get list of pod names
kubectl get pods

# Delete Pod
kubectl delete pod <Pod-Name>
kubectl delete pod my-first-pod
```

## Load Balancer Service Introduction
- What are Services in k8s?
- What is a Load Balancer Service?
- How it works?

## Demo - Expose Pod with a Service
- Expose pod with a service (Load Balancer Service) to access the application externally (from internet)
- **Ports**
  - **port:** Port on which node port service listens in Kubernetes cluster internally
  - **targetPort:** We define container port here on which our application is running.
- Verify the following before LB Service creation
  - Load Balancer created for GKE Cluster
    - Frontend IP Configuration
    - Load Balancing Rules
  - External Public IP 
```t
# Create  a Pod
kubectl run <desired-pod-name> --image <Container-Image> 
kubectl run my-first-pod --image unpluggedkk/kubenginx:v2

# Expose Pod as a Service
kubectl expose pod <Pod-Name>  --type=LoadBalancer --port=80 --name=<Service-Name>
kubectl expose pod my-first-pod  --type=LoadBalancer --port=80 --name=my-first-service

# Get Service Info
kubectl get service
kubectl get svc
Observation:
1. Initially External-IP will show as pending and slowly it will get the external-ip assigned and displayed.
2. It will take 2 to 3 minutes to get the external-ip listed

# Describe Service
kubectl describe service my-first-service

# Access Application
http://<External-IP-from-get-service-output>
curl http://<External-IP-from-get-service-output>
```
- Verify the following after LB Service creation
- Google Load Balancer created, verify it. 
  - Verify Backends 
  - Verify Frontends
- Verify **Workloads and Services** on Google GKE Dashboard GCP Console


## Interact with a Pod
## Verify Pod Logs
```t
# Get Pod Name
kubectl get po

# Dump Pod logs
kubectl logs <pod-name>
kubectl logs my-first-pod

# Stream pod logs with -f option and access application to see logs
kubectl logs <pod-name>
kubectl logs -f my-first-pod
```
- **Important Notes**
- Refer below link and search for **Interacting with running Pods** for additional log options
- Troubleshooting skills are very important. So please go through all logging options available and master them.
- **Reference:** https://kubernetes.io/docs/reference/kubectl/cheatsheet/

## Connect to a Container in POD and execute command
```t
# Connect to Nginx Container in a POD
kubectl exec -it <pod-name> -- /bin/bash
kubectl exec -it my-first-pod -- /bin/bash

# Execute some commands in Nginx container
ls
cd /usr/share/nginx/html
cat index.html
exit
```
## Running individual commands in a Container
```t
# Template
kubectl exec -it <pod-name> -- <COMMAND>

# Sample Commands
kubectl exec -it my-first-pod -- env
kubectl exec -it my-first-pod -- ls
kubectl exec -it my-first-pod -- cat /usr/share/nginx/html/index.html
```

## Get YAML Output of Pod & Service
## Get YAML Output
```t
# Get pod definition YAML output
kubectl get pod my-first-pod -o yaml   

# Get service definition YAML output
kubectl get service my-first-service -o yaml   
```

## Clean-Up
```t
# Get all Objects in default namespace
kubectl get all

# Delete Services
kubectl delete svc my-first-service

# Delete Pod
kubectl delete pod my-first-pod

# Get all Objects in default namespace
kubectl get all
```


## More Options

```t
# Return snapshot logs from pod nginx with only one container
kubectl logs nginx

# Return snapshot of previous terminated ruby container logs from pod web-1
kubectl logs -p -c ruby web-1

# Begin streaming the logs of the ruby container in pod web-1
kubectl logs -f -c ruby web-1

# Display only the most recent 20 lines of output in pod nginx
kubectl logs --tail=20 nginx

# Show all logs from pod nginx written in the last hour
kubectl logs --since=1h nginx
```

### Kubernetes Replicaset


## Create ReplicaSet
- Create ReplicaSet
```t
# Kubernetes ReplicaSet
kubectl create -f replicaset.yml
```
- **replicaset.yml**
```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: my-helloworld-rs
  labels:
    app: my-helloworld
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-helloworld
  template:
    metadata:
      labels:
        app: my-helloworld
    spec:
      containers:
      - name: my-helloworld-app
        image: unpluggedkk/hello-world-kishore:v3
```

## List ReplicaSets
- Get list of ReplicaSets
```t
# List ReplicaSets
kubectl get replicaset
kubectl get rs
```

## Describe ReplicaSet
- Describe the newly created ReplicaSet
```t
# Describe ReplicaSet
kubectl describe rs/<replicaset-name>

kubectl describe rs/my-helloworld-rs
[or]
kubectl describe rs my-helloworld-rs
```

## List of Pods
- Get list of Pods
```t
# Get list of Pods
kubectl get pods
kubectl describe pod <pod-name>

# Get list of Pods with Pod IP and Node in which it is running
kubectl get pods -o wide
```

## Verify the Owner of the Pod
- Verify the owner reference of the pod.
- Verify under **"name"** tag under **"ownerReferences"**. We will find the replicaset name to which this pod belongs to. 
```t
# List Pod with Output as YAML
kubectl get pods <pod-name> -o yaml
kubectl get pods my-helloworld-rs-c8rrj -o yaml 
```

## Expose ReplicaSet as a Service
- Expose ReplicaSet with a service (Load Balancer Service) to access the application externally (from internet)
```t
# Expose ReplicaSet as a Service
kubectl expose rs <ReplicaSet-Name>  --type=LoadBalancer --port=80 --target-port=8080 --name=<Service-Name-To-Be-Created>
kubectl expose rs my-helloworld-rs  --type=LoadBalancer --port=80 --target-port=8080 --name=my-helloworld-rs-service

# List Services
kubectl get service
kubectl get svc
```
- **Access the Application using External or Public IP**
```t
# Access Application
http://<External-IP-from-get-service-output>/hello
curl http://<External-IP-from-get-service-output>/hello

# Observation
1. Each time we access the application, request will be sent to different pod and pods id will be displayed for us. 
```

## Test Replicaset Reliability or High Availability 
- Test how the high availability or reliability concept is achieved automatically in Kubernetes
- Whenever a POD is accidentally terminated due to some application issue, ReplicaSet should auto-create that Pod to maintain desired number of Replicas configured to achive High Availability.
```t
# To get Pod Name
kubectl get pods

# Delete the Pod
kubectl delete pod <Pod-Name>

# Verify the new pod got created automatically
kubectl get pods   (Verify Age and name of new pod)
``` 

## Test ReplicaSet Scalability feature 
- Test how scalability is going to seamless & quick
- Update the **replicas** field in **replicaset.yml** from 3 to 6.
```yaml
# Before change
spec:
  replicas: 3

# After change
spec:
  replicas: 6
```
- Update the ReplicaSet
```t
# Apply latest changes to ReplicaSet
kubectl replace -f replicaset.yml

# Verify if new pods got created
kubectl get pods -o wide
```

## Delete ReplicaSet & Service
## Delete ReplicaSet
```t
# Delete ReplicaSet
kubectl delete rs <ReplicaSet-Name>

# Sample Commands
kubectl delete rs/my-helloworld-rs
[or]
kubectl delete rs my-helloworld-rs

# Verify if ReplicaSet got deleted
kubectl get rs
```

### Delete Service created for ReplicaSet
```t
# Delete Service
kubectl delete svc <service-name>

# Sample Commands
kubectl delete svc my-helloworld-rs-service
[or]
kubectl delete svc/my-helloworld-rs-service

# Verify if Service got deleted
kubectl get svc
```

# Validation Results

❯ kubectl get rs
NAME               DESIRED   CURRENT   READY   AGE
my-helloworld-rs   6         6         6       12m


❯ kubectl get pods
NAME                     READY   STATUS    RESTARTS   AGE
my-helloworld-rs-cg2kp   1/1     Running   0          4m41s
my-helloworld-rs-ghzqb   1/1     Running   0          12m
my-helloworld-rs-hh8vc   1/1     Running   0          4m41s
my-helloworld-rs-r7xfp   1/1     Running   0          4m41s
my-helloworld-rs-tcvtp   1/1     Running   0          12m
my-helloworld-rs-w69h8   1/1     Running   0          12m


❯ kubectl get svc my-helloworld-rs-service
NAME                       TYPE           CLUSTER-IP    EXTERNAL-IP    PORT(S)        AGE
my-helloworld-rs-service   LoadBalancer   10.80.1.150   34.71.13.158   80:31398/TCP   11m

❯

## Kubernetes Deployments 


## Create Deployment
- Create Deployment to rollout a ReplicaSet
- Verify Deployment, ReplicaSet & Pods
- **Docker Image Location:** https://hub.docker.com/layers/unpluggedkk/kubenginx/
```t
# Create Deployment
kubectl create deployment <Deplyment-Name> --image=<Container-Image>
kubectl create deployment my-first-deployment --image=unpluggedkk/kubenginx:v1

# Verify Deployment
kubectl get deployments
kubectl get deploy 

# Describe Deployment
kubectl describe deployment <deployment-name>
kubectl describe deployment my-first-deployment

# Verify ReplicaSet
kubectl get rs

# Verify Pod
kubectl get po
```
### Update Change-Cause for the Kubernetes Deployment - Rollout History
- **Observation:** We have the rollout history, so we can switch back to older revisions using revision history available to us
```t
# Verify Rollout History
kubectl rollout history deployment/my-first-deployment

# Update REVISION CHANGE-CAUSE for Kubernetes Deployment
kubectl annotate deployment/my-first-deployment kubernetes.io/change-cause="Deployment CREATE - App Version 1.0.0"

# Verify Rollout History
kubectl rollout history deployment/my-first-deployment
```
## Scaling a Deployment
- Scale the deployment to increase the number of replicas (pods)
```t
# Scale Up the Deployment
kubectl scale --replicas=10 deployment/<Deployment-Name>
kubectl scale --replicas=10 deployment/my-first-deployment 

# Verify Deployment
kubectl get deploy

# Verify ReplicaSet
kubectl get rs

# Verify Pods
kubectl get po

# Scale Down the Deployment
kubectl scale --replicas=2 deployment/my-first-deployment 
kubectl get deploy
```

## Expose Deployment as a Service
- Expose **Deployment** with a service (LoadBalancer Service) to access the application externally (from internet)
```t
# Expose Deployment as a Service
kubectl expose deployment <Deployment-Name>  --type=LoadBalancer --port=80 --target-port=80 --name=<Service-Name-To-Be-Created>
kubectl expose deployment my-first-deployment --type=LoadBalancer --port=80 --target-port=80 --name=my-first-deployment-service

# Get Service Info
kubectl get svc
```
- **Access the Application using Public IP**
```t
# Access Application
http://<External-IP-from-get-service-output>
curl http://<External-IP-from-get-service-output>
```


## Kubernetes Deployment Management
- We can update deployments using two options
  - Set Image
  - Edit Deployment

## Updating Application version V2 to V3 using "Set Image" Option
## Update Deployment
- **Observation:** Please Check the container name in `spec.container.name` yaml output and make a note of it and 
replace in `kubectl set image` command <Container-Name>
```t
# Get Container Name from current deployment
kubectl get deployment my-first-deployment -o yaml

# Update Deployment - SHOULD WORK NOW
kubectl set image deployment/<Deployment-Name> <Container-Name>=<Container-Image> 
kubectl set image deployment/my-first-deployment kubenginx=unpluggedkk/kubenginx:v3 
```

## Verify Rollout Status (Deployment Status)
- **Observation:** By default, rollout happens in a rolling update model, so no downtime.
```t
# Verify Rollout Status 
kubectl rollout status deployment/my-first-deployment

# Verify Deployment
kubectl get deploy
```
### Describe Deployment
- **Observation:**
  - Verify the Events and understand that Kubernetes by default do  "Rolling Update"  for new application releases. 
  - With that said, we will not have downtime for our application.
```t
# Descibe Deployment
kubectl describe deployment my-first-deployment
```
### Verify ReplicaSet
- **Observation:** New ReplicaSet will be created for new version
```t
# Verify ReplicaSet
kubectl get rs
```

### Verify Pods
- **Observation:** Pod template hash label of new replicaset should be present for PODs letting us 
know these pods belong to new ReplicaSet.
```t
# List Pods
kubectl get po
```
### Access the Application using Public IP
- We should see `Application Version:V3` whenever we access the application in browser
```t
# Get Load Balancer IP
kubectl get svc

# Application URL
http://<External-IP-from-get-service-output>
```

## Update Change-Cause for the Kubernetes Deployment - Rollout History
- **Observation:** We have the rollout history, so we can switch back to older revisions using revision history available to us.  
```t
# Verify Rollout History
kubectl rollout history deployment/my-first-deployment

# Update REVISION CHANGE-CAUSE
kubectl annotate deployment/my-first-deployment kubernetes.io/change-cause="Deployment UPDATE - App Version 3.0.0 - SET IMAGE OPTION"

# Verify Rollout History
kubectl rollout history deployment/my-first-deployment
```


## Update the Application from V1 to V2 using "Edit Deployment" Option
### Edit Deployment
```t
# Edit Deployment
kubectl edit deployment/<Deployment-Name> 
kubectl edit deployment/my-first-deployment 
```

```yaml
# Change From v1
    spec:
      containers:
      - image: unpluggedkk/kubenginx:v1

# Change To v2
    spec:
      containers:
      - image: unpluggedkk/kubenginx:v2
```


## Verify Rollout Status
- **Observation:** Rollout happens in a rolling update model, so no downtime.
```t
# Verify Rollout Status 
kubectl rollout status deployment/my-first-deployment

# Describe Deployment
kubectl describe deployment/my-first-deployment
```
## Verify Replicasets
- **Observation:**  We should see 3 ReplicaSets now, as we have updated our application to 3rd version 3.0.0
```t
# Verify ReplicaSet and Pods
kubectl get rs
kubectl get po
```

## Access the Application using Public IP
- We should see `Application Version:V2` whenever we access the application in browser
```t
# Get Load Balancer IP
kubectl get svc

# Application URL
http://<External-IP-from-get-service-output>
```

## Update Change-Cause for the Kubernetes Deployment - Rollout History
- **Observation:** We have the rollout history, so we can switch back to older revisions using revision history available to us. 
```t
# Verify Rollout History
kubectl rollout history deployment/my-first-deployment

# Update REVISION CHANGE-CAUSE
kubectl annotate deployment/my-first-deployment kubernetes.io/change-cause="Deployment UPDATE - App Version 2.0.0 - EDIT DEPLOYMENT OPTION"

# Verify Rollout History
kubectl rollout history deployment/my-first-deployment
```

## Rollback a Deployment to previous version

## Check the Rollout History of a Deployment
```t
# List Deployment Rollout History
kubectl rollout history deployment/<Deployment-Name>
kubectl rollout history deployment/my-first-deployment  
```

## Verify changes in each revision
- **Observation:** Review the "Annotations" and "Image" tags for clear understanding about changes.
```t
# List Deployment History with revision information
kubectl rollout history deployment/my-first-deployment --revision=1
kubectl rollout history deployment/my-first-deployment --revision=2
kubectl rollout history deployment/my-first-deployment --revision=3
```


## Rollback to previous version
- **Observation:** If we rollback, it will go back to revision-2 and its number increases to revision-4
```t
# Undo Deployment
kubectl rollout undo deployment/my-first-deployment

# List Deployment Rollout History
kubectl rollout history deployment/my-first-deployment  
```

## Verify Deployment, Pods, ReplicaSets
```t
# Verify Deployment, Pods, ReplicaSets
kubectl get deploy
kubectl get rs
kubectl get po
kubectl describe deploy my-first-deployment
```

### Access the Application using Public IP
- We should see `Application Version:V2` whenever we access the application in browser
```t
# Get Load Balancer IP
kubectl get svc

# Application URL
http://<External-IP-from-get-service-output>
```


## Rollback to specific revision

## Check the Rollout History of a Deployment
```t
# List Deployment Rollout History
kubectl rollout history deployment/<Deployment-Name>
kubectl rollout history deployment/my-first-deployment 
```
## Rollback to specific revision
```t
# Rollback Deployment to Specific Revision
kubectl rollout undo deployment/my-first-deployment --to-revision=3
```

## List Deployment History
- **Observation:** If we rollback to revision 3, it will go back to revision-3 and its number increases to revision-5 in rollout history
```t
# List Deployment Rollout History
kubectl rollout history deployment/my-first-deployment
```


### Access the Application using Public IP
- We should see `Application Version:V3` whenever we access the application in browser
```t
# Get Load Balancer IP
kubectl get svc

# Application URL
http://<Load-Balancer-IP>
```

## Rolling Restarts of Application
- Rolling restarts will kill the existing pods and recreate new pods in a rolling fashion. 
```t
# Rolling Restarts
kubectl rollout restart deployment/<Deployment-Name>
kubectl rollout restart deployment/my-first-deployment

# Get list of Pods
kubectl get po
``` 

## Pausing & Resuming Deployments

## Check current State of Deployment & Application
 ```t
# Check the Rollout History of a Deployment
kubectl rollout history deployment/my-first-deployment  
Observation: Make a note of last version number

# Get list of ReplicaSets
kubectl get rs
Observation: Make a note of number of replicaSets present.

# Access the Application 
http://<External-IP-from-get-service-output>
Observation: Make a note of application version
```

## Pause Deployment and Two Changes
```t
# Pause the Deployment
kubectl rollout pause deployment/<Deployment-Name>
kubectl rollout pause deployment/my-first-deployment

# Update Deployment - Application Version from V3 to V4
kubectl set image deployment/my-first-deployment kubenginx=unpluggedkk/kubenginx:v4

# Check the Rollout History of a Deployment
kubectl rollout history deployment/my-first-deployment  
Observation: No new rollout should start, we should see same number of versions as we check earlier with last version number matches which we have noted earlier.

# Get list of ReplicaSets
kubectl get rs
Observation: No new replicaSet created. We should have same number of replicaSets as earlier when we took note. 

# Make one more change: set limits to our container
kubectl set resources deployment/my-first-deployment -c=kubenginx --limits=cpu=20m,memory=30Mi
```
## Resume Deployment 
```t
# Resume the Deployment
kubectl rollout resume deployment/my-first-deployment

# Check the Rollout History of a Deployment
kubectl rollout history deployment/my-first-deployment  
Observation: You should see a new version got created

# Update REVISION CHANGE-CAUSE
kubectl annotate deployment/my-first-deployment kubernetes.io/change-cause="Deployment PAUSE RESUME Demo - App Version 4.0.0 "

# Check the Rollout History of a Deployment
kubectl rollout history deployment/my-first-deployment

# Get list of ReplicaSets
kubectl get rs
Observation: You should see new ReplicaSet.

# Get Load Balancer IP
kubectl get svc
```
## Access Application
```t
# Access the Application 
http://<External-IP-from-get-service-output>
Observation: You should see Application V4 version
```


## Clean-Up
```t
# Delete Deployment
kubectl delete deployment my-first-deployment

# Delete Service
kubectl delete svc my-first-deployment-service

# Get all Objects from Kubernetes default namespace
kubectl get all
```

## Kubernetes  Services
- **Service Types**
  1. ClusterIp
  2. NodePort
  3. LoadBalancer
  4. ExternalName
  5. Ingress


## ClusterIP Service - Backend Application Setup
- Create a deployment for Backend Application (Spring Boot REST Application)
- Create a ClusterIP service for load balancing backend application.
```t
# Create Deployment for Backend Rest App
kubectl create deployment my-backend-rest-app --image=unpluggedkk/hello-world-kishore:v3
kubectl get deploy

# Create ClusterIp Service for Backend Rest App
kubectl expose deployment my-backend-rest-app --port=8080 --target-port=8080 --name=my-backend-service
kubectl get svc
Observation: We don't need to specify "--type=ClusterIp" because default setting is to create ClusterIp Service. 
```
- **Important Note:** If backend application port (Container Port: 8080) and Service Port (8080) are same we don't need to use **--target-port=8080** but for avoiding the confusion i have added it. Same case applies to frontend application and service. 

- **Backend HelloWorld Application Source** [kube-helloworld](https://hub.docker.com/repository/docker/unpluggedkk/hello-world-kishore/tags?page=1&ordering=last_updated)


## LoadBalancer Service - Frontend Application Setup
-  Implemented **LoadBalancer Service** multiple times so far (in pods, replicasets and deployments), even then we are going to implement one more time to get a full architectural view in relation with ClusterIp service. 
- Create a deployment for Frontend Application (Nginx acting as Reverse Proxy)
- Create a LoadBalancer service for load balancing frontend application. 
- **Important Note:** In Nginx reverse proxy, ensure backend service name `my-backend-service` is updated when you are building the frontend container. We already built it and put ready for this demo (unpluggedkk/hello-world-kishore:v3)
- **Nginx Conf File**
```conf
server {
    listen       80;
    server_name  localhost;
    location / {
    # Update your backend application Kubernetes Cluster-IP Service name  and port below      
    # proxy_pass http://<Backend-ClusterIp-Service-Name>:<Port>;      
    proxy_pass http://my-backend-service:8080;
    }
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
```
- **Docker Image Location:** https://hub.docker.com/repository/docker/unpluggedkk/kube-frontend-nginx
```t
# Create Deployment for Frontend Nginx Proxy
kubectl create deployment my-frontend-nginx-app --image=unpluggedkk/kube-frontend-nginx:v1
kubectl get deploy

# Create LoadBalancer Service for Frontend Nginx Proxy
kubectl expose deployment my-frontend-nginx-app  --type=LoadBalancer --port=80 --target-port=80 --name=my-frontend-service
kubectl get svc

# Get Load Balancer IP
kubectl get svc
http://<External-IP-from-get-service-output>/hello
curl http://<External-IP-from-get-service-output>/hello

# Scale backend with 10 replicas
kubectl scale --replicas=10 deployment/my-backend-rest-app

# Test again to view the backend service Load Balancing
http://<External-IP-from-get-service-output>/hello
curl http://<External-IP-from-get-service-output>/hello
```

## Clean-Up Kubernetes Deployment and Services
```t
# List Services
kubectl get svc 

# Delete Services
kubectl delete service my-backend-service 
kubectl delete service my-frontend-service 

# List Deployments
kubectl get deploy

# Delete Deployments
kubectl delete deployment my-backend-rest-app   
kubectl delete deployment my-frontend-nginx-app
```