#------------------------------------------------------------------------------
# SQL SERVERS AND DATABASES
#------------------------------------------------------------------------------

resource "azurerm_resource_group" "data" {
  name     = "${var.teamcode}-${var.appname}-${var.env}-${var.loc}-data"
  location = var.location
  tags     = var.tags
} 

resource "azurerm_sql_server" "sql" {
  name                         = "ald-${var.teamcode}-${var.appname}-${var.env}-${var.loc}-sql"
  resource_group_name          = "${azurerm_resource_group.data.name}"
  location                     = "${var.location}"
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "${var.sql_admin_password}"
  tags                         = "${var.tags}"
} 

resource "azurerm_sql_database" "db" {
  count                            = "${length(var.sql_dbs_env_to_create) * length(var.sql_dbs_to_create)}"
  name                             = "${var.sql_dbs_env_to_create[ceil(count.index / length(var.sql_dbs_to_create))]}.${var.sql_dbs_to_create[count.index % length(var.sql_dbs_to_create)]}"
  resource_group_name              = "${azurerm_resource_group.data.name}"
  location                         = "${var.location}"
  server_name                      = "${azurerm_sql_server.sql.name}"
  edition                          = "${lookup(var.sql_db_spec, "edition")}"
  requested_service_objective_name = "${lookup(var.sql_db_spec, "requested_service_name")}"
  max_size_bytes                   = "${lookup(var.sql_db_spec, "max_size")}"
  tags                             = "${var.tags}"
}

resource "azurerm_sql_firewall_rule" "sql" {
  name                = "${element(keys(var.sql_firewall_ip_rules), count.index)}"
  resource_group_name = "${azurerm_sql_server.sql.resource_group_name}"
  server_name         = "${azurerm_sql_server.sql.name}"
  start_ip_address    = "${element(var.sql_firewall_ip_rules[element(keys(var.sql_firewall_ip_rules), count.index)],0)}"
  end_ip_address      = "${element(var.sql_firewall_ip_rules[element(keys(var.sql_firewall_ip_rules), count.index)],1)}"
  count               = "${length(var.sql_firewall_ip_rules)}"
} 

resource "azurerm_private_endpoint" "sql" {
  name                = "ald-${var.teamcode}-${var.appname}-${var.env}-${var.loc}-pe-sql"
  location            = "${azurerm_resource_group.data.location}"
  resource_group_name = "${azurerm_resource_group.data.name}"
  subnet_id           = "${module.vnet.vnet_subnets_name_id_map["DataSubnet"]}"

  private_service_connection {
    name                            = "sql-privateserviceconnection"
    private_connection_resource_id  = "${azurerm_sql_server.sql.id}"
    is_manual_connection            = false
    subresource_names               = ["sqlServer"]
  }
} 

#------------------------------------------------------------------------------
# STORAGE ACCOUNTS
#------------------------------------------------------------------------------

resource "azurerm_storage_account" "akssa" {  
  name                     = "ald${var.teamcode}${var.appname}${var.env}${var.loc}app"
  resource_group_name      = "${azurerm_resource_group.data.name}" 
  location                 = "${azurerm_resource_group.data.location}"
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags                     = "${var.tags}"
  network_rules {
    default_action             = "Deny"
    ip_rules                   = []
    virtual_network_subnet_ids = [module.vnet.vnet_subnets_name_id_map["AzureBastionSubnet"]]
    bypass                     = []
 }
}

resource "azurerm_private_endpoint" "asb" {
  name                = "ald-${var.teamcode}-${var.appname}-${var.env}-${var.loc}-pe-asset-sa-blob"
  location            = "${azurerm_resource_group.data.location}"
  resource_group_name = "${azurerm_resource_group.data.name}"
  subnet_id           = "${module.vnet.vnet_subnets_name_id_map["DataSubnet"]}"

  private_service_connection {
    name                            = "asset-sa-privateserviceconnection"
    private_connection_resource_id  = "${azurerm_storage_account.akssa.id}"
    is_manual_connection            = false
    subresource_names               =["blob"]
  }
}

resource "azurerm_private_endpoint" "ast" {
  name                = "ald-${var.teamcode}-${var.appname}-${var.env}-${var.loc}-pe-asset-sa-table"
  location            = "${azurerm_resource_group.data.location}"
  resource_group_name = "${azurerm_resource_group.data.name}"
  subnet_id           = "${module.vnet.vnet_subnets_name_id_map["DataSubnet"]}"

  private_service_connection {
    name                            = "asset-sa-privateserviceconnection"
    private_connection_resource_id  = "${azurerm_storage_account.akssa.id}"
    is_manual_connection            = false
    subresource_names               =["table"]
  }
}

