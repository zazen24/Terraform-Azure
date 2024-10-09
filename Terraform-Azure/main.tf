# resource "random_pet" "rg_name" {
#   prefix = var.resource_group_name_prefix
# }

resource "azurerm_resource_group" "rg" {
  location = "eastus2"
  name     = "AKS-ResourceGroup"

}

resource "azurerm_resource_group" "ag-rg" {
  location = "eastus2"
  name     = "AG-ResourceGroup"

}


# resource "azurerm_public_ip" "app_gateway_ip" {
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



##create a application gateway and associate it with the kubernetes cluster




resource "azurerm_virtual_network" "example" {
  name                = "app-gateway-network"
  resource_group_name = azurerm_resource_group.ag-rg.name
  location            = azurerm_resource_group.ag-rg.location
  address_space       = ["10.254.0.0/16"]
}

resource "azurerm_subnet" "example" {
  name                 = "app-gateway-subnet"
  resource_group_name  = azurerm_resource_group.ag-rg.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.254.0.0/24"]
}

resource "azurerm_public_ip" "example" {
  name                = "AG-pip"
  resource_group_name = azurerm_resource_group.ag-rg.name
  location            = azurerm_resource_group.ag-rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# since these variables are re-used - a locals block makes this more maintainable
locals {
  backend_address_pool_name      = "${azurerm_virtual_network.example.name}-beap"
  frontend_port_name             = "${azurerm_virtual_network.example.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.example.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.example.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.example.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.example.name}-rqrt"
  redirect_configuration_name    = "${azurerm_virtual_network.example.name}-rdrcfg"
}

resource "azurerm_application_gateway" "network" {
  name                = "example-appgateway"
  resource_group_name = azurerm_resource_group.ag-rg.name
  location            = azurerm_resource_group.ag-rg.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.example.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.example.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/path1/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    priority                   = 9
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}

# resource "azurerm_role_assignment" "example" {
#   principal_id                     = azurerm_kubernetes_cluster.cluster.kubelet_identity[0].object_id
#   role_definition_name             = "AcrPull"
#   scope                            = azurerm_container_registry.acr.id
#   skip_service_principal_aad_check = true
# }