variable "github_username" {
  description = "GitHub username for Jenkins and Argo CD"
  type        = string
  default     = "andreydos"
}

variable "github_token" {
  description = "GitHub PAT with repository read and write access. Do not commit this value."
  type        = string
  sensitive   = true
}

variable "git_repo_url" {
  description = "HTTPS URL of the Git repository that contains the Jenkinsfile and the Helm chart"
  type        = string
  default     = "https://github.com/andreydos/docc.git"
}

variable "git_revision" {
  description = "Git branch that Jenkins pushes to and Argo CD watches"
  type        = string
  default     = "final-project"
}

variable "db_password" {
  description = "Password for the RDS admin user. Set it in terraform.tfvars and do not commit that file."
  type        = string
  sensitive   = true
}
