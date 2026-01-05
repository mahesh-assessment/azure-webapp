resource "azurerm_public_ip" "appgw_pip" {
  name                = "pip-appgw"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  allocation_method = "Static"
  sku               = "Standard"

  domain_name_label = "quoteapp"

  zones = ["1", "2", "3"]
}
