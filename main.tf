provider "kubernetes" {
  config_path = "~/.kube/config"
}

# Создание Namespace
resource "kubernetes_namespace" "nginx" {
  metadata {
    name = "test-nginx"
  }
}

# RED ConfigMap
resource "kubernetes_config_map" "red" {
  metadata {
    name      = "red-index"
    namespace = kubernetes_namespace.nginx.metadata[0].name
  }

  data = {
    "index.html" = "<html><body style='background:red'><h1>RED NGINX</h1></body></html>"
  }
}

# BLUE ConfigMap
resource "kubernetes_config_map" "blue" {
  metadata {
    name      = "blue-index"
    namespace = kubernetes_namespace.nginx.metadata[0].name
  }

  data = {
    "index.html" = "<html><body style='background:blue'><h1>BLUE NGINX</h1></body></html>"
  }
}

# RED Deployment
resource "kubernetes_deployment" "red" {
  metadata {
    name      = "nginx-red"
    namespace = kubernetes_namespace.nginx.metadata[0].name
  }

  spec {
    replicas = 1
    selector {
      match_labels = { app = "nginx-red" }
    }
    template {
      metadata {
        labels = { app = "nginx-red" }
      }
      spec {
        container {
          name  = "nginx"
          image = "nginx"
          port {
            container_port = 80
          }
          volume_mount {
            name       = "html"
            mount_path = "/usr/share/nginx/html/index.html"
            sub_path   = "index.html"
          }
        }
        volume {
          name = "html"
          config_map {
            name = kubernetes_config_map.red.metadata[0].name
          }
        }
      }
    }
  }
}

# BLUE Deployment
resource "kubernetes_deployment" "blue" {
  metadata {
    name      = "nginx-blue"
    namespace = kubernetes_namespace.nginx.metadata[0].name
  }

  spec {
    replicas = 1
    selector {
      match_labels = { app = "nginx-blue" }
    }
    template {
      metadata {
        labels = { app = "nginx-blue" }
      }
      spec {
        container {
          name  = "nginx"
          image = "nginx"
          port {
            container_port = 80
          }
          volume_mount {
            name       = "html"
            mount_path = "/usr/share/nginx/html/index.html"
            sub_path   = "index.html"
          }
        }
        volume {
          name = "html"
          config_map {
            name = kubernetes_config_map.blue.metadata[0].name
          }
        }
      }
    }
  }
}

# RED Service
resource "kubernetes_service" "red" {
  metadata {
    name      = "nginx-red-svc"
    namespace = kubernetes_namespace.nginx.metadata[0].name
  }

  spec {
    selector = { app = "nginx-red" }
    port {
      port        = 80
      target_port = 80
    }
  }
}

# BLUE Service
resource "kubernetes_service" "blue" {
  metadata {
    name      = "nginx-blue-svc"
    namespace = kubernetes_namespace.nginx.metadata[0].name
  }

  spec {
    selector = { app = "nginx-blue" }
    port {
      port        = 80
      target_port = 80
    }
  }
}

# NGINX Proxy ConfigMap
resource "kubernetes_config_map" "proxy_conf" {
  metadata {
    name      = "nginx-proxy-conf"
    namespace = kubernetes_namespace.nginx.metadata[0].name
  }

  data = {
    "nginx.conf" = <<-EOT
      worker_processes 1;
      events { worker_connections 1024; }
      http {
        upstream backend {
          server nginx-red-svc:80;
          server nginx-blue-svc:80;
        }
        server {
          listen 80;
          location / {
            proxy_pass http://backend;
          }
        }
      }
    EOT
  }
}

# NGINX Proxy Deployment
resource "kubernetes_deployment" "proxy" {
  metadata {
    name      = "nginx-proxy"
    namespace = kubernetes_namespace.nginx.metadata[0].name
  }

  spec {
    replicas = 1
    selector {
      match_labels = { app = "nginx-proxy" }
    }
    template {
      metadata {
        labels = { app = "nginx-proxy" }
      }
      spec {
        container {
          name  = "nginx"
          image = "nginx"
          port {
            container_port = 80
          }
          volume_mount {
            name       = "conf"
            mount_path = "/etc/nginx/nginx.conf"
            sub_path   = "nginx.conf"
          }
        }
        volume {
          name = "conf"
          config_map {
            name = kubernetes_config_map.proxy_conf.metadata[0].name
          }
        }
      }
    }
  }
}

# Proxy Service
resource "kubernetes_service" "proxy" {
  metadata {
    name      = "nginx-proxy-svc"
    namespace = kubernetes_namespace.nginx.metadata[0].name
  }

  spec {
    selector = { app = "nginx-proxy" }
    port {
      port        = 80
      target_port = 80
    }
  }
}

# Ingress
resource "kubernetes_ingress_v1" "nginx" {
  metadata {
    name      = "nginx-ingress"
    namespace = kubernetes_namespace.nginx.metadata[0].name
    annotations = {
      "nginx.ingress.kubernetes.io/load-balance" = "round_robin"
    }
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.proxy.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
