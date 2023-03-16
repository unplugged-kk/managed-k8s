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


# CLI Commands to create cluster :

gcloud beta container --project "devsecopskishore2023jan" clusters create "kishore-public-cluster-1" --no-enable-basic-auth --cluster-version "1.24.9-gke.3200" --release-channel "regular" --machine-type "e2-small" --image-type "COS_CONTAINERD" --disk-type "pd-balanced" --disk-size "20" --metadata disable-legacy-endpoints=true --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" --num-nodes "1" --logging=SYSTEM,WORKLOAD --monitoring=SYSTEM --enable-ip-alias --network "projects/devsecopskishore2023jan/global/networks/default" --subnetwork "projects/devsecopskishore2023jan/regions/us-central1/subnetworks/default" --no-enable-intra-node-visibility --default-max-pods-per-node "110" --enable-dataplane-v2 --no-enable-master-authorized-networks --addons HorizontalPodAutoscaling,HttpLoadBalancing,GcePersistentDiskCsiDriver --enable-autoupgrade --enable-autorepair --max-surge-upgrade 1 --max-unavailable-upgrade 0 --workload-pool "devsecopskishore2023jan.svc.id.goog" --enable-shielded-nodes --node-locations "us-central1-a","us-central1-b","us-central1-c"

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

