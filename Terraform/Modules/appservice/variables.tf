variable "rg_hub_name" {
  type = string
}

variable "hub_vnet_id" {
  type = string
}

variable "app_rg_name" {
  type = string
}

variable "location" {
  type = string  
}

variable "app_inte_subnet" {
  type = string
}

variable "app_pe_subnet" {
  type = string
}


# ===================================================================
# AppService
# ===================================================================

variable "app_plan_name" {
  type = string
}

variable "plan_os" {
  type = string  
}

variable "plan_sku" {
  type = string  
}

variable "app_name" {
  type = string
}
