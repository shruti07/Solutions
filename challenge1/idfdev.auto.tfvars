
private_subscription_id = "7b895049-21a3-4867-9c2e-2f31514697f8"


public_subscription_id = "5657ecca-a92c-4e90-9d43-a2e3f0524947"


ad_client_app_id = "6455dcde-b0be-4a20-b872-ceafdc93388d"


ad_server_app_id = "fa8f4f05-bc2a-4f6e-9191-1a7165bbc12c"

ad_server_app_secret = "secret"

vpn_public_cert_name = "cert"

//Self signed certificate generated for specific environment
vpn_public_cert = "cert"

datasubnet_name = "DataSubnet"

clustersubnet_name = "ClusterSubnet"

gatewaysubnet_name= "GatewaySubnet"

routersubnet_name= "RouterSubnet"

bastionsubnet_name= "AzureBastionSubnet"

public_vnet_name= "dev-public-vnet"

public_vnet_rg= "dev-we-ntw"

env = "dev"

loc = "we"

appname = "demo"

teamcode = "test"

vm_count = {
     "fe"    = 1
     "be"    = 1
}

tags = {
    environment      = "dev"
    source           = "terraform"
}

vm_size = {
    "fe"    = "Standard_B2ms"
    "be"    = "Standard_B2ms"
}

bastion_subnet ="AzureBastionSubnet"

vnet_cidr = "193.200.23.0/24"

vnet_subnets = {  
  "DataSubnet"            = "193.200.23.96/27"
  "ClusterSubnet"         = "193.200.23.128/25"
  "GatewaySubnet"         = "193.200.23.48/28"
  "RouterSubnet"          = "193.200.23.64/29"
  "AzureBastionSubnet"    = "193.200.23.0/27"
}

sql_dbs_env_to_create = ["DEV"]

devopsToken = "token"

agentPool = "SelfHosted-agent"

kubernetes_version = "1.19.11"