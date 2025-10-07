variable "repo_names" {
  description = "List of ECR repository names to create"
  type        = list(string)
}

variable "image_scan" {
  description = "Enable image scanning on push"
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "Encryption type for images (AES256 or KMS)"
  type        = string
  default     = "AES256"
}

variable "image_tag_mutability" {
  description = "Tag immutability setting (MUTABLE or IMMUTABLE)"
  type        = string
  default     = "MUTABLE"
}

variable "lifecycle_policy" {
  description = "Lifecycle policy JSON document"
  type        = string
}

variable "tags" {
  description = "Tags applied to all repositories"
  type        = map(string)
  default     = {}
}
