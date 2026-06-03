terraform {
        required_providers {
                azurerm = {
                        source = "hashicorp/azurerm"
                        version = "=4.1.0"
                }
        }
}

provider "azurerm" {
        features {}
}

resource "azurerm_resource_group" "rg_june_2026" {
        name = "rg_pipeline_project"
        location = "southeastasia" # I am only allowed in 5 regions because of Students' restrictions. So, expect some latency
}

resource "azurerm_container_registry" "acr" {
        name = "acrprincepipelinejune2026"
        resource_group_name = azurerm_resource_group.rg_june_2026.name
        location = azurerm_resource_group.rg_june_2026.location
        sku = "Basic"
        admin_enabled = true
}