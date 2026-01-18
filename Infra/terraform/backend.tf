terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-vault"
    storage_account_name = "tfstatequote526"
    container_name       = "tfstate"
    key                  = "quote-app/production.tfstate"
  }
}
