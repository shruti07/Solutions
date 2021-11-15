#Azure Generic vNet Module
#https://github.com/Azure/terraform-azurerm-vnet/blob/master/main.tf

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.vnet_name}"
  location            = "${var.location}"
  address_space       = ["${var.address_space}"]
  resource_group_name = "${var.resource_group_name}"
  dns_servers         = "${var.dns_servers}"
  tags                = "${var.tags}"
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.subnet_names[count.index]}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  resource_group_name  = "${var.resource_group_name}"
  address_prefix       = "${var.subnet_prefixes[count.index]}"
  count                = "${length(var.subnet_names)}"
  # network_security_group_id = "${lookup(var.nsg_ids,var.subnet_names[count.index],"")}"
  enforce_private_link_endpoint_network_policies  = "${var.vnet_subnets_enable_privateendpoint[var.subnet_names[count.index]]}"
  service_endpoints    = "${var.vnet_subnets_service_endpoints[var.subnet_names[count.index]]}"
}