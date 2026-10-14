output "endpoint" {
  description = "Адреса для підключення до бази"
  value       = var.use_aurora ? aws_rds_cluster.aurora[0].endpoint : aws_db_instance.standard[0].address
}

output "port" {
  description = "Порт бази"
  value       = local.db_port
}

output "db_name" {
  description = "Ім'я бази даних"
  value       = var.db_name
}

output "username" {
  description = "Ім'я адміністративного користувача"
  value       = var.username
}

output "engine" {
  description = "Рушій, з яким створено базу"
  value       = local.engine_name
}

output "security_group_id" {
  description = "ID Security Group бази"
  value       = aws_security_group.rds.id
}

output "subnet_group_name" {
  description = "Назва DB Subnet Group"
  value       = aws_db_subnet_group.default.name
}
