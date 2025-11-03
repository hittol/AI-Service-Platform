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
    hub_to_aisvc_name               = var.hub_to_aisvc_name
    aisvce-to-hub_name              = var.aisvce-to-hub_name
    aoai_to_aisvc_name              = var.aoai_to_aisvc_name
    aisvce-to-aoai_name             = var.aisvce-to-aoai_name
    aoai_to_datastr_name            = var.aoai_to_datastr_name
    datastr-to-aoai_name            = var.datastr-to-aoai_name
    datastr_to_aisvc_name           = var.datastr_to_aisvc_name
    aisvce-to-datastr_name          = var.aisvce-to-datastr_name
    datastr_to_hub_name             = var.datastr_to_hub_name
    hub-to-datastr_name             = var.hub-to-datastr_name
    depends_on                      = [module.rg]      
}

module "vm" {
    source                          = "./Modules/vm"
    vm_name                         = var.vm_name
    location                        = var.location
    rg_name                         = module.rg.rg["HUBRG"].name
    storage_account_type            = var.storage_account_type
    ip_config_name                  = var.ip_config_name
    vnet-subnet_id                  = module.vnet.hub_subnet_ids["Jump_Subnet"]
    ip_address_allocation           = var.ip_address_allocation
    private_ip_address              = var.private_ip_address
    VM_Size                         = var.VM_Size
    vm_caching                      = var.vm_caching
    admin_username                  = var.admin_username
    UbuntuServer                    = var.UbuntuServer
    depends_on                      = [module.vnet]  
}

module "aoai" {
    source                          = "./Modules/aoai"
    rg_name                         = module.rg.rg["AOAIRG"].name
    location                        = var.location
    aoai_vnet_id                    = module.vnet.aoai-vnet_id
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
    rg_name                         = var.resource_group_name
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
    depends_on                      = [module.rg]
}

module "firewall" {
    source                          = "./modules/fw"
    rg_name                         = var.resource_group_name
    location                        = var.location
    fw_name                         = var.fw_name
    fw_sku                          = var.fw_sku
    routetable_name                 = var.routetable_name
    routetable_name_spoke           = var.routetable_name_spoke
    hub_vnet_id                     = module.vnet.hub_vnet_id
    hub_fw_subnet_id                = module.vnet.hub_subnet_ids["AzureFirewallSubnet"]
    hub_jump_subnet_id              = module.vnet.hub_subnet_ids["JumpSubnet"]
    spoke_subnet_id                 = module.vnet.spoke_subnet_ids["SpokeSubnet"]
    jumpvm_ip                       = module.vm.private_ip_address
    app_rule_collection_groups      = local.firewall_application_rules
    network_rule_collection_groups  = local.firewall_network_rules
    dnat_rule_name                  = var.dnat_rule_name
    dnat_protocols                  = var.dnat_protocols
    dnat_source_addresses           = var.dnat_source_addresses
    dnat_destination_ports          = var.dnat_destination_ports
    dnat_translated_port            = var.dnat_translated_port    
    depends_on                      = [module.vm] 
}