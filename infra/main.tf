terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.15.0"
    }
    airbyte = {
      source  = "airbytehq/airbyte"
      version = "0.6.2"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "airbyte" {
  // If running locally (Airbyte OSS) with docker-compose using the airbyte-proxy,
  // include the actual password/username you've set up (or use the defaults below)
  password = "password"
  username = "airbyte"

  // if running locally (Airbyte OSS)
  server_url = "http://localhost:8001/api/public/v1/"
}
