terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfdevbackenddevops123"
    container_name      = "tfstate"
    key                 = "dev.tfstate"
  }
}

provider "azurerm" {
  features {}
}