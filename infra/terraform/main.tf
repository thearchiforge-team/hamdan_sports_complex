terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_kms_key" "workload_cmk" {
  description             = "ArchiForge Customer-Managed KMS Key for shared-team-blueprints"
  deletion_window_in_days = 30
  enable_key_rotation     = true
}

resource "aws_vpc" "main" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = "vpc-shared-team-blueprints-${var.environment}"
    ManagedBy   = "ArchiForge"
    Environment = var.environment
  }
}
