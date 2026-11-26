variable "environment" {
  type        = string
  default     = "production"
  description = "Deployment environment (production, staging, development)"
}

variable "location" {
  type        = string
  default     = "eastus2"
  description = "Primary Azure region"
}

variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "Primary AWS region"
}

variable "project_id" {
  type        = string
  default     = "enterprise-cloud-prod"
  description = "GCP Project ID"
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "Primary GCP region"
}

variable "common_tags" {
  type = map(string)
  default = {
    ManagedBy = "ArchiForge"
    Security  = "ZeroTrust-TLS13-KMS"
  }
}
