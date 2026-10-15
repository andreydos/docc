variable "name" {
  description = "Назва Helm-релізу Argo CD"
  type        = string
  default     = "argocd"
}

variable "namespace" {
  description = "Namespace Argo CD"
  type        = string
  default     = "argocd"
}

variable "chart_version" {
  description = "Версія чарта Argo CD"
  type        = string
  default     = "5.46.4"
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
  description = "HTTPS URL Git-репозиторію з Helm-чартом"
  type        = string
}

variable "git_revision" {
  description = "Гілка, за якою стежить Argo CD"
  type        = string
}

variable "chart_path" {
  description = "Шлях до Helm-чарта всередині репозиторію"
  type        = string
}
