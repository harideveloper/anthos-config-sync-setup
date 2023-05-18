locals {
  machine_type = "n1-standard-4" # 1 vCPU; 3.75 GiB
  node_count   = 1
  subnet_name  = "${var.application}-${var.subnet_name}"
}

## vpc module
module "vpc" {
  source = "terraform-google-modules/network/google"

  project_id   = var.project_id
  network_name = var.vpc
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name   = local.subnet_name
      subnet_ip     = var.subnet_ip
      subnet_region = var.region
    },
  ]

  secondary_ranges = {
    "${local.subnet_name}" = [
      {
        range_name    = "${var.subnet_name}-pod-cidr"
        ip_cidr_range = var.pod_cidr
      },
      {
        range_name    = "${var.subnet_name}-svc1-cidr"
        ip_cidr_range = var.svc1_cidr
      },
      {
        range_name    = "${var.subnet_name}-svc2-cidr"
        ip_cidr_range = var.svc2_cidr
      },
    ]
  }

  firewall_rules = [{
    name        = "${var.application}-allow-all-10"
    description = "Allow Pod to Pod connectivity"
    direction   = "INGRESS"
    ranges      = ["10.0.0.0/8"]
    allow = [{
      protocol = "tcp"
      ports    = ["0-65535"]
    }]
  }]
}

## gke container data
data "google_container_cluster" "gke" {
  name     = var.gke_cluster_name
  location = var.gke_zone

  # ip_allocation_policy {
  #   cluster_ipv4_cidr_block = var.pod_cidr
  #   cluster_secondary_range_name = "${var.subnet_name}-pod-cidr"
  #   services_ipv4_cidr_block = var.svc1_cidr
  #   services_secondary_range_name = "${var.subnet_name}-svc1-cidr"
  # }

  depends_on = [module.acm-gke-cluster]
}


## gke module
module "acm-gke-cluster" {
  source = "terraform-google-modules/kubernetes-engine/google"
  count  = var.gke_enabled ? 1 : 0

  project_id                = module.vpc.project_id
  name                      = var.gke_cluster_name
  regional                  = false
  region                    = var.region
  zones                     = [var.gke_zone]
  network                   = module.vpc.network_name
  subnetwork                = local.subnet_name
  ip_range_pods             = "${var.subnet_name}-pod-cidr"
  ip_range_services         = "${var.subnet_name}-svc1-cidr"
  default_max_pods_per_node = 64
  network_policy            = true
  release_channel           = var.gke_channel
  cluster_resource_labels   = { "mesh_id" : "${var.project_id}" }
  node_pools = [
    {
      name         = "node-pool-01"
      autoscaling  = false
      auto_upgrade = true
      min_count    = local.node_count
      max_count    = local.node_count
      node_count   = local.node_count
      machine_type = local.machine_type
    },
  ]
}

## Module Gke Auth
module "gke_auth" {
  source = "terraform-google-modules/kubernetes-engine/google//modules/auth"
  count  = var.gke_enabled ? 1 : 0

  project_id   = var.project_id
  cluster_name = module.acm-gke-cluster[0].name
  location     = module.acm-gke-cluster[0].location
  depends_on   = [module.acm-gke-cluster]
}

resource "local_file" "gke_kubeconfig" {
  count = var.gke_enabled ? 1 : 0

  content  = module.gke_auth[0].kubeconfig_raw
  filename = var.gke_kubeconfig
}

# Module GKE Hub

resource "google_gke_hub_membership" "gke_membership" {
  membership_id = var.gke_cluster_name
  endpoint {
    gke_cluster {
      resource_link = "//container.googleapis.com/${data.google_container_cluster.gke.id}"
    }
  }
  provider = google-beta
  depends_on = [module.acm-gke-cluster]
}

## Enable Hub 

# resource "null_resource" "exec_gke_mesh" {
#   provisioner "local-exec" {
#     interpreter = ["bash", "-exc"]
#     command     = "${path.module}/scripts/mesh.sh"
#     environment = {
#       CLUSTER    = data.google_container_cluster.gke.name
#       LOCATION   = data.google_container_cluster.gke.location
#       PROJECT    = var.project_id
#       KUBECONFIG = var.gke_kubeconfig
#     }
#   }
#   triggers = {
#     build_number = "${timestamp()}"
#     script_sha1  = sha1(file("${path.module}/scripts/mesh.sh")),
#   }
# }

resource "google_gke_hub_feature" "feature" {
  name = "configmanagement"
  location = "global"
  provider = google-beta
}


## Enable Config Sync Feature

resource "google_gke_hub_feature_membership" "config_sync_feature" {
  location = "global"
  feature = "configmanagement"
  membership = google_gke_hub_membership.gke_membership.membership_id
  configmanagement {
    #version = "1.8.0"
    config_sync {
      source_format = "unstructured"
      git {
        sync_repo = var.sync_repo
        sync_branch = var.sync_branch
        policy_dir = var.policy_dir
        secret_type = "token"
        # secret_type = "none"
        # secret_type = "ssh"
      }
    }
  }
  provider = google-beta
}

## Create GIT CREDS Secret ( Register Config Sync )
resource "null_resource" "config_sync_secret" {
  provisioner "local-exec" {
    interpreter = ["bash", "-exc"]
    command     = "${path.module}/scripts/gitcreds.sh"
    environment = {
      ACM_NAMESPACE = var.acm_namespace
      GIT_USER =  var.git_user 
      TOKEN = var.sync_token 
      SSH_PATH = var.sync_ssh_key_path
    }
  }
  triggers = {
    build_number = "${timestamp()}"
    script_sha1  = sha1(file("${path.module}/scripts/gitcreds.sh")),
  }
  #depends_on = [module.acm]
  depends_on = [google_gke_hub_feature_membership.config_sync_feature]
}



