#------------------------------------------------------------------------------
# Create terraform account to keep tfstate
#------------------------------------------------------------------------------

# Terraform account 
terraform {
  backend "azurerm" {
    resource_group_name  = "oc-idf-dev-we-terraform"
    storage_account_name = "aldocidfdevweterraform"
    container_name       = "tfstate"
    key                  = "AKS-state.tfstate"
  }
}

#------------------------------------------------------------------------------
# Configure the Microsoft Azure Provider
#------------------------------------------------------------------------------

provider "azurerm" {
  version         = ">= 2.0"
  subscription_id = var.private_subscription_id
  tenant_id       = var.tenant_id
  features {}
}

#------------------------------------------------------------------------------
#Network Resources
#------------------------------------------------------------------------------

# ResourceGroup
resource "azurerm_resource_group" "nsg" {
  name     = "${var.teamcode}-${var.appname}-${var.env}-${var.loc}-nsg"
  location = "${var.location}"
  tags     = "${var.tags}"
}

module "vnet" {
  source                         = "./modules/vnet"
  vnet_name                      = "ald-${var.teamcode}-${var.appname}-${var.env}-${var.loc}-private-vnet"
  resource_group_name            = "${azurerm_resource_group.ntw-vnet.name}"
  location                       = "${azurerm_resource_group.ntw-vnet.location}"
  address_space                  = "${var.vnet_cidr}"
  subnet_prefixes                = "${values(var.vnet_subnets)}"
  subnet_names                   = "${keys(var.vnet_subnets)}"
  vnet_subnets_enable_privateendpoint = "${var.vnet_subnets_enable_privateendpoint}"
  vnet_subnets_service_endpoints = "${var.vnet_subnets_service_endpoints}"
  aksroutingtable                = "${var.aksroutingtable}"
  tags                           = "${var.tags}"
  nsg_ids = {
    "Cluster_Subnet" = module.Cluster_nsg.network_security_group_id
    "Data_Subnet" = module.data_nsg.network_security_group_id
  }
}

resource "azurerm_resource_group" "ntw-vnet" {
  name     = "${var.teamcode}-${var.appname}-${var.env}-${var.loc}-rg-ntw"
  location = "${var.location}"
  tags     = "${var.tags}"
}

#------------------------------------------------------------------------------
# NSG subnet associations 
#------------------------------------------------------------------------------

resource "azurerm_subnet_network_security_group_association" "clustersubnetnsg" {
  subnet_id                 = "${module.vnet.vnet_subnets_name_id_map["ClusterSubnet"]}"
  network_security_group_id = module.Cluster_nsg.network_security_group_id
}

resource "azurerm_subnet_network_security_group_association" "datasubnetnsg" {
  subnet_id                 = "${module.vnet.vnet_subnets_name_id_map["DataSubnet"]}"
  network_security_group_id = module.data_nsg.network_security_group_id
}

#------------------------------------------------------------------------------
# Creating route tables for ClusterSubnet and DataSubnet
#------------------------------------------------------------------------------

resource "azurerm_route_table" "cluster" {
  name                          = "ald-${var.teamcode}-${var.appname}-${var.env}-${var.loc}-cluster-rtbl"
  location                      = "${azurerm_resource_group.ntw-vnet.location}"
  resource_group_name           = "${azurerm_resource_group.ntw-vnet.name}"
  disable_bgp_route_propagation = false

  route {
    name           = "Default"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = "183.200.45.188"
  }

  tags = {
    environment = "DEV"
  }
}

resource "azurerm_route_table" "data" {
  name                          = "ald-${var.teamcode}-${var.appname}-${var.env}-${var.loc}-data-rtbl"
  location                      = "${azurerm_resource_group.ntw-vnet.location}"
  resource_group_name           = "${azurerm_resource_group.ntw-vnet.name}"
  disable_bgp_route_propagation = false

  route {
    name           = "Default"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = "183.200.45.188"
  }

  tags = {
    environment = "DEV"
  }
}

