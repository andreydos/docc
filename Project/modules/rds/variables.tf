variable "name" {
  description = "Назва інстансу RDS або кластера Aurora. Лише малі літери, цифри та дефіс."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,62}$", var.name))
    error_message = "name має починатися з літери і містити лише малі літери, цифри та дефіс (до 63 символів)."
  }
}

variable "use_aurora" {
  description = "true створює Aurora Cluster, false — звичайний інстанс RDS."
  type        = bool
  default     = false
}

variable "engine" {
  description = "Рушій звичайної RDS: postgres або mysql."
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "Версія рушія звичайної RDS. Має існувати в обраному регіоні AWS."
  type        = string
  default     = "17.11"
}

variable "parameter_group_family_rds" {
  description = "Сімейство parameter group для звичайної RDS. Має відповідати engine і engine_version, наприклад postgres17 або mysql8.4."
  type        = string
  default     = "postgres17"
}

variable "engine_cluster" {
  description = "Рушій Aurora: aurora-postgresql або aurora-mysql."
  type        = string
  default     = "aurora-postgresql"
}

variable "engine_version_cluster" {
  description = "Версія рушія Aurora. Має існувати в обраному регіоні AWS."
  type        = string
  default     = "17.11"
}

variable "parameter_group_family_aurora" {
  description = "Сімейство cluster parameter group для Aurora, наприклад aurora-postgresql17 або aurora-mysql8.4."
  type        = string
  default     = "aurora-postgresql17"
}

variable "aurora_instance_count" {
  description = "Кількість інстансів Aurora. Перший стає writer, решта — reader. Мінімум 1."
  type        = number
  default     = 2

  validation {
    condition     = var.aurora_instance_count >= 1
    error_message = "aurora_instance_count має бути не менше 1."
  }
}

variable "instance_class" {
  description = "Клас інстансу, наприклад db.t3.micro для RDS або db.t3.medium для Aurora."
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Обсяг диска в ГБ для звичайної RDS. Для Aurora не використовується."
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Ім'я бази, яку AWS створить під час запуску."
  type        = string
}

variable "username" {
  description = "Ім'я адміністративного користувача бази."
  type        = string
}

variable "password" {
  description = "Пароль адміністративного користувача. Не комітьте це значення."
  type        = string
  sensitive   = true
}

variable "vpc_id" {
  description = "ID VPC, у якій створюється Security Group."
  type        = string
}

variable "subnet_private_ids" {
  description = "Приватні підмережі. Використовуються, коли publicly_accessible = false."
  type        = list(string)
}

variable "subnet_public_ids" {
  description = "Публічні підмережі. Використовуються, коли publicly_accessible = true."
  type        = list(string)
}

variable "publicly_accessible" {
  description = "true відкриває базу з інтернету і кладе її в публічні підмережі. false лишає базу в приватних підмережах."
  type        = bool
  default     = false
}

variable "multi_az" {
  description = "Резервна репліка звичайної RDS в іншій зоні доступності. Для Aurora відмовостійкість дає aurora_instance_count більше 1."
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Скільки днів зберігати автоматичні резервні копії. 0 вимикає бекапи для звичайної RDS."
  type        = number
  default     = 7
}

variable "parameters" {
  description = "Параметри parameter group. Набір має відповідати рушію: для PostgreSQL це max_connections, log_statement, work_mem."
  type        = map(string)
  default = {
    max_connections = "200"
    log_statement   = "ddl"
    work_mem        = "4096"
  }
}

variable "parameter_apply_method" {
  description = "Коли застосовувати параметри: pending-reboot або immediate. pending-reboot безпечний для статичних параметрів на кшталт max_connections."
  type        = string
  default     = "pending-reboot"

  validation {
    condition     = contains(["pending-reboot", "immediate"], var.parameter_apply_method)
    error_message = "parameter_apply_method має бути pending-reboot або immediate."
  }
}

variable "allowed_cidr_blocks" {
  description = "CIDR, з яких дозволено вхід на порт бази. Для продакшну обмежте мережею застосунку замість 0.0.0.0/0."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "port" {
  description = "Порт бази. null обирає 5432 для PostgreSQL і 3306 для MySQL."
  type        = number
  default     = null
}

variable "skip_final_snapshot" {
  description = "Не створювати фінальний знімок під час знищення. Зручно для навчального середовища."
  type        = bool
  default     = true
}

variable "storage_encrypted" {
  description = "Шифрувати диск бази."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Теги для всіх ресурсів модуля."
  type        = map(string)
  default     = {}
}
