terraform {
  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      #version = "~>2.0"
      version = ">= 3.0"
      #features =  {}
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

provider "helm" {
  kubernetes = {
    host                   = azurerm_kubernetes_cluster.cluster.kube_config[0].host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.cluster.kube_config[0].client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.cluster.kube_config[0].client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.cluster.kube_config[0].cluster_ca_certificate)
  }
}