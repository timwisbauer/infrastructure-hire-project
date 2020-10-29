resource "kubernetes_config_map" "s3_vulns_location" {
  metadata {
    name = "s3-vulns-location"
  }

  data = {
    S3_BUCKET_NAME = aws_s3_bucket.vulns_bucket.id
    S3_OBJECT_KEY  = aws_s3_bucket_object.vulns_file.key
  }
}

resource "kubernetes_deployment" "vulns_app" {
  metadata {
    name      = "vulns-app"
    namespace = local.k8s_service_account_namespace
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "vulns-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "vulns-app"
        }
      }

      spec {
        service_account_name = "vulns-app-s3"
        security_context {
          fs_group = "65534"
        }
        container {
          image = aws_ecr_repository.vulns_app.repository_url
          name  = "vulns-app"
                  port {
                     container_port = 8080
                   }
          env {
            name  = "S3_BUCKET_NAME"
            value = aws_s3_bucket.vulns_bucket.id
          }
          env {
            name  = "S3_OBJECT_KEY"
            value = aws_s3_bucket_object.vulns_file.key
          }

        }
      }
    }
  }
}

resource "kubernetes_service" "vulns_app" {
  metadata {
    name      = "vulns-app"
    namespace = "vulns-app"
  }

  spec {
    type = "ClusterIP"
    selector = {
      app = "vulns-app"
    }
    port {
      port        = 80
      target_port = 8080
    }

  }
}