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
  username   = "airbyte"
  password   = "airbyte"
  server_url = "http://localhost:8001/api/public/v1/"
}
