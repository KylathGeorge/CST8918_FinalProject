###############################################################################
# Azure Container Registry — single shared registry for both test and prod
# Images are tagged with commit SHA by the Docker build workflow (Person D)
###############################################################################

resource "azurerm_container_registry" "this" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  admin_enabled       = false # use managed identity / RBAC, not admin creds

  tags = var.tags
}

###############################################################################
# Grant each AKS cluster's kubelet identity AcrPull on this registry.
# Person B's AKS module must output kubelet_identity[0].object_id for each cluster.
# Pass them in as a list — both test and prod clusters get pull access.
###############################################################################

resource "azurerm_role_assignment" "aks_acr_pull" {
  for_each = toset(var.aks_kubelet_principal_ids)

  scope                            = azurerm_container_registry.this.id
  role_definition_name             = "AcrPull"
  principal_id                     = each.value
  skip_service_principal_aad_check = true
}
