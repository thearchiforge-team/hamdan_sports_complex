terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.110"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
}

resource "azurerm_resource_group" "main" {
  name     = "rg-hamdan-sports-complex-unified-arena-academy-plat-${var.environment}"
  location = var.location
  tags     = var.common_tags
}

resource "azurerm_virtual_network" "main" {
  name                = "vnet-hamdan-sports-complex-unified-arena-academy-plat-${var.environment}"
  address_space       = ["10.10.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.common_tags
}
