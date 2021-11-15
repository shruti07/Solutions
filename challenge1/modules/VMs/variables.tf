variable "resource_group_name" {
  description = "The name of the resource group in which the resources will be created"
}

variable "location" {
  description = "The location/region where the virtual network is created. Changing this forces a new resource to be created."
}

variable "vnet_subnet_id" {
  description = "The subnet id of the virtual network where the virtual machines will reside."
}

variable "admin_password" {
  description = "The admin password to be used on the VMSS that will be deployed. The password must meet the complexity requirements of Azure"
  default     = ""
}

variable "admin_username" {
  description = "The admin username of the VM that will be deployed"
  default     = "azureuser"
}

variable "storage_account_type" {
  description = "Defines the type of storage account to be created. Valid options are Standard_LRS, Standard_ZRS, Standard_GRS, Standard_RAGRS, Premium_LRS."
  default     = "Premium_LRS"
}

variable "vm_size" {
  description = "Specifies the size of the virtual machine."
  default     = "Standard_DS1_V2"
}

variable "nb_instances" {
  description = "Specify the number of vm instances"
  default     = "1"
}

variable "vm_hostname" {
  description = "local name of the VM"
  default     = "myvm"
}

variable "timezone" {
  description = "Azure timezone for the VM"
  default     = "Romance Standard Time" #http://jackstromberg.com/2017/01/list-of-time-zones-consumed-by-azure/
}

variable "tags" {
  type        ="map"
  description = "A map of the tags to use on the resources that are deployed with this module."

  default = {
    source = "terraform"
  }
}

variable "delete_os_disk_on_termination" {
  description = "Delete os when machine is terminated"
  default     = "true"
}

variable "delete_data_disk_on_termination" {
  description = "Delete datadisk when machine is terminated"
  default     = "true"
}

variable "data_sa_type" {
  description = "Data Disk Storage Account type"
  default     = "Standard_LRS"
}

variable "data_disk_size_gb" {
  description = "Storage data disk size size"
  default     = ""
}

variable "boot_diagnostics" {
  description = "(Optional) Enable or Disable boot diagnostics"
  default     = "false"
}

variable "boot_diagnostics_sa_type" {
  description = "(Optional) Storage account type for boot diagnostics"
  default     = "Standard_LRS"
}

variable "load_balancer_backend_address_pools_ids" {
  description = "The loadbalancer ID for the NIC interface"
  type        = "list"
  default     = []
}

variable "app_name" {
  description = "Server role "
  default     = "none"
}

variable "app_env" {
  description = "Server role "
  default     = "dev"
}

variable "octopus" {
  description = "Octopus Server"
  type        = "map"
  default     = {}
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

variable "service_map_enabled" {
  description = "Do you want to enable Log Analytics Service Map agent on the VM"
  default     = "false"
}

variable "add_public_ip" {
  description = "Enables a public ip for VM - 'true' or 'false' value"
  default     = false
}

variable "prefix" {
  description = "The prefix for creating resources"
}

variable "vmCode" {
  description = "The type of vm to create, E.g. be, in, fe"
}

variable "devopsToken" {
  description = "The Azure Devops Personal Access Token with which the hosted Azure Devops Agent will connect to the agent pool"
}

variable "agentPool" {
  description = "The name of the Azure Devops agent pool that the Azure pipeline agent will run in"
}