variable "ecr_name" {
  description = "ECR repository name"
  type        = string
}

variable "scan_on_push" {
  description = "Scan images when they are pushed"
  type        = bool
}
