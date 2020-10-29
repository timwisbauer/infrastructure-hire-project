resource "kubernetes_deployment" "proxy" {
  metadata {
    name      = "proxy"
    namespace = local.k8s_service_account_namespace
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
          liveness_probe {
            http_get {
              path = "/test"
              port = 8081
            }

            initial_delay_seconds = 5
            period_seconds        = 3
          }

        }
      }
    }
  }
}

resource "kubernetes_service" "proxy" {
  metadata {
    name      = "proxy"
    namespace = local.k8s_service_account_namespace
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
    namespace = local.k8s_service_account_namespace
    annotations = {
      "kubernetes.io/ingress.class"           = "alb"
      "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
      "alb.ingress.kubernetes.io/target-type" = "ip"
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
}
