module "vpc" {
  source = "../../../modules/vpc"
}


module "ecr" {
  source = "../../../modules/ecr"

  repo_names = ["capstone-proshop-frontend", "capstone-proshop-backend", "capstone-proshop-nginx"]

  // Image Scanning for vulnerabilities on push
  image_scan      = true
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
