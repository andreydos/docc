resource "helm_release" "argo_cd" {
  name             = var.name
  namespace        = var.namespace
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.chart_version
  create_namespace = true
  timeout          = 600

  values = [
    file("${path.module}/values.yaml")
  ]
}

resource "helm_release" "argo_apps" {
  name             = "${var.name}-apps"
  chart            = "${path.module}/charts"
  namespace        = var.namespace
  create_namespace = false
  timeout          = 300

  values = [
    templatefile("${path.module}/charts/values.yaml.tftpl", {
      argo_namespace  = var.namespace
      git_repo_url    = var.git_repo_url
      git_revision    = var.git_revision
      chart_path      = var.chart_path
      github_username = var.github_username
      github_token    = var.github_token
    })
  ]

  depends_on = [helm_release.argo_cd]
}
