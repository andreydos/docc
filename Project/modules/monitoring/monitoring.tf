resource "helm_release" "prometheus" {
  name             = "prometheus"
  namespace        = var.namespace
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "prometheus"
  version          = "29.37.0"
  create_namespace = true
  timeout          = 900

  values = [
    file("${path.module}/prometheus-values.yaml")
  ]
}

resource "helm_release" "grafana" {
  name             = "grafana"
  namespace        = var.namespace
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "grafana"
  version          = "10.5.15"
  create_namespace = true
  timeout          = 600

  values = [
    templatefile("${path.module}/grafana-values.yaml", {
      admin_password = var.grafana_admin_password
    })
  ]

  depends_on = [helm_release.prometheus]
}
