variable "location" {
  type = string  
}

variable "Hub_rg_name" {
  type = string  
}

variable "AISVC_rg_name" {
  type = string  
}

variable "DataSTR_rg_name" {
  type = string  
}

variable "AOAI_rg_name" {
  type = string  
}

# ===================================================================
# VNet
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
    nsg_key          = optional(string)
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

# ===================================================================
# NSG
# ===================================================================

variable "apim_intg_nsg_name" {
  type = string 
}

variable "network_security_groups_rule" {
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
  default = {}
}

# ===================================================================
# Peering
# ===================================================================

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

