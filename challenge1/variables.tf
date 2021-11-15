#------------------------------------------------------------------------------
#Variables
#------------------------------------------------------------------------------
variable "private_subscription_id" {
  description = "Enter Subscription ID for provisioning resources in Azure"
  default     = "7b895049-21a3-4867-9c2e-2f31514697f8"
}


variable "uk_subscription_id" {
  description = "Enter UK Subscription ID for vnet to dev (Octopus) connectivity"
  default     = "7b895049-21a3-4867-9c2e-2f31514697f8"
}

variable "client_id" {
  description = "Enter Client ID for provisioning resources in Azure"
  default     = "415395d1-4e2d-41ef-bf0b-7c02ca086087"
}

variable "client_secret" {
  description = "Enter Client Secret for the service principle"
  default     = "eX:hlrKg0GF@Nm_K35=wED1D38Z3BS/3"
}

variable "tenant_id" {
  description = "Enter Tenant ID for provisioning resources in Azure"
  default     = "757bdf2a-9fe4-43ea-b5c9-fdb554650622"
}

variable "ad_client_app_id" {
  description = "Enter Client app id for the service principle"
  default     = "6455dcde-b0be-4a20-b872-ceafdc93388d"
}

variable "ad_server_app_id" {
  description = "Enter server app id for the service principle"
  default     = "fa8f4f05-bc2a-4f6e-9191-1a7165bbc12c"
}

variable "ad_server_app_secret" {
  description = "Enter server application secret (application password) for the service principle"
  default     = ".XNr_0T~OGs-6j3t9Z5~PqLSuK8kLRIq18"
}

variable "location" {
  description = "The default Azure region for the resource provisioning"
  default     = "West Europe"
}

variable "cosmosdb_location" {
  description = "location for the cosmos db"
  default     = "West Europe"
}

variable "failover_location" {
  description = "Failover location"
  default     = "North Europe"
}

variable "vnet_location" {
  description = "The VNET location"
  default     = "West Europe"
}

variable "enable_cosmos_db_failover" {
    description = "Enable cosmos db failover"
    default     = true
}

//Overriden in tfvars
variable "datasubnet_name" {
  description = "Data subnet name"
  default     = "DataSubnet"
}

//Overriden in tfvars
variable "clustersubnet_name" {
  description = "Cluster subnet name"
  default     = "ClusterSubnet"
}

//Overriden in tfvars
variable "gatewaysubnet_name" {
  description = "Gateway subnet name"
  default     = "GatewaySubnet"
}

//Overriden in tfvars
variable "bastionsubnet_name" {
  description = "Bastion subnet name"
  default     = "BastionSubnet"
}

//Overriden in tfvars
variable "public_vnet_name" {
  description = "Public vnet name"
  default     = "PublicVnet"
}

//Overriden in tfvars
variable "public_vnet_rg" {
  description = "Public vnet resource group name"
  default     = "PublicVnetRg"
}

//Overriden in tfvars
variable "env" {
  description = "The azure environment name"
  default     = "dev"
}

//Overriden in tfvars
variable "loc" {
  description = "The location"
  default     = "euw"
}

//Overriden in tfvars
variable "appname" {
  description = "The application name"
  default     = "idf"
}

//Overriden in tfvars
variable "teamcode" {
  description = "Team/Department code"
  default     = "tnc"
}

//Overriden in tfvars
variable "tags" {
  description = "The tags to associate with your network and subnets."
  type        = map

  default = {
    digital_platform = "true"
    environment      = "dev"
    source           = "terraform"
  }
}

//Overriden in tfvars
variable "vm_size" {
  description = "The VM type for each tier"
  type        = map

  default = {
    "fe"    = "Standard_B2ms"
    "be"    = "Standard_B2ms"
  }
}

//Overriden in tfvars
variable "vm_count" {
  description = "The VM count for each type"
  type        = map

  default = {
    "fe"    = 2
    "be"    = 1
  }
}

//Overriden in tfvars
variable "vnet_cidr" {
  description = "CIDR block for Private Virtual Network"
  default     = "10.100.2.0/24"
}

//Overriden in tfvars
variable "vnet_subnets" {
  description = "All the subnets"
  type        = map

  default = {
     "AzureBastionSubnet"    = "10.100.2.0/27"
     "DataSubnet"            = "10.100.2.32/27"
     "ClusterSubnet"         = "10.100.2.64/25"
     "GatewaySubnet"         = "10.100.2.64/25"
  }
}

variable "aksroutingtable" {
  default = ""
}

variable "vnet_subnets_service_endpoints" {
  description = "The list of Service endpoints to associate with the subnet. Possible values include: Microsoft.AzureActiveDirectory, Microsoft.AzureCosmosDB, Microsoft.EventHub, Microsoft.KeyVault, Microsoft.ServiceBus, Microsoft.Sql and Microsoft.Storage."
  type        = map

  default = {
    "AzureBastionSubnet"       = ["Microsoft.Storage","Microsoft.KeyVault"]
    "ClusterSubnet"            = ["Microsoft.Sql", "Microsoft.AzureCosmosDB"]
    "DataSubnet"               = ["Microsoft.KeyVault","Microsoft.AzureCosmosDB"]
    "GatewaySubnet"            = []
    "RouterSubnet"            = []
  }
}

variable "vnet_subnets_enable_privateendpoint" {
  description = ""
  type        = map

  default = {
    "ClusterSubnet"        = "true"
    "DataSubnet"           = "true"
    "GatewaySubnet"        = "false"
    "AzureBastionSubnet"   = "false"
    "RouterSubnet"         = "false"
  }
}

# If no values specified, this defaults to Azure DNS 

