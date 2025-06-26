provider "kubernetes" {
  config_path = "~/.kube/config"
}

# Create Namespace
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
        labels = {
          app = "nginx-red"
          service = "nginx-loadbalanced"
        }
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
        labels = {
          app = "nginx-blue"
          service = "nginx-loadbalanced"
        }
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

# Load Balanced Service (selects both red and blue pods)
resource "kubernetes_service" "loadbalanced" {
  metadata {
    name      = "nginx-loadbalanced-svc"
    namespace = kubernetes_namespace.nginx.metadata[0].name
  }

  spec {
    selector = { service = "nginx-loadbalanced" }
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
              name = kubernetes_service.loadbalanced.metadata[0].name
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
