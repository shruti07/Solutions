#------------------------------------------------------------------------------
#Private AKS Cluster Network Security Group
#------------------------------------------------------------------------------

module "Cluster_nsg" {
  source              = "./modules/network-security-group"
  resource_group_name = "${azurerm_resource_group.nsg.name}"
  location            = var.location
  security_group_name = "ald-${var.teamcode}-${var.appname}-${var.env}-${var.loc}-cluster-nsg"
  subnet_id           = "${module.vnet.vnet_subnets_name_id_map["ClusterSubnet"]}"

  custom_rules = [
    {
      # In
      name                       = "allow_mountebank_in"
      priority                   = "544"
      direction                  = "Inbound"
      destination_port_range     = "2525,6004,6005,6006,6007"
      description                = "Allow mountebank communication"
    },
    {
      # Out
      name                       = "allow_mountebank_out"
      priority                   = "100"
      direction                  = "Outbound"
      destination_port_range     = "1433,2525,6004,6005,6006,6007"
      description                = "Allow communication from mounebank"
    },
    
]
  tags = var.tags
}