#-------------------------------------------------------------------
# Route Table Assosiation to both ClusterSubnet and DataSubnet
#--------------------------------------------------------------------

resource "azurerm_subnet_route_table_association" "clustersubnet" {
  subnet_id      = "${module.vnet.vnet_subnets_name_id_map["ClusterSubnet"]}"
  route_table_id = "${azurerm_route_table.cluster.id}"
}

resource "azurerm_subnet_route_table_association" "datasubnet" {
  subnet_id      = "${module.vnet.vnet_subnets_name_id_map["DataSubnet"]}"
  route_table_id = "${azurerm_route_table.data.id}"
}

#------------------------------------------------------------------------------
# Private to Public vNet Peering
#------------------------------------------------------------------------------

resource "azurerm_virtual_network_peering" "pub2pri" {
  //provider = "azurerm.public"
  name                      = "ald-${var.teamcode}-${var.appname}-${var.env}-${var.loc}-vnetp-pub2pri"
  resource_group_name       = "${azurerm_resource_group.ntw-vnet.name}"
  virtual_network_name      = "${azurerm_virtual_network.publicvnet.name}"
  remote_virtual_network_id = "${module.vnet.vnet_name}"
  allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "pri2pub" {
  name                      = "ald-${var.teamcode}-${var.appname}-${var.env}-${var.loc}-vnetp-pri2pub"
  resource_group_name       = "${azurerm_resource_group.ntw-vnet.name}"
  virtual_network_name      = "${module.vnet.vnet_name}"
  remote_virtual_network_id = "${azurerm_virtual_network.publicvnet.name}"
  allow_virtual_network_access = true
} 

#------------------------------------------------------------------------------
# CLUSTER Resources
#------------------------------------------------------------------------------

resource "azurerm_resource_group" "aks-rsg" {
  name     = "${var.teamcode}-${var.appname}-${var.env}-${var.loc}-aks"
  location = "${var.location}"
  tags = {
    Environment = "${var.env}"
  }
} 

resource "azurerm_log_analytics_workspace" "aks" {
  name                = "ald-${var.teamcode}-${var.appname}-${var.env}-${var.loc}-law"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.aks-rsg.name}"
  sku                 = "${var.log_analytics_workspacesku}"
}

resource "azurerm_log_analytics_solution" "las" {
  solution_name         = "ContainerInsights"
  location              = "${azurerm_log_analytics_workspace.aks.location}"
  resource_group_name   = "${azurerm_resource_group.aks-rsg.name}"
  workspace_resource_id = "${azurerm_log_analytics_workspace.aks.id}"
  workspace_name        = "${azurerm_log_analytics_workspace.aks.name}"
  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

resource "azurerm_container_registry" "acr" {
  name                = "ald${var.teamcode}${var.appname}${var.env}${var.loc}acr"
  resource_group_name = "${azurerm_resource_group.aks-rsg.name}"
  location            = "${azurerm_resource_group.aks-rsg.location}"
  sku                 = "Premium"
  admin_enabled       = false
} 

resource "azurerm_private_endpoint" "acr" {
  name                = "ald-${var.teamcode}-${var.appname}-${var.env}-${var.loc}-pe-aks"
  location            = "${azurerm_resource_group.aks-rsg.location}"
  resource_group_name = "${azurerm_resource_group.aks-rsg.name}"
  subnet_id           = "${module.vnet.vnet_subnets_name_id_map["ClusterSubnet"]}"
 
  private_service_connection {
    name                           = "acr-privateserviceconnection"
    private_connection_resource_id = "${azurerm_container_registry.acr.id}"
    is_manual_connection           = false
    subresource_names              =["registry"]
  }
}


resource "azurerm_kubernetes_cluster" "aks-cluster" {
  name                = "ald-${var.teamcode}-${var.appname}-${var.env}-${var.loc}-aks-cluster"
  location            = "${azurerm_resource_group.aks-rsg.location}"
  resource_group_name = "${azurerm_resource_group.aks-rsg.name}"
  dns_prefix          = "${var.env}"
  //private_link_enabled = true
  private_cluster_enabled = true
  kubernetes_version  = "${var.kubernetes_version}"

  default_node_pool {
    name       = "default"
    node_count = "${var.vm_count["fe"]}"
    vm_size    = "${var.vm_size["fe"]}"
    vnet_subnet_id = "${module.vnet.vnet_subnets_name_id_map["ClusterSubnet"]}"
  }

  linux_profile {
    admin_username = "${var.vm_admin_username}"
    ssh_key {
      key_data = "${file("${var.ssh_public_key}")}"
    }
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
    outbound_type     = "userDefinedRouting"
  } 

    service_principal {
    client_id     = "${var.client_id}"
    client_secret = "${var.client_secret}"
  }

  role_based_access_control {
     enabled = true
     azure_active_directory {
      tenant_id = "${var.tenant_id}"
      client_app_id     = "${var.ad_client_app_id}"
      server_app_id     = "${var.ad_server_app_id}"
      server_app_secret = "${var.ad_server_app_secret}"
    }
  }

  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = "${azurerm_log_analytics_workspace.aks.id}"
    }
    http_application_routing {
      enabled = false
    }
    kube_dashboard {
      enabled = true
    }
  }

  tags = {
    Environment = "${var.env}"
  }
}

