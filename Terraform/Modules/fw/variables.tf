variable "rg_name" {
  type = string  
}

variable "location" {
  type = string  
}

variable "hub_vnet_id" {
  type = string
}

variable "hub_fw_subnet_id" {
  type = string
}

variable "hub_manfw_subnet_id" {
  type = string
}

variable "jump_subnet_id" {
  type = string
}

variable "apim_subnet_id" {
  type = string
}

variable "app_subnet_id" {
  type = string
}

variable "aks_subnet_id" {
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

variable "jumpvm_ip" {
  type = string
}

variable "fw_sku" {
  type = string
}


# ===================================================================
# Firewall Policy Application Rule
# ===================================================================

variable "app_rule_collection_groups" {
  type = map(object({
    priority = number
    collection = object({
      name         = string
      priority     = number
      action       = string
      rules = list(object({
        name              = string
        protocols         = list(object({ type = string, port = number }))
        source_addresses  = list(string)
        destination_fqdns = list(string)
      }))
    })
  }))
  default = {
  }
}

# ===================================================================
# Firewall Policy network Rule
# ===================================================================

variable "network_rule_collection_groups" {
  type = map(object({
    priority = number
    collection = object({
      name         = string
      priority     = number
      action       = string
      rules = list(object({
        name                  = string
        protocols             = list(string)
        source_addresses      = list(string)
        destination_addresses = list(string)
        destination_ports     = list(string)
      }))
    })
  }))
  default = {
  }
}