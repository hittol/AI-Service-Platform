variable "rg_name" {
  type = string  
}

variable "location" {
  type = string  
}

variable "aoai_vnet_id" {
  type = string
}

variable "aoai_subnet_id" {
  type = string
}

# ===================================================================
# AOAI Settings
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