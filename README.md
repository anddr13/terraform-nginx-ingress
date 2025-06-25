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
