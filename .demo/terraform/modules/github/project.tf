#
# Optional project resource for demo repository
#

locals {
  project_count = var.create_project ? 1 : 0
}

resource "github_repository_project" "project" {
  count      = local.project_count
  name       = "Features Roadmap"
  repository = github_repository.repository.name
  body       = "Project board for our feature development team."
}

resource "github_project_column" "to_do" {
  count      = local.project_count
  project_id = github_repository_project.project[0].id
  name       = "To do"
}

resource "github_project_column" "in_progress" {
  count      = local.project_count
  project_id = github_repository_project.project[0].id
  name       = "In progress"

  depends_on = [
    github_project_column.to_do
  ]
}

resource "github_project_column" "done" {
  count      = local.project_count
  project_id = github_repository_project.project[0].id
  name       = "Done"

  depends_on = [
    github_project_column.in_progress
  ]
}