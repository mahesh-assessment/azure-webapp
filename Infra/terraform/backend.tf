# backend.tf
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "tfstate${random_id.rand.hex}"
    container_name       = "tfstate"
    key                  = "quote-app.terraform.tfstate"
    use_azuread_auth     = true
  }
}
