resource "helm_release" "airflow" {
  name             = "airflow"
  description      = "Airflow Release"
  repository       = "https://airflow-helm.github.io/charts"
  chart            = "airflow"
  version          = "8.9.0"
  namespace        = "airflow"
  create_namespace = true

  values = [
    file("${path.module}/airflow-values.yml")
  ]
}
