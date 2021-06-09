terraform {
  required_version = "~>0.14"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~>4.5.1"
    }
  }
}


provider "github" {
  token        = var.github_token
  organization = var.target_repository.owner
}


resource "github_repository" "repository" {
  name                   = var.target_repository.repo
  description            = "Bookstore demo repository for @${var.actor}"
  visibility             = "private"
  has_issues             = true
  has_projects           = var.create_project
  delete_branch_on_merge = true
  vulnerability_alerts   = true
  template {
    owner = var.template_repository.owner
    repository = var.template_repository.repo
  }
}

resource "github_issue_label" "deploy_to_qa" {
  repository  = github_repository.repository.name
  name        = "deploy to qa"
  description = "Trigger a deploy event targeting the qa environment"
  color       = "5755f2"
}

resource "github_issue_label" "deploy_to_staging" {
  repository  = github_repository.repository.name
  name        = "deploy to staging"
  description = "Trigger a deploy event targeting the staging environment"
  color       = "1dad00"
}

resource "github_issue_label" "deploy_to_test" {
  repository  = github_repository.repository.name
  name        = "deploy to test"
  description = "Trigger a deploy event targeting the test environment"
  color       = "7d5c01"
}

resource "github_actions_secret" "azure_app_plan" {
  repository      = github_repository.repository.name
  secret_name     = "AZURE_APP_PLAN_NAME"
  plaintext_value = var.azure.service_plan_name
}

resource "github_actions_secret" "azure_resource_group" {
  repository      = github_repository.repository.name
  secret_name     = "AZURE_RESOURCE_GROUP_NAME"
  plaintext_value = var.azure.resource_group_name
}

resource "github_branch_protection" "protect_default_branch" {
  repository_id  = github_repository.repository.node_id
  pattern        = "main"
  enforce_admins = false

  required_status_checks {
    strict = false
    # The following is tied into the workflow actions for the builds in the base template repository
    contexts = ["Build (ubuntu-20.04, 11)"]
  }
  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    required_approving_review_count = 1
  }
}


output "repository_url" {
  value       = github_repository.repository.html_url
  description = "The HTML URL for the newly created repository"
}

output "repository_full_name" {
  value       = github_repository.repository.full_name
  description = "The name for the newly created repository in 'owner/repo_name' form"
}
