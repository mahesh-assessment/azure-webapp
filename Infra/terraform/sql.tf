# sql.tf - REMOVED the data "azurerm_client_config" "current" {} line

resource "azurerm_mssql_server" "sql" {
  name                = "sql-quote-${random_id.rand.hex}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  version             = "12.0"

  # SQL admin credentials from Key Vault (randomly generated)
  administrator_login          = "sqladminuser"
  administrator_login_password = data.azurerm_key_vault_secret.sql_admin_password.value

  # SECURITY: Disable public access
  public_network_access_enabled = false

  # Azure AD Admin (required for Managed Identity auth)
  # Now references the data block from keyvault.tf
  azuread_administrator {
    login_username = "aad-sql-admin"
    object_id      = data.azurerm_client_config.current.object_id
  }
}

resource "azurerm_mssql_database" "db" {
  name      = "quotedb"
  server_id = azurerm_mssql_server.sql.id
  sku_name  = "Basic"

  depends_on = [
    azurerm_mssql_server.sql
  ]

  # Prevents 404 LTR policy race condition
  long_term_retention_policy {
    weekly_retention  = "P0D"
    monthly_retention = "P0D"
    yearly_retention  = "P0D"
  }

  timeouts {
    create = "30m"
    read   = "10m"
  }
}

resource "azurerm_mssql_database_transparent_data_encryption" "tde" {
  database_id = azurerm_mssql_database.db.id
  state       = "Enabled"
}

resource "azurerm_mssql_server_security_alert_policy" "alerts" {
  server_name         = azurerm_mssql_server.sql.name
  resource_group_name = azurerm_resource_group.rg.name
  state               = "Enabled"
}

resource "azurerm_mssql_server_auditing_policy" "audit" {
  server_id                  = azurerm_mssql_server.sql.id
  storage_endpoint           = azurerm_storage_account.audit.primary_blob_endpoint
  storage_account_access_key = azurerm_storage_account.audit.primary_access_key
  retention_in_days          = 90
}

