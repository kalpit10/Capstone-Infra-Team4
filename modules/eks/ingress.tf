###############################################
# INGRESS RESOURCE - AWS ALB CONTROLLER
# What is an Ingress Resource? 
# An Ingress Resource in Kubernetes is a set of rules for the inbound traffic to reach your services. It provides HTTP and HTTPS routing to services based on defined rules.
# This file will create an Ingress resource that will create a load balancer in front of our services.
# The ALB created will route traffic to the appropriate services based on the rules defined in the Ingress resource.
# It routes traffic from ALB → Kubernetes Service → Pods.
# Here, Service is of type ClusterIP, which is only accessible within the cluster.
###############################################

// We will register backend and frontend services as target groups.

resource "kubernetes_ingress_v1" "proshop_ingress" {
  metadata {
    name      = "proshop-ingress"
    namespace = "proshop"

    # Annotations define specific configurations for the ALB
    // What is an annotation? It is a key-value pair which has a job of adding metadata to Kubernetes objects.
    // What is a Kubernetes object? It is any resource in Kubernetes like Pod, Service, Ingress, etc.
    annotations = {
      # Required by AWS Load Balancer Controller
      "kubernetes.io/ingress.class"                  = "alb"
      "alb.ingress.kubernetes.io/scheme"             = "internet-facing" // Makes the ALB public
      "alb.ingress.kubernetes.io/target-type"        = "ip"              // Targets are pods (IP addresses)
      "alb.ingress.kubernetes.io/load-balancer-name" = "proshop-alb"
      "alb.ingress.kubernetes.io/listen-ports"       = "[{\"HTTP\":80}]" // Listens on port 80 for HTTP
      "alb.ingress.kubernetes.io/healthcheck-path"   = "/"               // Health check path
    }
  }

  # This step will create rules for routing traffic to the backend and frontend services using path-based routing
  spec {
    // Here, we mention /api/ first because path matching is done in order. If we put / first, it would match all paths and /api/ would never be reached.
    rule {
      http {
        // Any request starting with /api/ — for example /api/products, /api/users — gets forwarded to the backend-service, which listens on port 5000.
        path {
          path      = "/api/"
          path_type = "Prefix"

          // Routes traffic to backend-service on port 5000
          backend {
            service {
              name = "backend-service"
              port {
                number = 5000
              }
            }
          }
        }

        // Routes traffic to frontend-service on port 80
        // Any other path (/, /home, /about) goes to the frontend-service (port 80). The frontend will serve React's static files (like index.html, JS bundles, etc.).
        path {
          path      = "/"
          path_type = "Prefix"
          // The keyword "backend" here refers to the backend of the Ingress resource, not the backend service of our application. It's naming convention in Kubernetes Ingress.
          backend {
            service {
              name = "frontend-service"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    helm_release.alb_controller,
    kubernetes_service.backend,
    kubernetes_service.frontend
  ]
}
