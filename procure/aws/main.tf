terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.12"
    }
  }
}

# AWS Configuration
provider "aws" {
  access_key = var.access_key_id
  secret_key = var.secret_access_key
  region = var.region
}
