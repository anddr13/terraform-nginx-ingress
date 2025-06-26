✅ Requirements

Make sure you have the following:

    ✅ A Kubernetes cluster (Docker Desktop, Minikube, or kubeadm)

    ✅ kubectl installed and configured (should return nodes with kubectl get nodes)

    ✅ terraform installed 

    ✅ NGINX Ingress Controller installed (see Step 1 below)
   🚀 Step 1: Install NGINX Ingress Controller

If you haven’t already, run:
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.1/deploy/static/provider/cloud/deploy.yaml
```
Wait for the controller to be ready:
```
kubectl get pods -n ingress-nginx
```
You should see:
```
NAME                                        READY   STATUS    RESTARTS   AGE
ingress-nginx-controller-xxxxx              1/1     Running   0          1m
```
⚙️ Step 2: Initialize Terraform

Go to the directory where your main.tf file is located:
```
terraform init
```
🏗️ Step 3: Apply the Terraform Configuration

Run:
```
terraform apply -auto-approve
```

🌐 Step 4: Access the Application

For local clusters (e.g., Docker Desktop, Minikube):
```
    The Ingress is usually accessible at:
    👉 http://localhost/
```
Open your browser and go to:

http://localhost/

🔁 Refresh the page — you should see it alternate between:

    🔴 RED NGINX

    🔵 BLUE NGINX

🧪 Quick Test with Curl

You can also test via terminal:
```
curl http://localhost/
```


```

📘 Test Task Description: Deploy Two NGINX Pods and Ingress with Load Balancing
🎯 Objective
Create a Terraform configuration that deploys the following to a Kubernetes cluster:

Two NGINX Deployments, each with a unique custom start page:

One with a red background and the text RED NGINX

Another with a blue background and the text BLUE NGINX

Two Services to expose each NGINX Deployment.

An Ingress resource that uses round-robin load balancing to alternate HTTP requests between the two services.

📋 Requirements
Use Terraform to define all Kubernetes resources.

Deploy everything into a dedicated Kubernetes namespace (default: test-nginx).

The custom NGINX start pages must be served via ConfigMap, replacing the default /usr/share/nginx/html/index.html file.

Ingress must use IngressClass nginx.

Add the annotation nginx.ingress.kubernetes.io/load-balance: round_robin to enable request distribution.


🧰 Additional Notes
The Ingress must be externally accessible (via LoadBalancer service or a configured Ingress Controller).

To verify the setup: when accessing the Ingress URL at /, reloading the page should alternate between the red and blue NGINX pages.
```
