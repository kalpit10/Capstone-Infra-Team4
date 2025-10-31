# Reads the latest version of your existing AWS secret
data "aws_secretsmanager_secret_version" "backend" {
  secret_id = var.backend_secret_name
}

# Decode JSON so other modules can consume specific keys
locals {
  backend_secrets = jsondecode(data.aws_secretsmanager_secret_version.backend.secret_string)
}

