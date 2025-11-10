variable "rg_name" {
  type = string  
}

variable "location" {
  type = string  
}

variable "hub_vnet_id" {
  type = string
}

variable "hub_subnet_id" {
  type = string
}

variable "on_premise_public_ip" {
  type = string
}

variable "on_premise_address_space" {
  type = list(string)
}


variable "public_ip_allocation_method" {
  type = string
  validation {
    condition     = contains(["Static", "Dynamic"], var.public_ip_allocation_method)
    error_message = "Wrong Value : allocation_method must has 'Static' or 'Dynamic'."
  }
}

variable "active_active_enabled" {
  type = bool
}

variable "bgp_enabled" {
  type = bool
}

variable "vpn_shared_key" {
  type = string
}

variable "vpngateway_name" {
  type = string
}

variable "localgateway_name" {
  type = string
}

variable "vpn_sku" {
  type = string 
}

variable "vpngateway_connection_name" {
  type = string
}

variable "private_ip_allocation_method" {
  type    = string
  validation {
    condition     = contains(["Static", "Dynamic"], var.private_ip_allocation_method)
    error_message = "Wrong Value : allocation_method must has 'Static' or 'Dynamic'."
  }
}