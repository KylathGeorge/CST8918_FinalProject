# Create the Resource Group
resource "azurerm_resource_group" "backend" {
  name     = var.resource_group_name
  location = var.location
}

# Create the Storage Account
resource "azurerm_storage_account" "state" {
  name                     = "st8918${var.group_number}${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.backend.name
  location                 = azurerm_resource_group.backend.location
  account_tier             = "Standard"
  replication_type         = "LRS"
  allow_nested_items_to_pull_separate_account_keys = false
}

# Create the Container for the .tfstate file
resource "azurerm_storage_container" "state_container" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.state.name
  container_access_type = "private"
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}