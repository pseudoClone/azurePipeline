terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id
}

resource "azurerm_resource_group" "rg_june_2026" {
  name     = "rg_pipeline_project"
  location = "southeastasia" # I am only allowed in 5 regions because of Students' restrictions. So, expect some latency
}

resource "azurerm_container_registry" "acr" {
  name                = "acrprincepipelinejune2026"
  resource_group_name = azurerm_resource_group.rg_june_2026.name
  location            = azurerm_resource_group.rg_june_2026.location
  sku                 = "Basic"
  admin_enabled       = true
}

resource "azurerm_log_analytics_workspace" "law_rg_june_2026" {
  name                = "log-analytics-workspace-for-rg-june-2026"
  location            = azurerm_resource_group.rg_june_2026.location
  resource_group_name = azurerm_resource_group.rg_june_2026.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "azcontappenv" {
  name                       = "env-serve-and-log-app"
  location                   = azurerm_resource_group.rg_june_2026.location
  resource_group_name        = azurerm_resource_group.rg_june_2026.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law_rg_june_2026.id
}
# This thing above is the serverless cluster context

resource "azurerm_container_app" "azapp" {
  name                         = "serve-and-log-cont-app"
  container_app_environment_id = azurerm_container_app_environment.azcontappenv.id
  resource_group_name          = azurerm_resource_group.rg_june_2026.name
  revision_mode                = "Single"
  # Close old container and create a new one when update happens, saves money for me

#  lifecycle {
#    ignore_changes = [
#      template[0].container[0].image
#      # Because template is nested as list of objects. Which is valid since this is how Kubernetes deploy.yaml workds
#    ]
#  }

  secret {
    name  = "acr-password"
    value = azurerm_container_registry.acr.admin_password
  }

  registry {
    server               = azurerm_container_registry.acr.login_server
    username             = azurerm_container_registry.acr.admin_username
    password_secret_name = "acr-password"
  }

  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = 80
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  template {
    container {
      name  = "june2026fastapiapplication"
      image = "mcr.microsoft.com/azuredocs/aci-helloworld:latest"
      # I keep this above image because we haven't deployed yet and hence ACR is empty
      cpu    = "0.25"
      memory = "0.5Gi"
    }
  }
}

output "june2026fastapiapplication_url" {
  value = azurerm_container_app.azapp.latest_revision_fqdn
}