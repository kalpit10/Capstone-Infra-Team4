###############################################
# BACKEND NAMESPACE
###############################################
resource "kubernetes_namespace" "proshop" {
  metadata {
    name = "proshop"
  }

}


# Read existing secret from AWS Secrets Manager
data "aws_secretsmanager_secret_version" "backend" {
  secret_id = var.backend_secret_id
}


# Decode JSON into a Terraform map
# What's a terraform map? It's a collection of key-value pairs in json format.
locals {
  backend_secrets = jsondecode(data.aws_secretsmanager_secret_version.backend.secret_string)
}

# Convert AWS Secrets Manager data into a Kubernetes Secret
# It's data comes directly from Secrets Manager (still encrypted at rest inside the cluster).
resource "kubernetes_secret" "backend_env" {
  metadata {
    name      = "backend-secrets"
    namespace = kubernetes_namespace.proshop.metadata[0].name
  }

  data = {
    PORT              = local.backend_secrets["PORT"]
    MONGO_URI         = local.backend_secrets["MONGO_URI"]
    JWT_SECRET        = local.backend_secrets["JWT_SECRET"]
    PAYPAL_CLIENT_ID  = local.backend_secrets["PAYPAL_CLIENT_ID"]
    PAYPAL_APP_SECRET = local.backend_secrets["PAYPAL_APP_SECRET"]
    PAYPAL_API_URL    = local.backend_secrets["PAYPAL_API_URL"]
    PAGINATION_LIMIT  = local.backend_secrets["PAGINATION_LIMIT"]
    NODE_ENV          = local.backend_secrets["NODE_ENV"]
  }

  # type Opaque means the secret data is stored in base64-encoded format.
  type = "Opaque"
}

###############################################
# BACKEND SERVICE ACCOUNT WITH IRSA
# This service account allows backend pods to assume an IAM role via OIDC
###############################################

resource "kubernetes_service_account" "backend_sa" {
  metadata {
    name      = "backend-sa"
    namespace = kubernetes_namespace.proshop.metadata[0].name
    # Annotation to link the service account to the IAM role for IRSA
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.backend_irsa_role.arn
    }
  }
}


###############################################
# BACKEND DEPLOYMENT
# Deploys Pod(s) for the backend application
###############################################
resource "kubernetes_deployment" "backend" {
  metadata {
    name      = "backend-deployment"
    namespace = kubernetes_namespace.proshop.metadata[0].name
    labels = {
      app = "backend"
    }

  }
  depends_on = [
    kubernetes_service_account.backend_sa,
    kubernetes_secret.backend_env
  ]


  # Spec is the specification of the desired behavior of the deployment
  spec {
    # Requesting 1 replica of the backend pod in development environment.
    replicas = var.backend_replicas
    # Selector is used to identify the pods managed by this deployment
    selector {
      match_labels = {
        app = "backend"
      }
    }

    # Template describes the pods that will be created
    template {
      metadata {
        labels = {
          app = "backend"
        }
      }

      spec {
        # That ensures the pod runs with the IAM role that can access Secrets Manager (if you ever refresh secrets directly).
        service_account_name = kubernetes_service_account.backend_sa.metadata[0].name
        # This step defines the container that will run in the pod
        container {
          name = "backend"
          # ECR backend image that we pushed earlier is going to be used to run this backend container.
          image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.backend_image_repo}:latest"


          port {
            container_port = 5000
          }

          # Injecting secrets from the Kubernetes secret into the backend container as environment variables.
          env_from {
            # This block references the Kubernetes secret we created earlier.
            # It will inject all key-value pairs from that secret as environment variables into the container.
            secret_ref {
              name = kubernetes_secret.backend_env.metadata[0].name
            }
          }

          # Resource definitions for the backend container for resource management.
          resources {
            # requests define the minimum resources required for the container to run
            requests = {
              cpu    = var.backend_cpu_request # minimum CPU the pod expects (0.1 core or 0.1vCPU)
              memory = var.backend_mem_request # minimum memory the pod expects (Mi is Mebibytes => 1Mi = 1.048576 MB)
            }
            # limits define the maximum resources the container can use
            limits = {
              cpu    = var.backend_cpu_limit # maximum CPU the pod can use (0.25 core or 0.25vCPU)
              memory = var.backend_mem_limit # maximum memory the pod can use (Mi is Mebibytes => 1Mi = 1.048576 MB)
            }

          }
        }
      }
    }
  }
}

###############################################
# BACKEND HPA ( Horizontal Pod Autoscaler )
# This HPA automatically scales the number of backend pods based on CPU utilization
###############################################

resource "kubernetes_horizontal_pod_autoscaler_v2" "backend_hpa" {
  metadata {
    name      = "backend-hpa"
    namespace = "proshop"
  }

  spec {
    # What is Scale Target Ref? It specifies the target resource (deployment) that the HPA will monitor and scale.
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment.backend.metadata[0].name
    }

    min_replicas = var.backend_hpa_min
    max_replicas = var.backend_hpa_max

    # This block defines the metric based on which the HPA will scale the backend deployment
    metric {
      type = "Resource"

      resource {
        # Specifies that we are scaling based on CPU utilization
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = 70
        }
      }
    }
  }
}



###############################################
# BACKEND SERVICE
# Backend service to expose the backend deployment within the cluster
# Why is this needed? Because it allows other pods (like the frontend) to communicate with the backend via a stable IP and DNS name.
###############################################
resource "kubernetes_service" "backend" {
  metadata {
    name      = "backend-service"
    namespace = kubernetes_namespace.proshop.metadata[0].name
  }

  spec {
    selector = {
      app = "backend"
    }

    # Exposes port 5000 of the backend pods
    # First port is the port that the service will listen on
    # Second port is the port on the pod that the service will forward traffic to
    port {
      port        = 5000
      target_port = 5000
    }

    # ClusterIP is the default service type, which exposes the service on a cluster-internal IP.
    # What is ClusterIP? It means the service is only reachable from within the cluster.
    # We need ClusterIP because the frontend will communicate with the backend internally.
    type = "ClusterIP"
  }
}
