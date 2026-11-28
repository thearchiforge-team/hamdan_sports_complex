output "project_slug" {
  value       = "hamdan-sports-complex-unified-arena-academy-plat"
  description = "Canonical ArchiForge service identifier"
}

output "primary_resource_group" {
  value       = azurerm_resource_group.main.name
  description = "Primary Azure Resource Group in uaenorth"
}

output "aks_cluster_name" {
  value       = azurerm_kubernetes_cluster.aks.name
  description = "Multi-Zone AKS Microservices Cluster"
}

output "postgres_fqdn" {
  value       = azurerm_postgresql_flexible_server.postgres.fqdn
  description = "Zone-Redundant PostgreSQL 16 Flexible Server FQDN"
}

output "redis_hostname" {
  value       = azurerm_redis_cache.redis.hostname
  description = "Azure Cache for Redis Enterprise Hostname"
}

output "key_vault_uri" {
  value       = azurerm_key_vault.hsm.vault_uri
  description = "Azure Key Vault HSM URI for CMK & PCI Tokenization"
}
