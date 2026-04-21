terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

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

module "network_test" {
  source              = "../../modules/basic-network-infrastructure"
  resource_group_name = var.resource_group_name
  location            = var.location
  
  tags = {
    environment = "test"
    project     = "cst8918-final-project"
  }
}

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
}

output "github_test_client_id" {
  description = "Client ID for GitHub Actions OIDC login in test"
  value       = module.github_oidc_test.client_id
}