resource "azurerm_private_endpoint" "asq" {
  name                = "ald-${var.teamcode}-${var.appname}-${var.env}-${var.loc}-pe-asset-sa-queue"
  location            = "${azurerm_resource_group.data.location}"
  resource_group_name = "${azurerm_resource_group.data.name}"
  subnet_id           = "${module.vnet.vnet_subnets_name_id_map["DataSubnet"]}"

  private_service_connection {
    name                            = "asset-sa-privateserviceconnection"
    private_connection_resource_id  = "${azurerm_storage_account.akssa.id}"
    is_manual_connection            = false
    subresource_names               =["queue"]
  }
}

resource "azurerm_storage_account" "customer" {  
  #count                    = "${length(var.storage_ac_to_create)}"
  name                     = "ald${var.teamcode}${var.appname}${var.env}${var.loc}cust"
  resource_group_name      = "${azurerm_resource_group.data.name}" 
  location                 = "${var.location}"
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags                     = "${var.tags}"
  network_rules {
    default_action             = "Deny"
    ip_rules                   = []
    virtual_network_subnet_ids = [module.vnet.vnet_subnets_name_id_map["AzureBastionSubnet"]]
    bypass                     = []
  }
}

  resource "azurerm_private_endpoint" "csb" {
  name                = "ald-${var.teamcode}-${var.appname}-${var.env}-${var.loc}-pe-cust-sa-blob"
  location            = "${azurerm_resource_group.data.location}"
  resource_group_name = "${azurerm_resource_group.data.name}"
  subnet_id           = "${module.vnet.vnet_subnets_name_id_map["DataSubnet"]}"

  private_service_connection {
    name                            = "cust-sa-privateserviceconnection"
    private_connection_resource_id  = "${azurerm_storage_account.customer.id}"
    is_manual_connection            = false
    subresource_names               = ["blob"]
  }
}

  resource "azurerm_private_endpoint" "cst" {
  name                = "ald-${var.teamcode}-${var.appname}-${var.env}-${var.loc}-pe-cust-sa-table"
  location            = "${azurerm_resource_group.data.location}"
  resource_group_name = "${azurerm_resource_group.data.name}"
  subnet_id           = "${module.vnet.vnet_subnets_name_id_map["DataSubnet"]}"

  private_service_connection {
    name                            = "cust-sa-privateserviceconnection"
    private_connection_resource_id  = "${azurerm_storage_account.customer.id}"
    is_manual_connection            = false
    subresource_names               = ["table"]
  }
}

  resource "azurerm_private_endpoint" "csq" {
  name                = "ald-${var.teamcode}-${var.appname}-${var.env}-${var.loc}-pe-cust-sa-queue"
  location            = "${azurerm_resource_group.data.location}"
  resource_group_name = "${azurerm_resource_group.data.name}"
  subnet_id           = "${module.vnet.vnet_subnets_name_id_map["DataSubnet"]}"

  private_service_connection {
    name                            = "cust-sa-privateserviceconnection"
    private_connection_resource_id  = "${azurerm_storage_account.customer.id}"
    is_manual_connection            = false
    subresource_names               = ["queue"]
  }
}

resource "azurerm_private_dns_zone" "dnsblob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.ntw-vnet.name
}

resource "azurerm_private_dns_a_record" "dnsbrecapp" {
  name                = "aldocidfdevweapp"
  zone_name           = azurerm_private_dns_zone.dnsblob.name
  resource_group_name = azurerm_resource_group.ntw-vnet.name
  ttl                 = 10
  records             = azurerm_private_endpoint.asb.id
}

resource "azurerm_private_dns_a_record" "dnsbreccust" {
  name                = "aldocidfdevwecust"
  zone_name           = azurerm_private_dns_zone.dnsblob.name
  resource_group_name = azurerm_resource_group.ntw-vnet.name
  ttl                 = 10
  records             = azurerm_private_endpoint.csb.id
}

resource "azurerm_private_dns_zone" "dnstable" {
  name                = "privatelink.table.core.windows.net"
  resource_group_name = azurerm_resource_group.ntw-vnet.name
}

resource "azurerm_private_dns_a_record" "dnstrecapp" {
  name                = "aldocidfdevweapp"
  zone_name           = azurerm_private_dns_zone.dnstable.name
  resource_group_name = azurerm_resource_group.ntw-vnet.name
  ttl                 = 10
  records             = azurerm_private_endpoint.ast.id
}

resource "azurerm_private_dns_a_record" "dnstreccust" {
  name                = "aldocidfdevwecust"
  zone_name           = azurerm_private_dns_zone.dnstable.name
  resource_group_name = azurerm_resource_group.ntw-vnet.name
  ttl                 = 10
  records             = azurerm_private_endpoint.cst.id
}

resource "azurerm_private_dns_zone" "dnsqueue" {
  name                = "privatelink.queue.core.windows.net"
  resource_group_name = azurerm_resource_group.ntw-vnet.name
}

resource "azurerm_private_dns_a_record" "dnsqrecapp" {
  name                = "aldocidfdevweapp"
  zone_name           = azurerm_private_dns_zone.dnsqueue.name
  resource_group_name = azurerm_resource_group.ntw-vnet.name
  ttl                 = 10
  records             = azurerm_private_endpoint.asq.id
}