variable "enable_public_ip" {
  description = "Allow to connect from Internet. Will create an Azure Load Balancer in front of Frontend Web."
  default     = true
}

variable "p2s_address_space" {
  description = "Used by the Point-to-site VPN clients"
  default     = "172.20.20.0/24"
}

variable "trusted_network" {
  description = "Trusted network to allow RDP"
  default     = "183.200.0.64/29"
}


variable "onpremise_public_ip" {
  description = "On premise public IP for IPSec"
  default     = "94.140.175.163"
}

variable "onpremise_cidr" {
  description = "CIDR block for Subnet within on premise network"
  default     = "10.216.0.0/17"
}

variable "site2site_shared_key" {
  description = "Shared key to establish the site-2-site VPN"
  default     = "key"
}

variable "uk_virtual_network_gateway_id" {
  description = "UK Virtual Network ID"
  default     = ""
}

variable "vnet2vnet_preshared_key" {
  description = "vNet-to-vNet Pre Shared Key"
  default     = ""
}

variable "vm_admin_username" {
  description = "Admin username for the deployed VMs"
  default     = "azureuser"
}

variable "ssh_public_key" {
    default = "ssh-public-key.pub"
}

variable "vm_admin_password" {
  description = "Admin password for the deployed vm VMs"
  default     = "--Password1--"
}

variable "frontend_vm_instances" {
  description = "The number of Web Frontend VM"
  default     = 1
}

variable "backend_vm_instances" {
  description = "The number of Backend VM"
  default     = 1
}

//Overriden in tfvars
variable "vpn_public_cert_name" {
  default = ""
}

//Overriden in tfvars
variable "vpn_public_cert" {
  description = "Public cert data"
  default     = ""
}

variable "public_ip_domain_name_label" {
  description = "(Optional) A domain name label"
  default     = ""
}

variable "sql_firewall_ip_rules" {
  description = "The start id and end ip of azurerm_sql_firewall_rule resource"
  type        = map

  default = {    
    "azure_services" = ["0.0.0.0", "0.0.0.0"] #Only allow Azure services - Documented in https://docs.microsoft.com/en-us/rest/api/sql/firewallrules/createorupdate
  }
}

variable "sql_admin_password" {
  description = "The admin password of SQL Server"  
}

variable "sql_virtual_network_allowed_subnets" {
  description = "A list of virtual networks that can access the sql server"
  type        = list
  default     = ["ClusterSubnet"]
}

variable "sql_dbs_to_create" {
  description = "A list of sql database to create on sql server"
  type        = list
  default     = ["Users"]
}

//Overriden in tfvars
variable "sql_dbs_env_to_create" {
  description = "A list of sql database to create on sql server"
  type        = list
  default     = ["DEV"]
}

variable "sql_db_spec" {
  description = "The edition of the database to be created. Applies only if create_mode is Default. Valid values are: Basic/Basic, Standard/S6 etc."
  type        = map

  default = {
    edition                = "Standard"
    requested_service_name = "S0"
    max_size               = "268435456000"
  }
}

variable "log_analytics_enabled" {
  description = "Do you want to enable Log Analytics agent on the VM"
  default     = "false"
}

variable "log_analytics_workspaceid" {
  description = "If log analytics extension is enabled, please provide a Workspace ID"
  default     = "empty"
}

variable "log_analytics_workspacekey" {
  description = "If log analytics extension is enabled, please provide a Workspace Key"
  default     = "empty"
}

variable "log_analytics_workspacesku" {
  description = "If log analytics extension is enabled, one of the following values: [Free PerNode Premium Standalone Standard Unlimited]"
  default     = "Free"
}

variable "service_map_enabled" {
  description = "Do you want to enable Log Analytics Service Map agent on the VM"
  default     = "false"
}

variable "load_balance_rules_http" {
  description = "Load balancer http/https rules"
  type        = map(list(string))

  default = {
    http  = ["80", "Tcp", "80"]
    https = ["443", "Tcp", "443"]
  }
}

variable "tanium_inbound_nsg_rule" {
  description = "Creates an in bound nsg rule"
  type        = map(string)

  default = {
    # In
    name = "allow_tanium_in"
    priority                = "4010"
    direction               = "Inbound"
    destination_port_range  = "17472"
    source_address_prefixes = "213.41.15.160"
    description             = "Allow Tanium"
  }
}

variable "cosmos_db_virtual_network_firewall_subnet_id" {
  type = list(string)

  default = [
    ""
  ]
}

variable "connect_vnet_to_aldi_hub" {
  description = "Connect the VNET to ALD SA Hub VNET"
  default     = true
}

variable "uk_vnet_location" {
  description = "The VNET location"
  default     = "West Europe"
}

variable "uk_vnet_resource_group" {
  description = "The UK Dev VNET resource group"
  default     = "aldi-hub_euw_rg_ntw"
}

#aldi-hub_vnet
variable "uk_vnet" {
  description = "The UK Dev VNET"
  default     = "aldi-hub_vnet"
}

variable "aldihub_virtual_network_id" {
  description = "ALD SA Hub Virtual Network ID"
  default     = ""
}

variable "private_vnet_rg" {
  default = ""
}

//Overriden in tfvars
variable "private_vnet" {
  default = ""
}

//Overriden in tfvars
variable "bastion_subnet" {
  default = "AzureBastionSubnet"
}

//Overriden in tfvars
variable "devopsToken" {
  default = "Azure Devops PAT"
}

//Overriden in tfvars
variable "agentPool" {
  default = ""
}

//Overriden in tfvars
variable "kubernetes_version" {
  default = "1.19.3"
}