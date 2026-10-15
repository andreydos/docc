output "cluster_name" {
  description = "Назва EKS-кластера"
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "API endpoint EKS-кластера"
  value       = aws_eks_cluster.this.endpoint
}

output "oidc_provider_arn" {
  description = "ARN OIDC-провайдера EKS"
  value       = aws_iam_openid_connect_provider.this.arn
}

output "oidc_provider_url" {
  description = "URL OIDC-провайдера EKS"
  value       = aws_iam_openid_connect_provider.this.url
}
