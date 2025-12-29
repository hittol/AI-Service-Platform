# ===================================================================
# Resource Group
# ===================================================================

variable "location" {
  type = string
}

variable "rg_setting" {
  type = map(object({
    location = optional(string, "koreacentral")
    name     = string
  }))
}
# ===================================================================
# VNET
# ===================================================================


variable "hub_vnet_name" {
  type        = string 
}

variable "hub_vnet_address_space" {
  type        = list(string)
}

variable "hub_subnets" {
  type = map(object({
    address_prefixes = list(string)
  }))
}

variable "aisvc_vnet_name" {
  type        = string 
}

variable "aisvc_vnet_address_space" {
  type        = list(string)
}

variable "aisvc_subnets" {
  type = map(object({
    address_prefixes                          = list(string)
    nsg_key                                   = optional(string)
    service_delegation_name                   = optional(string)
    default_outbound_access_enabled           = optional(bool, false)
  }))
}

variable "aoai_vnet_name" {
  type        = string 
}

variable "aoai_vnet_address_space" {
  type        = list(string)
}

variable "aoai_subnets" {
  type = map(object({
    address_prefixes                          = list(string)
    nsg_key                                   = optional(string)
    service_delegation_name                   = optional(string)
    default_outbound_access_enabled           = optional(bool, false)
  }))
}

variable "datastr_vnet_name" {
  type        = string 
}

variable "datastr_vnet_address_space" {
  type        = list(string)
}

variable "datastr_subnets" {
  type = map(object({
    address_prefixes                          = list(string)
    nsg_key                                   = optional(string)
    service_delegation_name                   = optional(string)
    default_outbound_access_enabled           = optional(bool, false)
  }))
}

variable "nsg_rule"  {
  type = map(object({
    rules = list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = optional(string, "*")
      destination_port_range     = string
      source_address_prefix      = optional(string, "*")
      destination_address_prefix = optional(string, "*")
    }))
  }))
  default     = {}
}

variable "apim_intg_nsg_name" {
  type        = string 
}

variable "hub_to_aisvc_name" {
  type        = string 
}

variable "aisvce-to-hub_name" {
  type        = string 
}

variable "aoai_to_aisvc_name" {
  type        = string 
}

variable "aisvce-to-aoai_name" {
  type        = string 
}

variable "aoai_to_datastr_name" {
  type        = string 
}

variable "datastr-to-aoai_name" {
  type        = string 
}

variable "datastr_to_aisvc_name" {
  type        = string 
}

variable "aisvce-to-datastr_name" {
  type        = string 
}

variable "datastr_to_hub_name" {
  type        = string 
}

variable "hub-to-datastr_name" {
  type        = string 
}


# ===================================================================
# VM
# ===================================================================

variable "ip_config_name" {
    type        = string
}

variable "ip_address_allocation" {
    type        = string
}

variable "vm_name" {
  type        = string
}

variable "VM_Size" {
    type        = string   
}

variable "storage_account_type" {
    type        = string   
}

variable "vm_caching" {
    type        = string 
}

variable "UbuntuServer" {
    type = object({
        publisher   = string
        offer       = string
        sku         = string
        version     = string
  })
}

variable "admin_username" {
  type        = string
}

variable "private_ip_address" {
  type      = string
}

# ===================================================================
# AOAI
# ===================================================================

variable "aoai_instance" {
  type = map(object({
    account_name          = string
    custom_subdomain_name = string
    sku_name              = string
    deployment_name       = string
    model_name            = string
    model_version         = string
    sku = object({
      name     = string
      capacity = number 
    })
  }))
}

# ===================================================================
# VPN Gateway
# ===================================================================

variable "vpngateway_name" {
  type = string
}

variable "localgateway_name" {
  type = string
}

variable "vpn_shared_key" {
  type = string
}

variable "on_premise_public_ip" {
  type = string
}

variable "on_premise_address_space" {
  type = list(string)
}

variable "vpngateway_connection_name" {
  type = string
}

variable "vpn_sku" {
  type = string 
}

variable "active_active_enabled" {
  type = bool
}

variable "bgp_enabled" {
  type = bool
}

variable "public_ip_allocation_method" {
  type = string
}

variable "private_ip_allocation_method" {
  type = string
}


# ===================================================================
# APIM
# ===================================================================

variable "identity_name" {
  type        = string  
}

variable "apim_name" {
  type        = string
}

variable "publisher_name" {
  type        = string
}

variable "publisher_email" {
  type        = string
}

variable "apim_sku" {
  type        = string
}

variable "entra_auth" {
  type = bool
}

variable "apimpublicaccess" {
  type = string
}

variable "openapi_name" {
  type = string
}

variable "openapi_protocols" {
  type = list(string)
}

variable "openapi_header" {
  type = string
}
variable "openapi_path" {
  type = string
}

# ===================================================================
# FW
# ===================================================================

variable fw_sku {
  type = string
}

variable "fw_name" {
  type = string
}

variable "routetable_name_JUMP" {
  type = string
}

variable "routetable_name_AOAI" {
  type = string
}

variable "routetable_name_AISVC" {
  type = string
}

# ===================================================================
# AppService
# ===================================================================

variable "acr_identity_name" {
  type = string
}

variable "acr_name" {
  type = string
}

variable "app_plan_name" {
  type = string
}

variable "plan_os" {
  type = string  
}

variable "plan_sku" {
  type = string  
}

variable "front_name" {
  type = string
}

variable "back_name" {
  type = string
}

variable "docker_registry_url" {
  type = string
}

variable "docker_image_name" {
  type = string
}

variable "docker_image_tag" {
  type = string
}

# ===================================================================
# AppGW&WAF
# ===================================================================

variable "appgw_name" {
  type        = string
}

variable "waf_name" {
  type        = string
}