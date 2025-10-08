output "repository_names" {
  description = "List of all ECR repository names created by this module"
  value       = [for r in aws_ecr_repository.this : r.name]
}

output "repository_uris" {
  description = "Map of repository name to its URI"
  // e.g., { "my-repo" = "123456789012.dkr.ecr.us-west-2.amazonaws.com/my-repo" }
  value = { for r in aws_ecr_repository.this : r.name => r.repository_url }
}
