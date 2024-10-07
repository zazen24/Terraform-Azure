# resource "random_pet" "rg_name" {
#   prefix = var.resource_group_name_prefix
# }

resource "azurerm_resource_group" "rg" {
  location = "eastus"
  name     = "AKS-ResourceGroup"

}

resource "azurerm_resource_group" "ag-rg" {
  location = "eastus"
  name     = "AG-ResourceGroup"

}

resource "azurerm_container_registry" "acr" {
  name                = "DemooACRchet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = false
}



resource "azurerm_kubernetes_cluster" "cluster" {
  name                = "learnk8scluster"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "learnk8scluster"
  kubernetes_version = "1.29.2"
  

  default_node_pool {
    name       = "default"
    node_count = "1"
    #vm_size    = "standard_d2_v2"
    vm_size    = "standard_B2s"
  }
  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "basic"
  }
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_public_ip" "app_gateway_ip" {
  name                = "app-gateway-ip"
  location            = azurerm_resource_group.ag-rg.name
  resource_group_name = azurerm_resource_group.ag-rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}



# resource "azurerm_role_assignment" "example" {
#   principal_id                     = azurerm_kubernetes_cluster.cluster.kubelet_identity[0].object_id
#   role_definition_name             = "AcrPull"
#   scope                            = azurerm_container_registry.acr.id
#   skip_service_principal_aad_check = true
# }