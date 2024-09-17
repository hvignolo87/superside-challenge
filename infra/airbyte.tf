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

resource "airbyte_source_postgres" "clients_db" {
  configuration = {
    database = "clients"
    host     = "clients-db"
    username = "clients"
    password = "clients"
    port     = 5432
    schemas  = ["public"]
    replication_method = {
      scan_changes_with_user_defined_cursor = {}
    }
    ssl_mode = {
      disable = {}
    }
    tunnel_method = {
      no_tunnel = {}
    }
  }
  workspace_id = "071d7739-bd76-42f8-a2be-79f4a8c70cf9"
  name         = "Clients"
}
