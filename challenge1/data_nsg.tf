#------------------------------------------------------------------------------
# Data Subnet Network Security Group
#------------------------------------------------------------------------------

module "data_nsg" {
  source              = "./modules/network-security-group"
  resource_group_name = "${azurerm_resource_group.nsg.name}"
  location            = var.location
  security_group_name = "ald-${var.teamcode}-${var.appname}-${var.env}-${var.loc}-data-nsg"
  subnet_id           = "${module.vnet.vnet_subnets_name_id_map["DataSubnet"]}"
  tags = var.tags
}