variable "environment" {
  type        = string
  default     = "production"
  description = "Deployment environment (production, staging, development)"
}

variable "location" {
  type        = string
  default     = "uaenorth"
  description = "Primary Azure region (Data Residency compliant)"
}

variable "dr_location" {
  type        = string
  default     = "uaecentral"
  description = "Paired Disaster Recovery Azure region (RTO <= 15m, RPO <= 5m)"
}

variable "common_tags" {
  type = map(string)
  default = {
    ManagedBy      = "ArchiForge"
    Security       = "ZeroTrust-TLS13-HSM"
    DataResidency  = "uaenorth"
  }
}
