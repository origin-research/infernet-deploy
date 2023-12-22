terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.5"
    }
  }
}

# GCP Configuration
provider "google" {
  credentials = file(var.gcp_credentials_file_path)
  project     = var.project
  region      = var.region
  zone        = var.zone
}
