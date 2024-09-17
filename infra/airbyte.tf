resource "helm_release" "airbyte" {
  name             = "airbyte"
  description      = "Airbyte Release"
  repository       = "https://airbytehq.github.io/helm-charts"
  chart            = "airbyte"
  version          = "0.594.0"
  namespace        = "airbyte"
  create_namespace = true
  timeout          = 600

  values = [
    file("${path.module}/airbyte-values.yml")
  ]
}
