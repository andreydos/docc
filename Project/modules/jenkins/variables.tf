variable "cluster_name" {
  description = "Назва EKS-кластера"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN OIDC-провайдера EKS"
  type        = string
}

variable "oidc_provider_url" {
  description = "URL OIDC-провайдера EKS"
  type        = string
}

variable "ecr_repository_arn" {
  description = "ARN ECR-репозиторію, куди Kaniko пушить образ"
  type        = string
}

variable "github_username" {
  description = "GitHub username"
  type        = string
}

variable "github_token" {
  description = "GitHub PAT"
  type        = string
  sensitive   = true
}

variable "git_repo_url" {
  description = "HTTPS URL Git-репозиторію"
  type        = string
}

variable "git_revision" {
  description = "Гілка, яку читає і оновлює Jenkins"
  type        = string
}
