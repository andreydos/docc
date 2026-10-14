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

output "db_endpoint" {
  description = "Адреса для підключення до бази"
  value       = module.rds.endpoint
}

output "db_port" {
  description = "Порт бази"
  value       = module.rds.port
}

output "db_name" {
  description = "Ім'я бази даних"
  value       = module.rds.db_name
}

output "db_engine" {
  description = "Рушій бази"
  value       = module.rds.engine
}
