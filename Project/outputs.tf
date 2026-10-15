output "s3_bucket_name" {
  description = "Назва S3-бакета для стейтів"
  value       = module.s3_backend.s3_bucket_name
}

output "dynamodb_table_name" {
  description = "Назва таблиці DynamoDB для блокування стейтів"
  value       = module.s3_backend.dynamodb_table_name
}

output "vpc_id" {
  description = "ID VPC"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "ID публічних підмереж"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "ID приватних підмереж"
  value       = module.vpc.private_subnets
}

output "ecr_repository_url" {
  description = "URL ECR-репозиторію"
  value       = module.ecr.repository_url
}

output "eks_cluster_name" {
  description = "Назва EKS-кластера"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "API endpoint EKS-кластера"
  value       = module.eks.cluster_endpoint
}

output "db_endpoint" {
  description = "Адреса RDS"
  value       = module.rds.endpoint
}

output "db_port" {
  description = "Порт RDS"
  value       = module.rds.port
}

output "db_name" {
  description = "Ім'я бази"
  value       = module.rds.db_name
}

output "jenkins_namespace" {
  description = "Namespace Jenkins"
  value       = module.jenkins.jenkins_namespace
}

output "argo_cd_namespace" {
  description = "Namespace Argo CD"
  value       = module.argo_cd.namespace
}

output "argo_cd_server_service" {
  description = "Service Argo CD server"
  value       = module.argo_cd.server_service
}

output "monitoring_namespace" {
  description = "Namespace Prometheus і Grafana"
  value       = module.monitoring.namespace
}
