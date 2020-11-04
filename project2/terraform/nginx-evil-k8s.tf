###########
# Kubernetes resources for nginx app.
###########

resource "kubernetes_deployment" "nginx" {
  metadata {
    name      = "nginx"
    namespace = local.k8s_service_account_namespace
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }

      spec {
        container {
          image = "nginx"
          name  = "nginx"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nginx" {
  metadata {
    name      = "nginx"
    namespace = local.k8s_service_account_namespace
  }

  spec {
    type = "ClusterIP"
    selector = {
      app = "nginx"
    }
    port {
      port        = 80
      target_port = 80
    }

  }
}
