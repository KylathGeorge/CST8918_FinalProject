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
# Kubernetes provider — points at the prod AKS cluster
###############################################################################

provider "kubernetes" {
  host                   = module.aks_prod.kube_config.host
  client_certificate     = base64decode(module.aks_prod.kube_config.client_certificate)
  client_key             = base64decode(module.aks_prod.kube_config.client_key)
  cluster_ca_certificate = base64decode(module.aks_prod.kube_config.cluster_ca_certificate)
}

###############################################################################
# Person A — Network infrastructure (prod)
###############################################################################

module "network_prod" {
  source              = "../../modules/basic-network-infrastructure"
  resource_group_name = var.resource_group_name
  location            = var.location

  tags = {
    environment = "prod"
    project     = "cst8918-final-project"
  }
}

###############################################################################
# Person B — AKS cluster (prod)
###############################################################################

module "aks_prod" {
  source = "../../modules/aks"

  resource_group_name = var.resource_group_name
  location            = var.location
  cluster_name        = "aks-prod"
  dns_prefix          = "aks-prod"
  kubernetes_version  = "1.32"
  node_count          = 1
  min_count           = 1
  max_count           = 3
  vm_size             = "Standard_B2s"
  enable_auto_scaling = true
  subnet_id           = module.network_prod.prod_subnet_id

  tags = {
    environment = "prod"
    project     = "cst8918-final-project"
  }
}

###############################################################################
# Person A — Backend (Terraform remote state storage)
###############################################################################

module "backend_prod" {
  source              = "../../modules/backend"
  resource_group_name = var.resource_group_name
  location            = var.location
  group_number        = "5"

  tags = {
    environment = "prod"
    project     = "cst8918-final-project"
  }
}

###############################################################################
# Person A — GitHub OIDC federated identity (prod)
###############################################################################

data "azurerm_client_config" "current" {}

module "github_oidc_prod" {
  source = "../../modules/github_oidc"

  identity_name       = "github-prod-oidc"
  resource_group_name = var.resource_group_name
  location            = var.location
  role_scope          = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}"
  github_subject      = "repo:KylathGeorge/CST8918_FinalProject:ref:refs/heads/main"

  tags = {
    environment = "prod"
    project     = "cst8918-final-project"
  }
}

###############################################################################
# Person C — ACR data source
# ACR is created in the test environment state.
# Prod just looks it up by name — no duplication, no cost.
###############################################################################

data "azurerm_container_registry" "shared" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
}

###############################################################################
# Person C — Remix Weather App (prod environment)
###############################################################################

module "weather_app_prod" {
  source = "../../modules/weather-app"

  environment         = "prod"
  resource_group_name = var.resource_group_name
  location            = var.location
  name_suffix         = var.name_suffix

  acr_login_server = data.azurerm_container_registry.shared.login_server
  weather_api_key  = var.weather_api_key

  replica_count  = 2
  redis_capacity = 0
  redis_sku      = "Basic"

  tags = {
    environment = "prod"
    project     = "cst8918-final-project"
  }
}

###############################################################################
# Outputs
###############################################################################

output "cluster_name" {
  value = module.aks_prod.cluster_name
}

output "cluster_id" {
  value = module.aks_prod.cluster_id
}

output "azure_tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "azure_subscription_id" {
  value = data.azurerm_client_config.current.subscription_id
}

output "github_prod_client_id" {
  description = "Client ID for GitHub Actions OIDC login in prod"
  value       = module.github_oidc_prod.client_id
}

output "prod_kubelet_identity_object_id" {
  description = "Paste this into environments/test/terraform.tfvars so ACR grants AcrPull to this cluster"
  value       = module.aks_prod.kubelet_identity_object_id
}

output "prod_namespace" {
  value = module.weather_app_prod.namespace
}

output "prod_deployment" {
  description = "Person D needs this for kubectl set image"
  value       = module.weather_app_prod.deployment_name
}

output "prod_container" {
  description = "Person D needs this for kubectl set image"
  value       = module.weather_app_prod.container_name
}
