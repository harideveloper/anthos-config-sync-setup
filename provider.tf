terraform {
  required_version = ">=1.0.0"
  required_providers {
    google = {
      source = "hashicorp/google"
    }
    google-beta = {
      source = "hashicorp/google-beta"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

# Provider
provider "google" {    
  project = "sandbox-db-enablers"
}
provider "google-beta" { 
  project = "sandbox-db-enablers"
}
