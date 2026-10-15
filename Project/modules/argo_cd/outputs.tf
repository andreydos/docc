output "namespace" {
  description = "Namespace Argo CD"
  value       = helm_release.argo_cd.namespace
}

output "server_service" {
  description = "Ім'я Service Argo CD server"
  value       = "${var.name}-server"
}

output "admin_password_command" {
  description = "Команда, яка виводить початковий пароль admin"
  value       = "kubectl -n ${var.namespace} get secret argocd-initial-admin-secret -o jsonpath={.data.password} | base64 -d"
}
