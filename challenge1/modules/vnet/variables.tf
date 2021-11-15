variable "address_space" {
  description = "The address space that is used by the virtual network."
  default     = "10.0.0.0/16"
}

# If no values specified, this defaults to Azure DNS 
variable "dns_servers" {
  description = "The DNS servers to be used with vNet."
  default     = []
}

variable "subnet_prefixes" {
  description = "The address prefix to use for the subnet."
  default     = ["10.0.1.0/24"]
}

variable "subnet_names" {
  description = "A list of public subnets inside the vNet."
  default     = ["DataSubnet", "ClusterSubnet","AzureBastionSubnet","GatewaySubnet","RouterSubnet"]
}

variable "subnet_ids" {
  description = "A map of subnet name to subnet ids"
  type        = map

  default = {
    subnet1 = "subnetId1"
    subnet2 = "subnetId2"
    subnet3 = "subnetId3"
    subnet4 = "subnetId4"
    subnet5 = "subnetId5"
  }
}

variable "nsg_ids" {
  description = "A map of subnet name to Network Security Group IDs"
  type        = map

  default = {
    subnet1 = "nsgid1"
    subnet2 = "nsgid2"
    subnet3 = "nsgid3"
    subnet4 = "nsgid4"
  }
}

variable "tags" {
  description = "The tags to associate with your network and subnets."
  type        = map

  default = {
    tag1 = ""
    tag2 = ""
  }
}

variable "vnet_subnets_service_endpoints" {
  description = "The list of Service endpoints to associate with the subnet. Possible values include: Microsoft.AzureActiveDirectory, Microsoft.AzureCosmosDB, Microsoft.EventHub, Microsoft.KeyVault, Microsoft.ServiceBus, Microsoft.Sql and Microsoft.Storage."
  type        = map

  default = {
    subnet1 = ["Microsoft.Sql"]
    subnet2 = ["Microsoft.Sql", "Microsoft.Storage"]
    subnet3 = ["Microsoft.Sql", "Microsoft.Storage"]
  }
}

variable "vnet_subnets_enable_privateendpoint" {
  description = "The list of private endpoint policy flag to associate with the subnet."
  type        = map

  default = {
    subnet1 = "false"
    subnet2 = "false"
    subnet3 = "false"
    subnet4 = "false"
    subnet5 = "false"
  }
}

//Overriden in tfvars
variable "private_vnet_rg" {
  default = ""
}

//Overriden in tfvars
variable "private_vnet" {
  default = ""
}

variable "aksroutingtable" {  
}

variable "resource_group_name" {
  description = "Default resource group name that the network will be created in."
  default     = ""
}

variable "location" {
  description = "The location/region where the core network will be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions"
  default     = "westus"
}

variable "vnet_name" {
  description = "Name of the vnet to create"
  default     = ""
}
