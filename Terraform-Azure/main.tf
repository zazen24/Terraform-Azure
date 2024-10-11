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

# resource "azurerm_public_ip" "AKS_subnet" {
#   name                = "app-gateway-ip"
#   location            = azurerm_resource_group.ag-rg.location
#   resource_group_name = azurerm_resource_group.ag-rg.name
#   allocation_method   = "Static"
#   sku                 = "Standard"
# }


resource "azurerm_container_registry" "acr" {
  name                = "DemooACRchet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = false
}



resource "azurerm_kubernetes_cluster" "cluster" {
  name                = "k8scluster"
  location            = azurerm_resource_group.resource_group_AKS.location
  resource_group_name = azurerm_resource_group.resource_group_AKS.name
  dns_prefix          = "learnk8scluster"
  kubernetes_version = "1.29.2"
  

  default_node_pool {
    name       = "default"
    node_count = "1"
    #vm_size    = "standard_d2_v2"
    vm_size    = "standard_B2s"
    vnet_subnet_id = azurerm_subnet.AKS_subnet.id
  }
  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "basic"
  }
  identity {
    type = "SystemAssigned"
  }

  ingress_application_gateway {
    gateway_name = "appgatewayfork8"
    subnet_id    = azurerm_subnet.AG_subnet.id
  }
  
}

data "azurerm_role_definition" "example" {
  name = "Contributor"
}

resource "azurerm_role_assignment" "example" {
  principal_id   = azurerm_kubernetes_cluster.cluster.ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
  role_definition_name = data.azurerm_role_definition.example.name
  scope          = azurerm_virtual_network.virtual_network.id
}

output "aks_uai_appgw_object_id" {
  value = azurerm_kubernetes_cluster.cluster.ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
}


# resource "azurerm_application_gateway" "network" {
#   name                = "appgatewayfork8"
#   resource_group_name = azurerm_resource_group.resource_group_AG.name
#   location            = azurerm_resource_group.resource_group_AG.location

#   sku {
#     name     = "Standard_v2"
#     tier     = "Standard_v2"
#     capacity = 1
#   }

#   gateway_ip_configuration {
#     name      = "my-gateway-ip-configuration"
#     subnet_id = azurerm_subnet.AG_subnet.id
#   }

#   frontend_port {
#     name = local.frontend_port_name
#     port = 80
#   }

#   frontend_ip_configuration {
#     name                 = local.frontend_ip_configuration_name
#     public_ip_address_id = azurerm_public_ip.example.id
#   }

#   backend_address_pool {
#     name = local.backend_address_pool_name
#   }

#   backend_http_settings {
#     name                  = local.http_setting_name
#     cookie_based_affinity = "Disabled"
#     path                  = "/path1/"
#     port                  = 80
#     protocol              = "Http"
#     request_timeout       = 60
#   }

#   http_listener {
#     name                           = local.listener_name
#     frontend_ip_configuration_name = local.frontend_ip_configuration_name
#     frontend_port_name             = local.frontend_port_name
#     protocol                       = "Http"
#   }

#   request_routing_rule {
#     name                       = local.request_routing_rule_name
#     priority                   = 9
#     rule_type                  = "Basic"
#     http_listener_name         = local.listener_name
#     backend_address_pool_name  = local.backend_address_pool_name
#     backend_http_settings_name = local.http_setting_name
#   }
# }

# resource "azurerm_role_assignment" "example" {
#   principal_id                     = azurerm_kubernetes_cluster.cluster.kubelet_identity[0].object_id
#   role_definition_name             = "AcrPull"
#   scope                            = azurerm_container_registry.acr.id
#   skip_service_principal_aad_check = true
# }