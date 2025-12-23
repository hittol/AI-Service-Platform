# ===================================================================
# module area
# ===================================================================

module "rg" {
    source      = "./Modules/rg"
    rg_setting  = var.rg_setting
}
module "vnet" {
    source                          = "./Modules/vnet"
    location                        = var.location
    Hub_rg_name                     = module.rg.rg["HUBRG"].name
    AISVC_rg_name                   = module.rg.rg["AISVCRG"].name
    DataSTR_rg_name                 = module.rg.rg["DataSTRRG"].name
    AOAI_rg_name                    = module.rg.rg["AOAIRG"].name
    hub_vnet_name                   = var.hub_vnet_name
    hub_vnet_address_space          = var.hub_vnet_address_space
    hub_subnets                     = var.hub_subnets
    aisvc_vnet_name                 = var.aisvc_vnet_name
    aisvc_vnet_address_space        = var.aisvc_vnet_address_space
    aisvc_subnets                   = var.aisvc_subnets
    aoai_vnet_name                  = var.aoai_vnet_name
    aoai_vnet_address_space         = var.aoai_vnet_address_space
    aoai_subnets                    = var.aoai_subnets
    datastr_vnet_name               = var.datastr_vnet_name
    datastr_vnet_address_space      = var.datastr_vnet_address_space
    datastr_subnets                 = var.datastr_subnets
    network_security_groups_rule    = var.nsg_rule
    apim_intg_nsg_name              = var.apim_intg_nsg_name
    aoai_to_aisvc_name              = var.aoai_to_aisvc_name
    aisvce-to-aoai_name             = var.aisvce-to-aoai_name
    aoai_to_datastr_name            = var.aoai_to_datastr_name
    datastr-to-aoai_name            = var.datastr-to-aoai_name
    datastr_to_aisvc_name           = var.datastr_to_aisvc_name
    aisvce-to-datastr_name          = var.aisvce-to-datastr_name
    depends_on                      = [module.rg]      
}

module "vm" {
    source                          = "./Modules/vm"
    vm_name                         = var.vm_name
    location                        = var.location
    rg_name                         = module.rg.rg["HUBRG"].name
    storage_account_type            = var.storage_account_type
    ip_config_name                  = var.ip_config_name
    vnet-subnet_id                  = module.vnet.hub_subnet_ids["JumpSubnet"]
    ip_address_allocation           = var.ip_address_allocation
    private_ip_address              = var.private_ip_address
    VM_Size                         = var.VM_Size
    vm_caching                      = var.vm_caching
    admin_username                  = var.admin_username
    UbuntuServer                    = var.UbuntuServer
    depends_on                      = [module.vnet]  
}

module "appservice" {
    source = "./modules/appservice"
    rg_hub_name                     = module.rg.rg["HUBRG"].name
    hub_vnet_id                     = module.vnet.hub_vnet_id
    aisvc_vnet_id                   = module.vnet.aisvc_vnet_id
    app_rg_name                     = module.rg.rg["AISVCRG"].name
    front_inte_subnet               = module.vnet.aisvc_subnet_ids["FrontINTEGSubnet"]
    back_inte_subnet                = module.vnet.aisvc_subnet_ids["BackINTEGSubnet"]
    app_pe_subnet                   = module.vnet.aisvc_subnet_ids["PESubnet"]
    location                        = var.location
    identity_name                   = var.acr_identity_name
    acr_name                        = var.acr_name
    app_plan_name                   = var.app_plan_name
    plan_os                         = var.plan_os
    plan_sku                        = var.plan_sku
    front_name                      = var.front_name
    back_name                       = var.back_name
    depends_on                      = [module.vm]
}

module "aoai" {
    source                          = "./Modules/aoai"
    rg_name                         = module.rg.rg["AOAIRG"].name
    location                        = var.location
    aoai_vnet_id                    = module.vnet.aoai_vnet_id
    aoai_subnet_id                  = module.vnet.aoai_subnet_ids["PESubnet"]
    aoai_instance                   = var.aoai_instance
    depends_on                      = [module.vnet]
}

