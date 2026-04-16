resource "azurerm_user_assigned_identity" "this" {
  name                = var.identity_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_federated_identity_credential" "this" {
  name                = "${var.identity_name}-fic"
  resource_group_name = var.resource_group_name
  parent_id           = azurerm_user_assigned_identity.this.id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = "https://token.actions.githubusercontent.com"
  subject             = var.github_subject
}

resource "azurerm_role_assignment" "this" {
  scope                = var.role_scope
  role_definition_name = var.role_definition_name
  principal_id         = azurerm_user_assigned_identity.this.principal_id
}