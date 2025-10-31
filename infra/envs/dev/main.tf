module "vpc" {
  source = "../../../modules/vpc"
}


module "ecr" {
  source = "../../../modules/ecr"

  repo_names = ["capstone-proshop-frontend", "capstone-proshop-backend", "capstone-proshop-nginx"]

  // Image Scanning for vulnerabilities on push
  image_scan = true
  // Why did we choose AES256? Because it's a widely used encryption standard that provides a good balance between security and performance.
  // KMS would be more secure but adds complexity and cost.
  encryption_type = "AES256"

  // Mutable means you can overwrite tags, Immutable means you cannot
  // An image tag is a mutable reference to an image 
  image_tag_mutability = "MUTABLE"
  lifecycle_policy     = file("${path.module}/ecr_lifecycle.json")

  tags = {
    Project     = "Capstone-Proshop-v2"
    Environment = "dev"
  }
}


module "eks" {
  source       = "../../../modules/eks"
  cluster_name = "capstone-proshop-eks"

  # We keep the EKS cluster in private frontend subnets because we don't want to expose the cluster to the internet directly.
  subnet_ids = module.vpc.private_frontend_subnet_ids
  vpc_id     = module.vpc.vpc_id
  account_id = "452940498021"
}

module "secrets" {
  source = "../../../modules/secrets"
}
