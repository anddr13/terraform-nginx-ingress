Requirements

    Kubernetes cluster (e.g., via Docker Desktop, Minikube, kubeadm)

    kubectl installed and configured

    terraform installed (v1.3+ recommended)

    NGINX Ingress Controller installed

Deployment Steps
1. Install NGINX Ingress Controller

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.1/deploy/static/provider/cloud/deploy.yaml

Wait for the controller pods to become ready:

kubectl get pods -n ingress-nginx

You should see something like:

NAME                                        READY   STATUS    RESTARTS   AGE
ingress-nginx-controller-xxxxx              1/1     Running   0          1m

2. Initialize Terraform

Make sure you're in the project folder with the main.tf file:

terraform init

3. Apply the Configuration

terraform apply -auto-approve

4. Access the Application

If you're using Docker Desktop or a local cluster, the Ingress will likely be available at:

http://localhost/

💡 Reload the page multiple times — you should see the background color alternate between red and blue.



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
