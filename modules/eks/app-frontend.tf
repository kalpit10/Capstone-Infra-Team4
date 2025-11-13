###############################################
# FRONTEND DEPLOYMENT
###############################################
resource "kubernetes_deployment" "frontend" {
  metadata {
    name      = "frontend-deployment"
    namespace = "proshop"
    labels = {
      app = "frontend"
    }
  }

  spec {
    replicas = var.frontend_replicas

    selector {
      match_labels = {
        app = "frontend"
      }
    }

    template {
      metadata {
        labels = {
          app = "frontend"
        }
      }

      spec {
        container {
          name  = "frontend"
          image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.frontend_image_repo}:latest"
          port {
            container_port = 80
          }

          # Frontend uses light Nginx/React static files, so we can keep resources low
          resources {
            requests = {
              cpu    = var.frontend_cpu_request # 0.05 core
              memory = var.frontend_mem_request
            }
            limits = {
              cpu    = var.frontend_cpu_limit # 0.15 core
              memory = var.frontend_mem_limit
            }
          }
        }
      }
    }
  }

}

###############################################
# FRONTEND HPA ( Horizontal Pod Autoscaler )
###############################################

resource "kubernetes_horizontal_pod_autoscaler_v2" "frontend_hpa" {
  metadata {
    name      = "frontend-hpa"
    namespace = "proshop"
  }

  spec {
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment.frontend.metadata[0].name
    }

    min_replicas = var.frontend_hpa_min
    max_replicas = var.frontend_hpa_max

    metric {
      type = "Resource"

      resource {
        name = "cpu"

        target {
          type                = "Utilization"
          average_utilization = 60
        }
      }
    }
  }
}




###############################################
# FRONTEND SERVICE
############################################

resource "kubernetes_service" "frontend" {
  metadata {
    name      = "frontend-service"
    namespace = "proshop"
  }

  spec {
    selector = {
      app = "frontend"
    }

    type = "ClusterIP"

    port {
      port        = 80
      target_port = 80
    }
  }
}
