terraform {
  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      #version = "~>2.0"
      version = ">= 3.0"
      features =  {}
    }
    
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
  backend "azurerm" {

      key   = "terraform.tfstate"
   }
 }

provider "azurerm" {
  features {}
  
}

