terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.12"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
  required_version = ">= 1.6.0"
}

# AWS Configuration
provider "aws" {
  access_key = var.access_key_id
  secret_key = var.secret_access_key
  region = var.region
}
