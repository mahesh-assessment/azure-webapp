resource "azurerm_public_ip" "appgw_pip" {
  name                = "pip-appgw"
  resource_group_name = var.resource_group_name
  location            = var.location

  allocation_method = "Static"
  sku               = "Standard"
}
