## Pre-requisite Step
- Create your Docker hub account. 
- https://hub.docker.com/
- **Important Note**: In the below listed commands wherever you see **unpluggedkk** you can replace with your docker hub account id. 


## Create Dockerfile and copy our customized nginx default.conf
- **Dockerfile**
```Dockerfile 
FROM nginx
COPY default.conf /etc/nginx/conf.d
```
- **default.conf**
  - Replace your backend cluster-ip service name and port in `proxy_pass`
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

## Build Docker Image & run it
```
# Build Docker Image
docker build -t unpluggedkk/kube-frontend-nginx:v1 .

# Replace your docker hub account Id
docker build -t <your-docker-hub-id>/kube-frontend-nginx:v1 .
```

## Push the Docker image to docker hub
```
# Push Docker Image to Docker Hub
docker push unpluggedkk/kube-frontend-nginx:v1 

# Replace your docker hub account Id
docker push <your-docker-hub-id>/kube-frontend-nginx:v1 
```