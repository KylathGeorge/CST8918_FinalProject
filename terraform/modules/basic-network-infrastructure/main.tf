data "azurerm_resource_group" "network" {
  name = var.resource_group_name
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-group-5"
  address_space       = ["10.0.0.0/14"]
  location            = data.azurerm_resource_group.network.location
  resource_group_name = data.azurerm_resource_group.network.name
  tags                = var.tags
}

# Subnets with Environment-based Octets
resource "azurerm_subnet" "prod" {
  name                 = "prod"
  resource_group_name  = data.azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "test" {
  name                 = "test"
  resource_group_name  = data.azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "dev" {
  name                 = "dev"
  resource_group_name  = data.azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.2.0.0/16"]
}

resource "azurerm_subnet" "admin" {
  name                 = "admin"
  resource_group_name  = data.azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.3.0.0/16"]
}