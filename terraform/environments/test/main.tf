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
# Kubernetes provider — reads from KUBECONFIG env var set by the workflow.
# Using explicit module outputs here would make the provider depend on a
# computed value (kube_config is unknown until AKS exists), which causes
# terraform import and the first apply to fail.
###############################################################################

provider "kubernetes" {
  # Credentials come from KUBECONFIG=/tmp/kubeconfig-test set in CI workflow.
  # Locally, 'az aks get-credentials --name aks-test' populates ~/.kube/config.
}

###############################################################################
# Person A — Network infrastructure (test)
###############################################################################

module "network_test" {
  source              = "../../modules/basic-network-infrastructure"
  resource_group_name = var.resource_group_name
  location            = var.location

  tags = {
    environment = "test"
    project     = "cst8918-final-project"
  }

  # backend_test creates the resource group — network module looks it up via
  # data source, so it must wait until the RG exists.
  depends_on = [module.backend_test]
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
  kubernetes_version  = "1.31"
  node_count          = 1
  vm_size             = "Standard_B2s"
  enable_auto_scaling = false
  subnet_id           = module.network_test.test_subnet_id

  tags = {
    environment = "test"
    project     = "cst8918-final-project"
  }
}

###############################################################################
# Person A — Backend (Terraform remote state storage)
###############################################################################

module "backend_test" {
  source              = "../../modules/backend"
  resource_group_name = var.resource_group_name
  location            = var.location
  group_number        = "5"

  tags = {
    environment = "test"
    project     = "cst8918-final-project"
  }
}

###############################################################################
# Person A — GitHub OIDC federated identity (test)
###############################################################################

data "azurerm_client_config" "current" {}

module "github_oidc_test" {
  source = "../../modules/github_oidc"

  identity_name       = "github-test-oidc"
  resource_group_name = var.resource_group_name
  location            = var.location
  role_scope          = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}"
  github_subject      = "repo:KylathGeorge/CST8918_FinalProject:pull_request"

  tags = {
    environment = "test"
    project     = "cst8918-final-project"
  }

  depends_on = [module.backend_test]
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

  # Keys are static strings (known at plan time) — Terraform can resolve for_each.
  # Prod key is only included when the variable has been filled in after first prod apply.
  aks_kubelet_principal_ids = merge(
    { test = module.aks_test.kubelet_identity_object_id },
    var.prod_kubelet_identity_object_id != "" ? { prod = var.prod_kubelet_identity_object_id } : {}
  )

  tags = {
    project    = "cst8918-final-project"
    managed-by = "terraform"
  }

  depends_on = [module.backend_test]
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

  depends_on = [module.backend_test]
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

output "azure_tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "azure_subscription_id" {
  value = data.azurerm_client_config.current.subscription_id
}

output "github_test_client_id" {
  description = "Client ID for GitHub Actions OIDC login in test"
  value       = module.github_oidc_test.client_id
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
  description = "Paste this value into prod/terraform.tfvars as prod_kubelet_identity_object_id"
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
