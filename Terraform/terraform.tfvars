# ===================================================================
# Resource Group Variables
# ===================================================================

location = "koreacentral"

rg_setting = {
  "HUBRG" = {
    name     = "rg-hub"
    location = "koreacentral"
  },  
  "AISVCRG" = {
    name     = "rg-aisvc"
    location = "koreacentral"
  },  
  "DataSTRRG" = {
    name     = "rg-datastr"
    location = "koreacentral"
  },
  "AOAIRG" = {
    name     = "rg-aoai"
    location = "koreacentral"
  } 
}


# ===================================================================
# VNET Variables
# ===================================================================

hub_vnet_name               = "hub-vnet"
hub_vnet_address_space      = ["10.0.0.0/23"]
hub_subnets = {
    "JumpSubnet" = {
      address_prefixes                = ["10.0.0.0/27"]
      nsg_key                         = "hub-nsg"
    },
    "GatewaySubnet"                   = {
      address_prefixes                = ["10.0.0.32/27"]
    },
    "AzureFirewallSubnet"             = {
      address_prefixes                = ["10.0.0.64/26"]
    },
    "AzureFirewallManagementSubnet"   = {
      address_prefixes                = ["10.0.0.128/26"]
    },
    "ApplicationGatewaySubnet"        = {
      address_prefixes                = ["10.0.1.0/24"]
    },
}

aisvc_vnet_name                         = "aisvc-vnet"
aisvc_vnet_address_space                = ["192.168.0.0/22"]
aisvc_subnets = {
    "FrontINTEGSubnet" = {
      address_prefixes                  = ["192.168.0.0/24"]
      default_outbound_access_enabled   = false
    },    
    "BackINTEGSubnet" = {
      address_prefixes                  = ["192.168.1.0/24"]
      default_outbound_access_enabled   = false
    },
    "PESubnet" = {
      address_prefixes                  = ["192.168.2.0/24"]
      default_outbound_access_enabled   = false
    }
}

aoai_vnet_name                         = "aoai-vnet"
aoai_vnet_address_space                = ["192.168.10.0/23"]
aoai_subnets = {
    "PESubnet" = {
      address_prefixes                  = ["192.168.10.0/24"]
      default_outbound_access_enabled   = false
    },
    "APIMINTGSubnet" = {
      address_prefixes                  = ["192.168.11.0/24"]
      default_outbound_access_enabled   = false
      service_delegation_name           = "Microsoft.Web/serverFarms"
    }
}

datastr_vnet_name                      = "datastr-vnet"
datastr_vnet_address_space             = ["192.168.20.0/23"]
datastr_subnets = {
    "PESubnet" = {
      address_prefixes                  = ["192.168.20.0/24"]
      default_outbound_access_enabled   = false
    }
}

nsg_rule    = {
  "hub-nsg" = {
    rules = [
      {
        name                       = "AllowRDPFromAdmin"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        destination_port_range     = "3389"
        source_address_prefix      = "*"
      }
    ]
  }
}
apim_intg_nsg_name  = "apim-nsg"

hub_to_aisvc_name       = "hub_to_aisvc" 
aisvce-to-hub_name      = "aisvc-to-hub" 
aoai_to_aisvc_name      = "aoai_to_aisvc" 
aisvce-to-aoai_name     = "aisvc-to-aoai" 
aoai_to_datastr_name    = "aoai_to_datastr" 
datastr-to-aoai_name    = "datastr-to-aoai"
datastr_to_aisvc_name   = "datastr_to_aisvc" 
aisvce-to-datastr_name  = "aisvc-to-datastr"
datastr_to_hub_name     = "datastr_to_hub" 
hub-to-datastr_name     = "hub-to-datastr"

# ===================================================================
# VM Variables
# ===================================================================

ip_config_name        = "internal"
ip_address_allocation = "Static"
private_ip_address    = "10.0.0.5"

vm_name               = "Jump-VM"
VM_Size               = "Standard_D2s_v5" 
storage_account_type  = "StandardSSD_LRS"
vm_caching            = "ReadWrite"

admin_username        = "adminuser"

UbuntuServer =   {
  publisher   =   "canonical"
  offer       =   "0001-com-ubuntu-server-focal"
  sku         =   "20_04-lts-gen2"
  version     =   "latest"
}

# ===================================================================
# AOAI Variables
# ===================================================================

aoai_instance = {
  "aoai_01" = {
    account_name          = "AIPlat-AOAI-01"
    custom_subdomain_name = "AIPlat-AOAI-01"
    sku_name              = "S0"
    deployment_name       = "gpt-4o-mini"
    model_name            = "gpt-4o-mini"
    model_version         = "2024-07-18"
    sku = {
      name     = "GlobalStandard"
      capacity = 10 
    }
  },
  "aoai_02" = {
    account_name          = "AIPlat-AOAI-02"
    custom_subdomain_name = "AIPlat-AOAI-02"
    sku_name              = "S0"
    deployment_name       = "gpt-4o-mini"
    model_name            = "gpt-4o-mini"
    model_version         = "2024-07-18"
    sku = {
      name     = "GlobalStandard"
      capacity = 100
    }
  }  
}

# ===================================================================
# APIM Variables
# ===================================================================

identity_name     = "AIPlat-identity-ID"

apim_name         = "AIPlat-AOAI-APIM"
apim_sku          = "StandardV2"
apimpublicaccess  = "Disabled"
publisher_name    = "google.com"
publisher_email   = "hittol17@gmail.com"

entra_auth        = false
openapi_path      = "openai"
openapi_header    = "api-key"
openapi_name      = "gpt-4o-Gateway"
openapi_protocols = ["https"]


# ===================================================================
# VPN Gateawy Variables
# ===================================================================

vpngateway_name              = "AIPlat-VPN-GW"
vpn_sku                      = "Basic"
active_active_enabled        = false
bgp_enabled                  = false
public_ip_allocation_method  = "Static"
private_ip_allocation_method = "Dynamic"

localgateway_name            = "AIPlat-Local-GW"
on_premise_public_ip         = "11.11.11.11"
on_premise_address_space     = ["10.1.0.0/16"]

vpngateway_connection_name   = "connection-01"
vpn_shared_key               = "ps_key_name"


# ===================================================================
# FW Variables
# ===================================================================

fw_name = "AIPlat-Firewall"
fw_sku  = "Standard"

routetable_name_JUMP    = "RT-JumpSubnet"
routetable_name_AOAI    = "RT-AOAISubent"
routetable_name_AISVC   = "RT-AISVCSubent"

# ===================================================================
# App Services Variables
# ===================================================================

acr_name            = "acr-AIPlat"

app_plan_name       = "AIPlat-plan-appservice"
plan_os             = "Linux"
plan_sku            = "B1"

front_name          = "app-AIPlat-front"
back_name           = "app-AIPlat-back"

# ===================================================================
# AppGW&WAF
# ===================================================================

appgw_name            = "AIPlat-AppGW"
waf_name              = "AIPlat-WAF"
