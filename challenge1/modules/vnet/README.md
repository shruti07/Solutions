
terraform-azurerm-vnet
======================================

Source: <https://github.com/Azure/terraform-azurerm-vnet>

Commit: <https://github.com/Azure/terraform-azurerm-vnet/tree/3935d941ce1321fa55db8a5d4c21998a9d5a1f60>

Create a basic virtual network in Azure
==============================================================================

This Terraform module deploys a Virtual Network in Azure with a subnet or a set of subnets passed in as input parameters.

The module does not create nor expose a security group. This would need to be defined separately as additional security rules on subnets in the deployed network.

Usage
-----

```hcl
module "vnet" {
    source              = "Azure/vnet/azurerm"
    resource_group_name = "myapp"
    location            = "westus"
    address_space       = "10.0.0.0/16"
    subnet_prefixes     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    subnet_names        = ["subnet1", "subnet2", "subnet3"]

    tags                = {
                            environment = "dev"
                            costcenter  = "it"
                          }
}

```

Example adding a network security rule for SSH
-----------------------------------------------

```hcl
variable "resource_group_name" { }

module "vnet" {
  source              = "Azure/vnet/azurerm"
  resource_group_name = "${var.resource_group_name}"
  location            = "westus"
  address_space       = "10.0.0.0/16"
  subnet_prefixes     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  subnet_names        = ["subnet1", "subnet2", "subnet3"]

  tags = {
    environment = "dev"
    costcenter  = "it"
  }
}

resource "azurerm_subnet" "subnet" {
  name  = "subnet1"
  address_prefix = "10.0.1.0/24"
  resource_group_name = "${var.resource_group_name}"
  virtual_network_name = "acctvnet"
  network_security_group_id = "${azurerm_network_security_group.ssh.id}"
}

resource "azurerm_network_security_group" "ssh" {
  depends_on          = ["module.vnet"]
  name                = "ssh"
  location            = "westus"
  resource_group_name = "${var.resource_group_name}"

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}
```