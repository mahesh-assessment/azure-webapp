# sql.tf

resource "azurerm_mssql_server" "sql" {
  name                = "sql-quote-${random_id.rand.hex}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  version             = "12.0"

  administrator_login          = "sqladminuser"
  administrator_login_password = data.azurerm_key_vault_secret.sql_admin_password.value

  public_network_access_enabled = false

  identity {
    type = "SystemAssigned"
  }

  azuread_administrator {
    login_username = "aad-sql-admin"
    object_id      = data.azurerm_client_config.current.object_id
  }
}

resource "azurerm_mssql_database" "db" {
  name      = "quotedb"
  server_id = azurerm_mssql_server.sql.id
  sku_name  = "Basic"

  # TDE is enabled by default (AES-256)
}

