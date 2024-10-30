resource "azurerm_resource_group" "rg" {
  location = "eastus2"
  name     = "Azure-ResourceGroup"

}

resource "azurerm_resource_group" "resource_group_AG" {
  location = "eastus2"
  name     = "AG-ResourceGroup"

}
resource "azurerm_resource_group" "resource_group_AKS" {
  location = "eastus2"
  name     = "AKS-ResourceGroup"

}

resource "azurerm_virtual_network" "virtual_network" {
  name     = "vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location = "eastus2"
  address_space = ["192.168.0.0/16"]
  
}

resource "azurerm_subnet" "AG_subnet" {
  name                 = "AG-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = ["192.168.0.0/24"]
}

resource "azurerm_subnet" "AKS_subnet" {
  name                 = "AKS-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = ["192.168.1.0/24"]
}


resource "azurerm_container_registry" "acr" {
  name                = "DemooACRchet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = false
}



resource "azurerm_key_vault" "example" {
  name                        = "examplekeyvault"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = var.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  # access_policy {
  #   tenant_id = var.tenant_id
  #   object_id = c2b8e0f1-4dca-454a-8d88-d789bedaa56b

  #   key_permissions = [
  #     "Get",
  #   ]

  #   secret_permissions = [
  #     "Get",
  #   ]

  #   storage_permissions = [
  #     "Get",
  #   ]
  # }
}

# resource "azurerm_kubernetes_cluster" "cluster" {
#   name                = "k8scluster"
#   location            = azurerm_resource_group.resource_group_AKS.location
#   resource_group_name = azurerm_resource_group.resource_group_AKS.name
#   dns_prefix          = "learnk8scluster"
#   kubernetes_version = "1.29.2"
  

#   default_node_pool {
#     name       = "default"
#     node_count = "1"
#     #vm_size    = "standard_d2_v2"
#     vm_size    = "standard_B2s"
#     vnet_subnet_id = azurerm_subnet.AKS_subnet.id
#   }
#   network_profile {
#     network_plugin    = "kubenet"
#     load_balancer_sku = "basic"
#   }
#   identity {
#     type = "SystemAssigned"
#   }

#   ingress_application_gateway {
#     gateway_name = "appgatewayfork8"
#     subnet_id    = azurerm_subnet.AG_subnet.id
#   }
  
# }

# resource "azurerm_role_assignment" "example-acr" {
#   principal_id                     = azurerm_kubernetes_cluster.cluster.kubelet_identity[0].object_id
#   role_definition_name             = "AcrPull"
#   scope                            = azurerm_container_registry.acr.id
#   skip_service_principal_aad_check = true
# }

# data "azurerm_role_definition" "example" {
#   name = "Contributor"
# }


# resource "azurerm_role_assignment" "example" {
#   principal_id   = azurerm_kubernetes_cluster.cluster.ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
#   role_definition_name = data.azurerm_role_definition.example.name
#   scope          = azurerm_virtual_network.virtual_network.id

#   depends_on = [
#     azurerm_kubernetes_cluster.cluster
#   ]
# }


# output "aks_uai_appgw_object_id" {
#   value = azurerm_kubernetes_cluster.cluster.ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
# }


# # Required for helm provider config.
# output "aks_config" { value = azurerm_kubernetes_cluster.cluster.kube_config }

# # Required to set access policy on key vault.
# output "aks_uai_agentpool_object_id" { value = azurerm_kubernetes_cluster.cluster.kubelet_identity[0].object_id }

# # Required when setting up csi driver secret provier class.
# output "aks_uai_agentpool_client_id" { value = azurerm_kubernetes_cluster.cluster.kubelet_identity[0].client_id }
