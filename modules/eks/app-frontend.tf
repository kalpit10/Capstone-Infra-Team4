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
