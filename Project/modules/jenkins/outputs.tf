output "jenkins_release_name" {
  description = "Назва Helm-релізу Jenkins"
  value       = helm_release.jenkins.name
}

output "jenkins_namespace" {
  description = "Namespace Jenkins"
  value       = helm_release.jenkins.namespace
}
