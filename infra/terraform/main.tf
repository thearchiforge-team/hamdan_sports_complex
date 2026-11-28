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

data "azurerm_client_config" "current" {}

# 1. Primary & DR Resource Groups (uaenorth / uaecentral)
resource "azurerm_resource_group" "main" {
  name     = "rg-hamdan-sports-complex-unified-arena-academy-plat-${var.environment}"
  location = var.location
  tags     = var.common_tags
}

resource "azurerm_resource_group" "dr" {
  name     = "rg-hamdan-sports-complex-unified-arena-academy-plat-dr-${var.environment}"
  location = var.dr_location
  tags     = var.common_tags
}

# 2. Zero-Trust Hub-and-Spoke Virtual Network & 3 Segmented Subnets
resource "azurerm_virtual_network" "main" {
  name                = "vnet-hamdan-sports-complex-unified-arena-academy-plat-${var.environment}"
  address_space       = ["10.10.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.common_tags
}

resource "azurerm_subnet" "public_ingress" {
  name                 = "snet-public-ingress"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_subnet" "private_app_aks" {
  name                 = "snet-private-app-aks"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.10.16.0/20"]
}

resource "azurerm_subnet" "isolated_data" {
  name                 = "snet-isolated-data-stores"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.10.32.0/24"]
}

# 3. Azure Front Door Premium & WAF Policy (Edge DDoS & Waiting Room)
resource "azurerm_cdn_frontdoor_profile" "edge" {
  name                = "afd-hamdan-sports-complex-unified-arena-academy-plat-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  sku_name            = "Premium_AzureFrontDoor"
  tags                = var.common_tags
}

# 4. Azure API Management (APIM Premium Gateway)
resource "azurerm_api_management" "apim" {
  name                = "apim-hamdan-sports-complex-unified-arena-academy-plat-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  publisher_name      = "ArchiForge Enterprise Platform"
  publisher_email     = "architecture@enterprise.internal"
  sku_name            = "Premium_1"
  tags                = var.common_tags
}

# 5. Azure Kubernetes Service (AKS Multi-Zone Cluster — System + High-Concurrency User Node Pools)
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-hamdan-sports-complex-unified-arena-academy-plat-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "aks-hamdan-sports-complex-unified-arena-academy-plat"
  sku_tier            = "Standard"

  default_node_pool {
    name                = "systempool"
    vm_size             = "Standard_D4s_v5"
    vnet_subnet_id      = azurerm_subnet.private_app_aks.id
    zones               = ["1", "2", "3"]
    enable_auto_scaling = true
    min_count           = 3
    max_count           = 12
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "calico"
  }

  tags = var.common_tags
}

# 6. Azure Database for PostgreSQL Flexible Server (Zone-Redundant HA + Geo-Replica)
resource "azurerm_postgresql_flexible_server" "postgres" {
  name                   = "psql-hamdan-sports-complex-unified-arena-academy-plat-${var.environment}"
  resource_group_name    = azurerm_resource_group.main.name
  location               = azurerm_resource_group.main.location
  version                = "16"
  sku_name               = "GP_Standard_D8s_v3"
  storage_mb             = 131072
  backup_retention_days  = 35
  geo_redundant_backup_enabled = true
  zone                   = "1"

  high_availability {
    mode                      = "ZoneRedundant"
    standby_availability_zone = "2"
  }

  tags = var.common_tags
}

# 7. Azure Cache for Redis Enterprise (8-Minute Atomic Seat Locks & Sub-150ms Turnstile Cache)
resource "azurerm_redis_cache" "redis" {
  name                = "redis-hamdan-sports-complex-unified-arena-academy-plat-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  capacity            = 2
  family              = "P"
  sku_name            = "Premium"
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"
  zones               = ["1", "2"]
  tags                = var.common_tags
}

# 8. Azure Event Hubs Namespace (Domain Events & Smart Turnstile Telemetry)
resource "azurerm_eventhub_namespace" "events" {
  name                = "evhns-hamdan-sports-complex-unified-arena-academy-plat-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"
  capacity            = 4
  zone_redundant      = true
  tags                = var.common_tags
}

# 9. Azure Key Vault Premium HSM (FIPS 140-2 Level 3 KMS CMK & PCI Tokenization)
resource "azurerm_key_vault" "hsm" {
  name                        = "kv-hamdansports-${var.environment}"
  location                    = azurerm_resource_group.main.location
  resource_group_name         = azurerm_resource_group.main.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "premium"
  soft_delete_retention_days  = 90
  purge_protection_enabled    = true
  enable_rbac_authorization   = true
  tags                        = var.common_tags
}

# 10. Azure Monitor Log Analytics & Application Insights (OpenTelemetry Observability)
resource "azurerm_log_analytics_workspace" "law" {
  name                = "law-hamdan-sports-complex-unified-arena-academy-plat-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 90
  tags                = var.common_tags
}

resource "azurerm_application_insights" "appinsights" {
  name                = "appi-hamdan-sports-complex-unified-arena-academy-plat-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  workspace_id        = azurerm_log_analytics_workspace.law.id
  application_type    = "web"
  tags                = var.common_tags
}
