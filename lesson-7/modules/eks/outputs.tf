output "cluster_name" {
  description = "Назва EKS-кластера"
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "API endpoint EKS-кластера"
  value       = aws_eks_cluster.this.endpoint
}
