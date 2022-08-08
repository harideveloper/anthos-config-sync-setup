variable "project_id" {
  type    = string
  default = "sandbox-db-enablers"
}

variable "application" {
  type    = string
  default = "acm-demo"
}

## VPC Module  
variable "vpc" {
  type    = string
  default = "acm-vpc-enablers"
}

variable "region" {
  type    = string
  default = "europe-west2"
}

variable "subnet_name" {
  type    = string
  default = "subnet-01"
}

variable "subnet_ip" {
  type    = string
  default = "10.0.0.0/20"
}

variable "pod_cidr" {
  type    = string
  default = "10.10.0.0/20"
}

variable "svc1_cidr" {
  type    = string
  default = "10.100.0.0/24"
}

variable "svc2_cidr" {
  type    = string
  default = "10.100.1.0/24"
}

## GKE Cluster Module 
variable "gke_cluster_name" {
  type    = string
  default = "gke-acm-cluster"
}

variable "gke_zone" {
  type    = string
  default = "europe-west2-a"
}

variable "gke_channel" {
  type    = string
  default = "REGULAR"
}

variable "gke_enabled" {
  type    = bool
  default = true
}

## Module GKE Auth
variable "gke_kubeconfig" {
  type    = string
  default = "gke_kubeconfig_enablers.secret"
}


## Module Config Sync

variable "sync_repo" {
  type    = string
  default = "https://github.com/harideveloper/acm-root-repo.git"
}

variable "sync_branch" {
  type    = string
  default = "main"
}

variable "sync_token" {
  type    = string
  default = ""
}

variable "sync_ssh_key_path" {
  type    = string
  #default = "/Users/harsunda1/Desktop/Workspace/keys/acm_keys/acm-public-key"
  default = "/home/harsunda1/anthos-config-sync/ssh/acm-public-key"
}

variable "git_user" {
  type    = string
  default = "harideveloper"
}

variable "policy_dir" {
  type    = string
  default = ""
}

variable "acm_namespace" {
  type    = string
  default = "config-management-system"
}








