variable "backend_secret_name" {
  type        = string
  default     = "proshop/backend"
  description = "Name of the AWS Secrets Manager secret containing backend env vars"
}
