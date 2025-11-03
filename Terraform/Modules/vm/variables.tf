variable "rg_name" {
  type = string  
}

variable "location" {
  type = string  
}

variable "vnet-subnet_id" {
  type = string   
}

# ===================================================================
# VM Settings
# ===================================================================

variable "ip_config_name" {
    type = string
}

variable "ip_address_allocation" {
    type = string
}

variable "private_ip_address" {
  type      = string
}

variable "vm_name" {
    type = string
}

variable "VM_Size" {
    type = string   
}

variable "vm_caching" {
    type = string 
}

variable "storage_account_type" {
    type = string   
}

variable "admin_username" {
    type = string
}

variable "UbuntuServer" {
    type = object({
        publisher   = string
        offer       = string
        sku         = string
        version     = string
  })
}

