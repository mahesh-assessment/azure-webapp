# keyvault.tf
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name                       = "kv-quote-${random_id.rand.hex}"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  # Grant yourself full access
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Recover",
      "Backup",
      "Restore",
      "Purge"
    ]
  }

  # Grant AKS identity access to read secrets
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_kubernetes_cluster.aks.identity[0].principal_id

    secret_permissions = [
      "Get",
      "List"
    ]
  }

  tags = {
    environment = "production"
  }
}

# Data sources to read existing secrets (will be created by CLI script)
data "azurerm_key_vault_secret" "appgw_cert_password" {
  name         = "appgw-cert-password"
  key_vault_id = azurerm_key_vault.kv.id
  
  # This will fail on first run, but that's OK - we'll create secrets after KV
  depends_on = [azurerm_key_vault.kv]
}

data "azurerm_key_vault_secret" "sql_admin_password" {
  name         = "sql-admin-password"
  key_vault_id = azurerm_key_vault.kv.id
  
  depends_on = [azurerm_key_vault.kv]
}

# Store certificate in Key Vault too (optional but recommended)
resource "azurerm_key_vault_certificate" "appgw" {
  name         = "appgw-ssl-certificate"
  key_vault_id = azurerm_key_vault.kv.id

  certificate {
    contents = filebase64("${path.module}/certificates/cloudapp.pfx")
    password = data.azurerm_key_vault_secret.appgw_cert_password.value
  }

  depends_on = [
    azurerm_key_vault.kv,
    data.azurerm_key_vault_secret.appgw_cert_password
  ]
}
