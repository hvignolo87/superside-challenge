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
  name         = "Clients"
  workspace_id = var.airbyte_workspace_id
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
}

resource "airbyte_destination_postgres" "warehouse" {
  name         = "Warehouse"
  workspace_id = var.airbyte_workspace_id
  configuration = {
    database            = "warehouse"
    host                = "warehouse"
    username            = "warehouse"
    password            = "warehouse"
    port                = 5432
    raw_data_schema     = "clients"
    schema              = "clients"
    disable_type_dedupe = false
    drop_cascade        = true
    ssl_mode = {
      disable = {}
    }
    tunnel_method = {
      no_tunnel = {}
    }
  }
}

resource "airbyte_connection" "clients_connection" {
  name                                 = "Clients"
  source_id                            = resource.airbyte_source_postgres.clients_db.source_id
  destination_id                       = resource.airbyte_destination_postgres.warehouse.destination_id
  namespace_definition                 = "custom_format"
  namespace_format                     = "clients"
  non_breaking_schema_updates_behavior = "propagate_columns"
  status                               = "active"
  schedule = {
    schedule_type = "manual"
    # cron_expression = "0 0 0/2 * * ?"
  }
  configurations = {
    streams = [
      {
        name      = "engagement_metrics"
        sync_mode = "full_refresh_overwrite"
      }
    ]
  }
}
