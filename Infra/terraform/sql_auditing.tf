resource "azurerm_mssql_server_auditing_policy" "audit" {
  server_id                  = azurerm_mssql_server.sql.id
  storage_endpoint           = azurerm_storage_account.audit.primary_blob_endpoint
  storage_account_access_key = azurerm_storage_account.audit.primary_access_key
  retention_in_days          = 90
}

