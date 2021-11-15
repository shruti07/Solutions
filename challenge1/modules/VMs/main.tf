#Resources

provider "random" {
  version = "~> 2.2.0"
}

resource "random_id" "vm-sa" {
  keepers = {
    vm_hostname = "${var.vm_hostname}"
  }

  byte_length = 6
}

resource "azurerm_storage_account" "vm-sa" {
  count                    = var.boot_diagnostics == "true" ? 1 : 0
  name                     = "bootdiag${lower(random_id.vm-sa.hex)}"
  location                 = var.location
  resource_group_name      = var.resource_group_name
  account_tier             = element(split("_", var.boot_diagnostics_sa_type), 0)
  account_replication_type = element(split("_", var.boot_diagnostics_sa_type), 1)
  tags                     = "${var.tags}"
}

resource "azurerm_availability_set" "vm" {
  name                         = "${var.prefix}-avset-${var.vmCode}"
  location                     = var.location
  resource_group_name          = var.resource_group_name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
  tags                         = "${var.tags}"
}

resource "azurerm_public_ip" "vm" {
  count               = "${var.add_public_ip == "true" ? 1 : 0}"
  name                = "${var.prefix}-ip-${var.vmCode}${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  tags                = "${var.tags}"
}

locals {
  public_ips = concat(list(""), azurerm_public_ip.vm.*.id)
}

resource "azurerm_network_interface" "vm" {
  count               = var.nb_instances
  name                = "${var.prefix}-nic-${var.vmCode}${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig${count.index}"
    subnet_id                     = var.vnet_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = length(local.public_ips) == 1 ? "" : element(local.public_ips, count.index + 1)
  }

  tags = "${var.tags}"
}

data "vmSoftware" "vm_software" {
  template = file("${path.module}/files/FirstLogonCommands.xml")

  vars = {
    devopsToken = var.devopsToken
    agentPool = var.agentPool
  }
}

resource "azurerm_virtual_machine" "vm" {
  count                            = var.nb_instances
  name                             = "${var.vm_hostname}${var.vmCode}${count.index}"
  resource_group_name              = var.resource_group_name
  location                         = var.location
  availability_set_id              = azurerm_availability_set.vm.id
  vm_size                          = var.vm_size
  network_interface_ids            = ["${element(azurerm_network_interface.vm.*.id, count.index)}"]
  delete_os_disk_on_termination    = var.delete_os_disk_on_termination
  delete_data_disks_on_termination = var.delete_data_disk_on_termination

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.prefix}-osdsk-${var.vmCode}${count.index}"
    create_option     = "FromImage"
    caching           = "ReadWrite"
    managed_disk_type = "${var.storage_account_type}"
  }

  identity {
    type = "SystemAssigned"
  }

  os_profile {
    computer_name  = "${var.vm_hostname}-${var.vmCode}${count.index}"
    admin_username = var.admin_username
    admin_password = var.admin_password
    custom_data    = base64encode("Param($app_name = \"${var.app_name}\", $vm_hostname = \"${var.vm_hostname}-${var.vmCode}${count.index}\") ${file("${path.module}/files/init.ps1")}")
  }

  os_profile_windows_config {
    provision_vm_agent        = true
    timezone                  = var.timezone
    enable_automatic_upgrades = true

    additional_unattend_config {
      pass         = "oobeSystem"
      component    = "Microsoft-Windows-Shell-Setup"
      setting_name = "AutoLogon"
      content      = "<AutoLogon><Password><Value>${var.admin_password}</Value></Password><Enabled>true</Enabled><LogonCount>1</LogonCount><Username>${var.admin_username}</Username></AutoLogon>"
    }

    additional_unattend_config {
      pass         = "oobeSystem"
      component    = "Microsoft-Windows-Shell-Setup"
      setting_name = "FirstLogonCommands"
      content      = data.vmSoftware.rendered
    }
  }

  boot_diagnostics {
    enabled     = "${var.boot_diagnostics}"
    storage_uri = "${var.boot_diagnostics == "true" ? join(",", azurerm_storage_account.vm-sa.*.primary_blob_endpoint) : ""}"
  }

  tags = "${var.tags}"
}