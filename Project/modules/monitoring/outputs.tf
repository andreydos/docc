output "namespace" {
  description = "Namespace Prometheus і Grafana"
  value       = var.namespace
}

output "grafana_service" {
  description = "Service Grafana"
  value       = helm_release.grafana.name
}

output "prometheus_service" {
  description = "Service Prometheus server"
  value       = "prometheus-server"
}