#------------------------------------------------------------------------------
# APPINSIGHTS
#------------------------------------------------------------------------------

resource "azurerm_application_insights" "ai" {
   name                = "ald-${var.teamcode}-${var.appname}-${var.env}-${var.loc}-ai"
   location            = azurerm_resource_group.data.location
   resource_group_name = azurerm_resource_group.data.name
   application_type    = "web"
 } 
 
#------------------------------------------------------------------------------
# APPSERVICE
#------------------------------------------------------------------------------

 resource "azurerm_resource_group" "appservice-rg" {
  name     = "appservicedemo"
  location = "West Europe"
}

resource "azurerm_app_service_plan" "appservice-plan" {
  name                = "appserviceplan"
  location            = azurerm_resource_group.appservice-rg.location
  resource_group_name = azurerm_resource_group.appservice-rg.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "appservice" {
  name                = "appservice"
  location            = azurerm_resource_group.appservice-rg.location
  resource_group_name = azurerm_resource_group.appservice-rg.name
  app_service_plan_id = azurerm_app_service_plan.appservice-plan.id

  site_config {
    dotnet_framework_version = "v4.0"
    scm_type                 = "LocalGit"
  }

  app_settings = {
    "appinsight" = "instrumentation key"
  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=some-server.mydomain.com;Integrated Security=SSPI"
  }
}


#------------------------------------------------------------------------------
# APPLICATION GATEWAY
#------------------------------------------------------------------------------

resource "azurerm_resource_group" "applicationgtw-rg" {
  name     = "applicationgtw-rg"
  location = "West Europe"
}

resource "azurerm_public_ip" "applicationgtw" {
  name                = "appgtw-pip"
  resource_group_name = azurerm_resource_group.applicationgtw-rg.name
  location            = azurerm_resource_group.applicationgtw-rg.location
  allocation_method   = "Dynamic"
}

#&nbsp;since these variables are re-used - a locals block makes this more maintainable
locals {
  backend_address_pool_name      = "${module.vnet.vnet_name}-beap"
  frontend_port_name             = "${module.vnet.vnet_name}-feport"
  frontend_ip_configuration_name = "${module.vnet.vnet_name}-feip"
  http_setting_name              = "${module.vnet.vnet_name}-be-htst"
  listener_name                  = "${module.vnet.vnet_name}-httplstn"
  request_routing_rule_name      = "${module.vnet.vnet_name}-rqrt"
  redirect_configuration_name    = "${module.vnet.vnet_name}-rdrcfg"
}

resource "azurerm_application_gateway" "network" {
  name                = "appgateway"
  resource_group_name = azurerm_resource_group.applicationgtw-rg.name
  location            = azurerm_resource_group.applicationgtw-rg.location

  sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.frontend.id
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
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}