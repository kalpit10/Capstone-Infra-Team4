# Optional: output specific values to feed into other Terraform code
# (safe to output because Terraform will not print plaintext unless you explicitly display it)
output "backend_secret_arn" {
  value = data.aws_secretsmanager_secret_version.backend.arn
}

# Expose the keys of the secrets for use in other modules
output "backend_secret_values" {
  value     = keys(local.backend_secrets)
  sensitive = true
}
