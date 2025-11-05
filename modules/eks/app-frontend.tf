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
    replicas = 1
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
          image = "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/capstone-proshop-frontend:latest"
          port {
            container_port = 80
          }

          # Frontend uses light Nginx/React static files, so we can keep resources low
          resources {
            requests = {
              cpu    = "50m" # 0.05 core
              memory = "128Mi"
            }
            limits = {
              cpu    = "150m" # 0.15 core
              memory = "256Mi"
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

    min_replicas = 1
    max_replicas = 3

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
