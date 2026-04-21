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

module "aks_prod" {
  source = "../../modules/aks"

  resource_group_name = var.resource_group_name
  location            = var.location
  cluster_name        = "aks-prod"
  dns_prefix          = "aks-prod"
  kubernetes_version  = "1.32"
  vm_size             = "Standard_B2s"
  enable_auto_scaling = true
  min_count           = 1
  max_count           = 3
  subnet_id           = var.subnet_id

  tags = {
    environment = "prod"
    project     = "cst8918-final-project"
  }
}

output "cluster_name" {
  value = module.aks_prod.cluster_name
}

output "cluster_id" {
  value = module.aks_prod.cluster_id
}

module "backend_prod" {
  source              = "../../modules/backend"
  resource_group_name = "var.resource_group_name"
  location            = var.location
  group_number        = "5"

  tags = {
    environment = "prod"
    project     = "cst8918-final-project"
  }
}