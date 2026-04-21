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

output "cluster_name" {
  value = module.aks_test.cluster_name
}

output "cluster_id" {
  value = module.aks_test.cluster_id
}