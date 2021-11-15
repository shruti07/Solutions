# terraform-azurerm-network-security-group

Source: <https://github.com/Azure/terraform-azurerm-network-security-group>

Commit: <https://github.com/Azure/terraform-azurerm-network-security-group/tree/22cd2de63dfc9940ddb42ff94fff077370d0ebbf>

## Create a network security group

This Terraform module deploys a Network Security Group (NSG) in Azure and optionally attach it to the specified vnets.

This module is a complement to the [Azure Network](https://registry.terraform.io/modules/Azure/network/azurerm) module. Use the network_security_group_id from the output of this module to apply it to a subnet in the Azure Network module.
NOTE: We are working on adding the support for applying a NSG to a network interface directly as a future enhancement.

This module includes a a set of pre-defined rules for commonly used protocols (for example HTTP or ActiveDirectory) that can be used directly in their corresponding modules or as independent rules.

## Usage with the generic module

The following example demonstrate how to use the network-security-group module with a combination of predefined and custom rules.

```hcl
module "network-security-group" {
    source                     = "Azure/network-security-group/azurerm"
    resource_group_name        = "nsg-resource-group"
    location                   = "westus"
    security_group_name        = "nsg"
    predefined_rules           = [
      {
        name                   = "SSH"
        priority               = "500"
        source_address_prefix  = ["10.0.3.0/24"]
      },
      {
        name                   = "LDAP"
        source_port_range      = "1024-1026"
      }
    ]
    custom_rules               = [
      {
        name                   = "myhttp"
        priority               = "200"
        direction              = "Inbound"
        access                 = "Allow"
        protocol               = "tcp"
        destination_port_range = "8080"
        description            = "description-myhttp"
      }
    ]
    tags                       = {
                                   environment = "dev"
                                   costcenter  = "it"
                                 }
}
```

## Usage with the pre-defined module

The following example demonstrate how to use the pre-defined HTTP module with a custom rule for ssh.

```hcl
module "network-security-group" {
    source                     = "Azure/network-security-group/azurerm//modules/HTTP"
    resource_group_name        = "nsg-resource-group"
    location                   = "westus"
    security_group_name        = "nsg"
    custom_rules               = [
      {
        name                   = "ssh"
        priority               = "200"
        direction              = "Inbound"
        access                 = "Allow"
        protocol               = "tcp"
        destination_port_range = "22"
        source_address_prefix  = ["VirtualNetwork"]
        description            = "ssh-for-vm-management"
      }
    ]
    tags                       = {
                                  environment = "dev"
                                  costcenter  = "it"
                                 }
}
```
