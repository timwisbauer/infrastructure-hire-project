###########
# Kubernetes resources for proxy app.
###########

resource "kubernetes_deployment" "proxy" {
  metadata {
    name      = "proxy"
    namespace = kubernetes_namespace.vulns-app.id
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "proxy"
      }
    }

    template {
      metadata {
        labels = {
          app = "proxy"
        }
      }

      spec {
        container {
          image = aws_ecr_repository.proxy.repository_url
          name  = "proxy"
          port {
            container_port = 8081
          }
          readiness_probe {
            http_get {
              path = "/test"
              port = 8081
            }

            initial_delay_seconds = 5
            period_seconds        = 3
          }
          resources {
            limits {
              memory = "512Mi"
            }
            requests {
              memory = "512Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "proxy" {
  metadata {
    name      = "proxy"
    namespace = kubernetes_namespace.vulns-app.id
  }

  spec {
    type = "ClusterIP"
    selector = {
      app = "proxy"
    }
    port {
      port        = 80
      target_port = 8081
    }

  }
}

resource "kubernetes_ingress" "proxy" {
  metadata {
    name      = "proxy"
    namespace = kubernetes_namespace.vulns-app.id
    annotations = {
      "kubernetes.io/ingress.class"                = "alb"
      "alb.ingress.kubernetes.io/scheme"           = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"      = "ip"
      "alb.ingress.kubernetes.io/healthcheck-path" = "/test"
    }
  }

  spec {
    rule {
      http {
        path {
          path = "/*"
          backend {
            service_name = "proxy"
            service_port = "80"
          }
        }
      }
    }
  }
  wait_for_load_balancer = true
}

