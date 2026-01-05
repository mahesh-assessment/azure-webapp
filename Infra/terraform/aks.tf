resource "azurerm_kubernetes_cluster" "aks" {
  name                      = "aks-quote-app"
  location                  = "centralindia"
  resource_group_name       = azurerm_resource_group.rg.name
  dns_prefix                = "quoteaks"
  workload_identity_enabled = true
  oidc_issuer_enabled       = true


  default_node_pool {
    name       = "system"
    node_count = 1
    vm_size    = "Standard_D2ls_v5"
    vnet_subnet_id = azurerm_subnet.aks.id 
  }

  identity {
    type = "SystemAssigned"
  }

}

