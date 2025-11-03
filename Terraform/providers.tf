terraform {
  required_providers {  
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.36"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "2.5"
    }
  }
}

provider "azurerm" {
  features {}
}