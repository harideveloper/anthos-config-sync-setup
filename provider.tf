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
  project = "hariprasad-sundaresan-0202"
}
provider "google-beta" { 
  project = "hariprasad-sundaresan-0202"
}
