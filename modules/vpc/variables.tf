variable "subnets" {
  description = "Subnet definitions for the VPC"
  type = map(object({
    cidr = string
    az   = string
    tier = string # public | private-frontend | private-backend
  }))

  default = {
    public-a = {
      cidr = "10.0.1.0/24"
      az   = "us-east-1a"
      tier = "public"
    }
    public-b = {
      cidr = "10.0.2.0/24"
      az   = "us-east-1b"
      tier = "public"
    }
    private-frontend-a = {
      cidr = "10.0.11.0/24"
      az   = "us-east-1a"
      tier = "private-frontend"
    }
    private-frontend-b = {
      cidr = "10.0.12.0/24"
      az   = "us-east-1b"
      tier = "private-frontend"
    }
    private-backend-a = {
      cidr = "10.0.21.0/24"
      az   = "us-east-1a"
      tier = "private-backend"
    }
    private-backend-b = {
      cidr = "10.0.22.0/24"
      az   = "us-east-1b"
      tier = "private-backend"
    }
  }
}

variable "env" {
  description = "Environment name (dev, prod, etc.)"
  type        = string
  default     = "dev"
}

variable "name_prefix" {
  description = "Prefix to add in front of all resource names"
  type        = string
  default     = "capstone-team4"
}
