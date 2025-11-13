**Capstone: Cloud-Native E-Commerce Deployment on AWS (Infrastructure
Repository)**

**Team 4 --- DevOps-Focused Cloud Architecture Project**

**This repository contains the entire Infrastructure-as-Code (IaC) for
deploying the ProShop v2 MERN e-commerce application on a fully
automated production-grade AWS environment using:**

- **Terraform Modules**

- **Amazon EKS (Kubernetes)**

- **Amazon ECR (Container Registry)**

- **Application Load Balancer (Ingress Controller)**

- **GitHub Actions OIDC CI/CD**

- **AWS Secrets Manager + IRSA**

- **Horizontal Pod Autoscaling (HPA)**

- **CloudWatch Dashboards & Logs**

**This README explains everything in beginner-friendly language while
documenting each system, tool, module, and deployment process in
detail.**

**📁 Repository Structure**

```
CAPSTONE-INFRA-TEAM4
│
├── .github/workflows/
│ └── terraform.yml # CI pipeline: fmt, validate, plan on PRs
│
├── infra/
│ └── envs/
│ ├── dev/ # Development environment Terraform root
│ │ ├── main.tf
│ │ ├── dev.tfvars
│ │ ├── outputs.tf
│ │ ├── variables.tf
│ │ └── versions.tf
│ │
│ └── prod/ # Production environment Terraform root
│ ├── main.tf
│ ├── prod.tfvars
│ ├── outputs.tf
│ ├── variables.tf
│ └── versions.tf
│
├── modules/
│ ├── ecr/ # ECR (container registry) module
│ │ ├── main.tf
│ │ ├── outputs.tf
│ │ ├── variables.tf
│ │ └── versions.tf
│ │
│ ├── eks/ # Complete EKS cluster + apps module
│ │ ├── app-backend.tf
│ │ ├── app-frontend.tf
│ │ ├── data.tf
│ │ ├── helm-alb.tf # AWS Load Balancer Controller
│ │ ├── ingress.tf
│ │ ├── iam.tf
│ │ ├── main.tf
│ │ ├── outputs.tf
│ │ ├── variables.tf
│ │ └── versions.tf
│ │
│ ├── secrets/ # Secrets Manager → K8s secrets module
│ │ ├── main.tf
│ │ ├── outputs.tf
│ │ └── variables.tf
│ │
│ └── vpc/ # Networking module (VPC, Subnets, NAT)
│ ├── main.tf
│ ├── outputs.tf
│ ├── variables.tf
│ └── versions.tf
│
└── README.md # You are reading this!
```

**📦 1. Project Summary**

**This project deploys the ProShop v2 MERN application onto AWS using a
fully automated, production-ready cloud architecture.**

**🔧 Application Stack (unchanged in this repository)**

- **Frontend: React + Vite + Nginx (static site served by Nginx)**

- **Backend: Node.js + Express**

- **Database: MongoDB Atlas (cloud database)**

- **Payments: PayPal API (sandbox mode)**

**☁️ Cloud & DevOps Scope (what _this repo_ builds)**

- **Complete AWS networking (VPC, subnets, NAT, route tables)**

- **Amazon EKS (Kubernetes cluster + managed node group)**

- **AWS Load Balancer Controller (via Helm)**

- **Ingress routing (ALB → frontend + backend)**

- **AWS ECR for all container images**

- **GitHub OIDC authentication (no static AWS keys)**

- **Secrets Manager → Kubernetes Secrets → Pod env variables**

- **Horizontal Pod Autoscaling (CPU-based)**

- **CloudWatch Logs + Dashboards**

**🧰 2. Required Tools (Local Machine Setup)**

**All developers working on this project must install:**

**✔ Git**

**Version control & GitHub commits.**

**✔ AWS CLI**

**Authenticate and interact with AWS.  
Installation:
<https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html>**

**✔ Terraform**

**Used to build the entire cloud infrastructure.  
Installation: https://developer.hashicorp.com/terraform/downloads**

