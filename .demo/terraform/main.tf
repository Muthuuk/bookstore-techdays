terraform {
  required_version = "~>0.14"

  # This allows us to utilize defaults and optional values on object variables
  experiments = [module_variable_optional_attrs]
}

#
# backend is dynamically generated and injected by terragrunt
#


module "azure" {
  source = "./modules/azure"

  azure_context         = var.cloud_context.azure
  azure_resource_suffix = "${var.github_context.target_repository.owner}-${var.github_context.target_repository.repo}"
}


module "github" {
  source = "./modules/github"

  github_token        = var.github_token
  actor               = var.github_context.actor
  template_repository = var.github_context.template_repository
  target_repository   = var.github_context.target_repository
  create_project = var.github_context.project != null ? var.github_context.project.create : false

  azure = {
    service_plan_name   = module.azure.bookstore_service_plan_name
    resource_group_name = module.azure.bookstore_resource_group_name
  }
}


output "repository_url" {
  value       = module.github.repository_url
  description = "GitHub repository URL"
}

output "repository_full_name" {
  value       = module.github.repository_full_name
  description = "GitHub repository full name"
}