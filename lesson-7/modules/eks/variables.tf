variable "cluster_name" {
  description = "Назва EKS-кластера"
  type        = string
}

variable "cluster_version" {
  description = "Версія Kubernetes"
  type        = string
}

variable "public_subnet_ids" {
  description = "Публічні підмережі VPC для кластера і LoadBalancer"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Приватні підмережі VPC для worker-нод"
  type        = list(string)
}

variable "desired_size" {
  description = "Бажана кількість нод"
  type        = number
}

variable "min_size" {
  description = "Мінімальна кількість нод"
  type        = number
}

variable "max_size" {
  description = "Максимальна кількість нод"
  type        = number
}

variable "instance_types" {
  description = "Типи EC2 для нод"
  type        = list(string)
}