**✔ kubectl**

**CLI for interacting with the Kubernetes cluster.  
Installation: <https://kubernetes.io/docs/tasks/tools/>**

**✔ Helm**

**Required to install the AWS Load Balancer Controller & Metrics
Server.  
Installation: <https://helm.sh/docs/intro/install/>**

**✔ Docker**

**Only needed if you want to test images locally.**

**✔ Node.js + npm**

**Only needed for testing the app locally.**

**🏗 3. Architecture Overview**

**Below is the high-level architecture (explained simply):**

**Networking Layer (VPC Module)**

- **One VPC per environment (dev, prod)**

- **6 subnets:**

  - **2 Public (ALB + NAT)**

  - **2 Private-Frontend**

  - **2 Private-Backend**

- **Internet Gateway (public)**

- **NAT Gateway (private)**

- **Separate route tables**

- **Strict security groups**

**ECR (Container Registry Module)**

- **Stores 3 container images:**

  - **frontend**

  - **backend**

  - **nginx**

- **Dev and Prod use separate ECR repos**

- **Image scanning + lifecycle policies enabled**

**EKS (Kubernetes Cluster Module)**

**Inside private subnets:**

- **EKS Control Plane (managed)**

- **Managed node group**

- **OIDC provider for IRSA**

- **AWS Load Balancer Controller via Helm**

- **Metrics Server via Helm**

**Application Deployment**

**Terraform deploys:**

- **Backend Deployment + Service (ClusterIP)**

- **Frontend Deployment + Service (ClusterIP)**

- **Ingress:**

  - **/api/\* → backend**

  - **/ → frontend**

**Secrets Management**

- **Secrets stored in AWS Secrets Manager**

- **Terraform loads them and creates Kubernetes Secrets**

- **Backend pods get secrets securely**

- **IRSA gives the backend pod permission to read only its secret**

**Autoscaling**

- **Horizontal Pod Autoscalers for:**

  - **Frontend**

  - **Backend**

- **CPU-based scaling**

**Monitoring**

- **CloudWatch Logs for:**

  - **EKS control plane**

  - **Application logs**

- **CloudWatch Dashboard for cluster & ALB metrics**

**🧩 4. How Terraform Is Organized (Modules)**

**4.1 VPC Module**

**Creates:**

- **VPC**

- **Subnets**

- **IGW + NAT**

- **Route tables**

- **Security groups**

**All parameters come from tfvars (one file per environment).**

**4.2 ECR Module**

**Creates multiple repositories using a list input:**

- **AES256 encryption**

- **Image scanning enabled**

- **Lifecycle policy to clean old images**

- **Tags for tracking project & environment**

**4.3 EKS Module**

**This is the largest module and contains:**

**☑ Cluster & Node Group**

- **Private subnets**

- **Dynamic scaling (dev vs prod)**

- **No hard-coded account IDs (uses aws_caller_identity)**

**☑ IAM & IRSA**

- **Roles for:**

  - **EKS**

  - **Worker nodes**

  - **Load Balancer Controller**

  - **Backend pods to read secrets**

**☑ Helm Installations**

- **Load Balancer Controller**

- **Metrics Server**

**☑ Kubernetes Deployments**

- **Backend deployment**

- **Frontend deployment**

- **Services**

- **Ingress routing**

**☑ Autoscaling**

- **Horizontal Pod Autoscalers**

- **CPU target values read from tfvars**

**4.4 Secrets Module**

**Handles:**

- **Reading values from AWS Secrets Manager**

- **Decoding JSON**

- **Creating Kubernetes Secrets**

- **Creating service accounts with IRSA roles**

- **Injecting env vars into backend pods**

**🌍 5. Environments**

**This repository supports two separate, isolated environments:**

**✔ Development (infra/envs/dev)**

- **Smaller instance sizes**

- **Fewer replicas**

- **Mutable ECR tags**

- **Cheaper for testing**

**✔ Production (infra/envs/prod)**

