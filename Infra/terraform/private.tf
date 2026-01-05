resource "azurerm_private_endpoint" "sql" {
  name                = "pe-sql"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.sql.id

  private_service_connection {
    name                           = "sql-priv-conn"
    private_connection_resource_id = azurerm_mssql_server.sql.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = "sql-dns-zone-group"
    private_dns_zone_ids = [
      azurerm_private_dns_zone.sql.id
    ]
  }
}
