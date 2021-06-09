terraform {
  required_version = "~>0.15"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.51.0"
    }
  }

  # This allows us to utilize defaults and optional values on object variables
  experiments = [module_variable_optional_attrs]
}

locals {
  # Initialize the context filling in any missing value with defaults
  # Curently a pending fix fo this https://github.com/hashicorp/terraform/issues/27385
  #azure_context = defaults(var.azure_context, {
  #  location = "UK West"
  #    tier = "Basic"
  #  service_plan = {
  #    size = "B1"
  #  }
  #})
  azure_context = merge(var.azure_context, {
    location = "UK West"
    service_plan = {
      tier = "Basic"
      size = "B1"
    }
  })
}


provider "azurerm" {
  # Injection is required via the ARM_xxx environment variables

  features {}
}


resource "azurerm_resource_group" "demo" {
  name     = "bookstore-demo-${var.azure_resource_suffix}"
  location = local.azure_context.location

  tags = {
    repository = var.azure_resource_suffix
  }
}

resource "azurerm_app_service_plan" "demo" {
  name                = azurerm_resource_group.demo.name
  resource_group_name = azurerm_resource_group.demo.name
  location            = azurerm_resource_group.demo.location
  kind                = "Linux"
  reserved            = true

  sku {
    tier = local.azure_context.service_plan.tier
    size = local.azure_context.service_plan.size
  }
}


output "bookstore_resource_group_name" {
  value = azurerm_resource_group.demo.name
}

output "bookstore_service_plan_name" {
  value = azurerm_app_service_plan.demo.name
}