resource "azurerm_private_dns_a_record" "dnsqreccust" {
  name                = "aldocidfdevwecust"
  zone_name           = azurerm_private_dns_zone.dnsqueue.name
  resource_group_name = azurerm_resource_group.ntw-vnet.name
  ttl                 = 10
  records             = azurerm_private_endpoint.csq.id
}

resource "azurerm_private_dns_zone" "dnsdb" {
  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.ntw-vnet.name
}

resource "azurerm_private_dns_a_record" "dnsqrecdb" {
  name                = "ald-oc-idf-dev-we-sql"
  zone_name           = azurerm_private_dns_zone.dnsdb.name
  resource_group_name = azurerm_resource_group.ntw-vnet.name
  ttl                 = 10
  records             = azurerm_private_endpoint.sql.id
}

#------------------------------------------------------------------------------
# Key Vault Resource
#------------------------------------------------------------------------------

resource "azurerm_key_vault" "keyvault" {
  name                        = "ald-${var.teamcode}-${var.appname}-${var.env}-${var.loc}-vault"
  location                    = azurerm_resource_group.data.location
  resource_group_name         = azurerm_resource_group.data.name
  enabled_for_disk_encryption = true
  tenant_id                   = "${var.tenant_id}"
  sku_name = "standard"
  # soft_delete_enabled = false
  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    virtual_network_subnet_ids = [module.vnet.vnet_subnets_name_id_map["AzureBastionSubnet"]]
  }
   tags = var.tags
  }
  
  resource "azurerm_private_endpoint" "kv" {
  name                = "ald-${var.teamcode}-${var.appname}-${var.env}-${var.loc}-pe-kv"
  location            = "${azurerm_resource_group.data.location}"
  resource_group_name = "${azurerm_resource_group.data.name}"
  subnet_id           = "${module.vnet.vnet_subnets_name_id_map["DataSubnet"]}"
 
  private_service_connection {
    name                           = "kv-privateserviceconnection"
    private_connection_resource_id = "${azurerm_key_vault.keyvault.id}"
    is_manual_connection           = false
    subresource_names              =["vault"]
  }
} 

resource "azurerm_private_dns_zone" "dnsvault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.ntw-vnet.name
}

resource "azurerm_private_dns_a_record" "dnsvrec" {
  name                = "ald-oc-idf-dev-we-vault"
  zone_name           = azurerm_private_dns_zone.dnsvault.name
  resource_group_name = azurerm_resource_group.ntw-vnet.name
  ttl                 = 10
  records             = azurerm_private_endpoint.kv.id
}

resource "azurerm_private_dns_zone" "idpdev" {
  name                = "idp.aldidev.com"
  resource_group_name = azurerm_resource_group.ntw-vnet.name
}

#------------------------------------------------------------------------------
# COSMOS DB
#------------------------------------------------------------------------------

locals {
  
  # IP Range Filter here is to allow azure portal access
  cosmosdb_ip_range_azure = [
    "104.42.195.92/32",
    "40.76.54.131/32",
  ]
} 
resource "azurerm_cosmosdb_account" "db" {
  # count               = "${length(var.sql_dbs_env_to_create)}"
  name                = "ald-${var.teamcode}-${var.appname}-${var.env}-${var.loc}-nosql"
  location            = "${var.cosmosdb_location}"
  resource_group_name = "${azurerm_resource_group.data.name}"
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"
  enable_automatic_failover = "${var.enable_cosmos_db_failover}"
  is_virtual_network_filter_enabled = true
  ip_range_filter = "${join(",",concat(local.cosmosdb_ip_range_azure,var.sql_firewall_ip_rules["azure_services"]))}"
  virtual_network_rule {
    id           = "${module.vnet.vnet_subnets_name_id_map["DataSubnet"]}"
  }
  consistency_policy {
    consistency_level       = "Session"
    max_interval_in_seconds = "301"
    max_staleness_prefix    = "100001"
  }

  geo_location {
    location          = "${var.failover_location}"
    failover_priority = 1
  }

  geo_location {
    location          = "${var.cosmosdb_location}"
    failover_priority = 0
  }
}

resource "azurerm_private_endpoint" "cosmos" {
  name                = "ald-${var.teamcode}-${var.appname}-${var.env}-${var.loc}-pe-nosql"
  location            = "${azurerm_resource_group.data.location}"
  resource_group_name = "${azurerm_resource_group.data.name}"
  subnet_id           = "${module.vnet.vnet_subnets_name_id_map["DataSubnet"]}"

  private_service_connection {
    name                           = "cosmos-pe-privateserviceconnection"
    private_connection_resource_id = "${azurerm_cosmosdb_account.db.id}"
    is_manual_connection           = false
    subresource_names              = ["Sql"]
  }
}