resource "azurerm_user_assigned_identity" "aks" {
  name                = "uai-aks-quote"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}
