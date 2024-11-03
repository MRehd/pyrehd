terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.116.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = "1.50.0" #1.50.0
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {
}