module "apim" {
    source = "./modules/apim"
    rg_name                         = module.rg.rg["AOAIRG"].name
    rg_id                           = module.rg.rg["AOAIRG"].id
    location                        = var.location
    identity_name                   = var.identity_name
    apim_name                       = var.apim_name
    apim_sku                        = var.apim_sku
    publisher_name                  = var.publisher_name
    publisher_email                 = var.publisher_email
    entra_auth                      = var.entra_auth
    aoai_backend                    = local.aoai_backend
    apimpublicaccess                = var.apimpublicaccess
    openapi_name                    = var.openapi_name
    openapi_protocols               = var.openapi_protocols
    firewall_trigger                = module.firewall.firewall_id
    apim_pe_subnet_id               = module.vnet.aoai_subnet_ids["PESubnet"]
    apim_integration_subnet_id      = module.vnet.aoai_subnet_ids["APIMINTGSubnet"]
    hub_vnet_id                     = module.vnet.hub_vnet_id
    openapi_header                  = var.openapi_header 
    openapi_path                    = var.openapi_path
    depends_on                      = [module.aoai]   
}

module "vpngateway" {
    source                          = "./modules/vpngateway"
    rg_name                         = module.rg.rg["HUBRG"].name
    location                        = var.location
    vpngateway_name                 = var.vpngateway_name
    active_active_enabled           = var.active_active_enabled
    bgp_enabled                     = var.bgp_enabled
    localgateway_name               = var.localgateway_name  
    vpn_shared_key                  = var.vpn_shared_key
    public_ip_allocation_method     = var.public_ip_allocation_method
    private_ip_allocation_method    = var.private_ip_allocation_method
    on_premise_public_ip            = var.on_premise_public_ip
    on_premise_address_space        = var.on_premise_address_space
    vpngateway_connection_name      = var.vpngateway_connection_name
    vpn_sku                         = var.vpn_sku
    hub_vnet_id                     = module.vnet.hub_vnet_id
    hub_subnet_id                   = module.vnet.hub_subnet_ids["GatewaySubnet"]
    depends_on                      = [module.vnet]
}

module "firewall" {
    source                          = "./modules/fw"
    rg_name                         = module.rg.rg["HUBRG"].name
    location                        = var.location
    fw_name                         = var.fw_name
    fw_sku                          = var.fw_sku
    routetable_name_JUMP            = var.routetable_name_JUMP
    routetable_name_AOAI            = var.routetable_name_AOAI
    routetable_name_AISVC           = var.routetable_name_AISVC
    hub_vnet_id                     = module.vnet.hub_vnet_id
    hub_fw_subnet_id                = module.vnet.hub_subnet_ids["AzureFirewallSubnet"]
    hub_manfw_subnet_id             = module.vnet.hub_subnet_ids["AzureFirewallManagementSubnet"]
    jump_subnet_id                  = module.vnet.hub_subnet_ids["JumpSubnet"]
    apim_subnet_id                  = module.vnet.aoai_subnet_ids["APIMINTGSubnet"]
    app_subnet_id                   = module.vnet.aisvc_subnet_ids["AppINTEGSubnet"]
    aks_subnet_id                   = module.vnet.aisvc_subnet_ids["AKSINTEGSubnet"]
    jumpvm_ip                       = module.vm.private_ip_address
    app_rule_collection_groups      = local.firewall_application_rules
    network_rule_collection_groups  = local.firewall_network_rules
    depends_on                      = [module.vpngateway]
}

module "peering" {
    source                          = "./Modules/peering"
    Hub_rg_name                     = module.rg.rg["HUBRG"].name
    hub_vnet_id                     = module.vnet.hub_vnet_id
    hub_vnet_name                   = module.vnet.hub_vnet_name
    AISVC_rg_name                   = module.rg.rg["AISVCRG"].name
    AISVC_vnet_id                   = module.vnet.aisvc_vnet_id
    AISVC_vnet_name                 = module.vnet.aisvc_vnet_name
    DataSTR_rg_name                 = module.rg.rg["DataSTRRG"].name
    DataSTR_vnet_id                 = module.vnet.datastr_vnet_id
    DataSTR_vnet_name               = module.vnet.datastr_vnet_name
    hub_to_aisvc_name               = var.hub_to_aisvc_name
    aisvce-to-hub_name              = var.aisvce-to-hub_name
    datastr_to_hub_name             = var.datastr_to_hub_name
    hub-to-datastr_name             = var.hub-to-datastr_name
    depends_on                      = [module.firewall]
}

module "appgw" {
    source                          = "./Modules/appgw"
    rg_name                         = module.rg.rg["HUBRG"].name
    location                        = var.location
    appgw_name                      = var.appgw_name
    waf_name                        = var.waf_name
    appgw-subnet_id                 = module.vnet.hub_subnet_ids["ApplicationGatewaySubnet"]
    app_pe_ipaddress                = module.appservice.private_ip_address
    depends_on                      = [module.peering]
}