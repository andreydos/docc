variable "db_password" {
  description = "Пароль користувача бази. Задайте його в terraform.tfvars і не комітьте цей файл."
  type        = string
  sensitive   = true
}