- **Separate VPC CIDR range**

- **Larger node groups**

- **Immutable image tags**

- **Unique ALB names**

- **Separate secrets**

**Each environment is deployed independently with its own S3 state
file + DynamoDB lock.**

**🔐 6. Secrets & Security**

**✔ No secrets are stored in Terraform files**

**Everything sensitive lives in AWS Secrets Manager.**

**✔ Terraform reads secrets securely**

**Then converts them into Kubernetes Secrets.**

**✔ Backend pods retrieve secrets at runtime**

**A Kubernetes service account with IRSA is used.**

**✔ RBAC & IAM least privilege**

- **Dev pods can only access dev secrets**

- **Prod pods can only access prod secrets**

**🚀 7. CI/CD (GitHub Actions)**

**The WebApp repo contains:**

- **A workflow that:**

  - **Builds Docker images**

  - **Uses GitHub → AWS OIDC authentication**

  - **Pushes images to ECR (dev, prod, or both)**

  - **Tags every image with:**

    - **Commit SHA**

    - **latest**

**The Infra repo contains:**

- **A Terraform validation pipeline:**

  - **terraform fmt**

  - **terraform validate**

  - **terraform plan**

- **Runs automatically on pull requests**

- **Uses OIDC as well**

- **No long-lived AWS access keys**

**☸️ 8. Connecting to the EKS Cluster**

**After apply:**

**aws eks update-kubeconfig \--region us-east-1 \--name
capstone-proshop-eks-prod**

**kubectl get nodes**

**kubectl get pods -A**

**Everything should be running:**

- **ALB Controller**

- **Metrics Server**

- **Frontend pods**

- **Backend pods**

- **Ingress**

**🌐 9. Accessing the Deployed Application**

**Retrieve the ALB DNS:**

**kubectl get ingress -n proshop**

**Open the DNS in your browser.**

**The app should fully work:**

- **Login / Register**

- **Product browsing**

- **Add to cart**

- **Checkout using PayPal Sandbox**

**📉 10. Autoscaling (HPA)**

**HPAs monitor CPU usage.**

**To observe scaling:**

**kubectl get hpa -n proshop**

**kubectl get pods -n proshop**

**Under load:**

- **Frontend scales from 2 → 6 pods**

- **Backend scales from 2 → 6 pods**

**This ensures high availability and low latency.**

**📊 11. Monitoring & Logs**

**Enabled components:**

- **CloudWatch Logs for:**

  - **App logs**

  - **EKS control plane**

- **CloudWatch Dashboards for:**

  - **Cluster CPU**

  - **ALB requests**

  - **Pod usage**

  - **HPA activity**

**You can extend this with:**

- **Prometheus + Grafana (future improvement)**

- **Alarms (CPU, 5xx errors)**

**🧹 12. Cleanup**

**Destroy environment:**

**terraform destroy -var-file=\"prod.tfvars\"**

**Deletes:**

- **VPC**

- **EKS**

- **ALB**

- **IAM roles**

- **All Kubernetes resources**

**ECR repositories remain safely intact unless explicitly destroyed.**

**📌 13. Future Enhancements**

**Optional improvements:**

- **Route 53 + HTTPS (ACM certificates)**

- **Prometheus & Grafana monitoring stack**

- **Cluster Autoscaler**

- **Argo CD (GitOps)**

- **Velero backups**

- **Multiple node groups (frontend vs backend)**

- **Cost optimization via Karpenter**

**🏁 14. Summary**

**This repository builds a real-world, production-grade cloud
architecture using Terraform modules and Kubernetes on AWS.**

**You learned how to:**

- **Design multi-environment networking**

- **Containerize and deploy microservices**

- **Use ECR, EKS, ALB, IRSA, Secrets Manager**

- **Automate deployments with GitHub Actions**

- **Implement HPA for auto-scaling**

- **Monitor workloads with CloudWatch**

**The entire infrastructure is modular, reusable, secure, scalable, and
fully automated.**
