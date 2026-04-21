terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
  }
}

provider "azurerm" {
  features {}
}

###############################################################################
# Kubernetes provider — points at the test AKS cluster
# Uses the kube_config output added to Person B's module
###############################################################################

provider "kubernetes" {
  host                   = module.aks_test.kube_config.host
  client_certificate     = base64decode(module.aks_test.kube_config.client_certificate)
  client_key             = base64decode(module.aks_test.kube_config.client_key)
  cluster_ca_certificate = base64decode(module.aks_test.kube_config.cluster_ca_certificate)
}

###############################################################################
# Person B — AKS cluster (test)
###############################################################################

module "aks_test" {
  source = "../../modules/aks"

  resource_group_name = var.resource_group_name
  location            = var.location
  cluster_name        = "aks-test"
  dns_prefix          = "aks-test"
  kubernetes_version  = "1.32"
  node_count          = 1
  vm_size             = "Standard_B2s"
  enable_auto_scaling = false
  subnet_id           = var.subnet_id

  tags = {
    environment = "test"
    project     = "cst8918-final-project"
  }
}

###############################################################################
# Person C — Azure Container Registry (shared across test + prod)
# Lives in the test env state. Prod references it via data source.
# AcrPull granted to both clusters — pass prod kubelet ID in via variable.
###############################################################################

module "acr" {
  source = "../../modules/acr"

  acr_name            = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Basic"

  # compact() removes the empty string so no invalid role assignment is created
  # before prod_kubelet_identity_object_id has been filled in.
  aks_kubelet_principal_ids = compact([
    module.aks_test.kubelet_identity_object_id,
    var.prod_kubelet_identity_object_id,
  ])

  tags = {
    project    = "cst8918-final-project"
    managed-by = "terraform"
  }
}

###############################################################################
# Person C — Remix Weather App (test environment)
###############################################################################

module "weather_app_test" {
  source = "../../modules/weather-app"

  environment         = "test"
  resource_group_name = var.resource_group_name
  location            = var.location
  name_suffix         = var.name_suffix

  acr_login_server = module.acr.acr_login_server
  weather_api_key  = var.weather_api_key

  replica_count  = 1
  redis_capacity = 0
  redis_sku      = "Basic"

  tags = {
    environment = "test"
    project     = "cst8918-final-project"
  }
}

###############################################################################
# Outputs
###############################################################################

output "cluster_name" {
  value = module.aks_test.cluster_name
}

output "cluster_id" {
  value = module.aks_test.cluster_id
}

output "acr_name" {
  description = "ACR name — Person D needs this for az acr login"
  value       = module.acr.acr_name
}

output "acr_login_server" {
  description = "ACR login server — Person D uses this as the image prefix"
  value       = module.acr.acr_login_server
}

output "test_kubelet_identity_object_id" {
  description = "Paste this value into prod/terraform.tfvars as test_kubelet_identity_object_id"
  value       = module.aks_test.kubelet_identity_object_id
}

output "test_namespace" {
  value = module.weather_app_test.namespace
}

output "test_deployment" {
  description = "Person D needs this for kubectl set image"
  value       = module.weather_app_test.deployment_name
}

output "test_container" {
  description = "Person D needs this for kubectl set image"
  value       = module.weather_app_test.container_name
}
