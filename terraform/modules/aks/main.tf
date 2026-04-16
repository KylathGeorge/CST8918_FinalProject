resource "azurerm_kubernetes_cluster" "this" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name                 = "default"
    vm_size              = var.vm_size
    vnet_subnet_id       = var.subnet_id
    auto_scaling_enabled = var.enable_auto_scaling
    node_count           = var.enable_auto_scaling ? null : var.node_count
    min_count            = var.enable_auto_scaling ? var.min_count : null
    max_count            = var.enable_auto_scaling ? var.max_count : null
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }

  role_based_access_control_enabled = true

  tags = var.tags
}