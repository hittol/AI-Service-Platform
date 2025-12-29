variable "rg_hub_name" {
  type = string
}

variable "hub_vnet_id" {
  type = string
}

variable "aisvc_vnet_id" {
  type = string
}

variable "acr_name" {
  type = string
}

variable "app_rg_name" {
  type = string
}

variable "location" {
  type = string  
}

variable "front_inte_subnet" {
  type = string
}

variable "back_inte_subnet" {
  type = string
}

variable "app_pe_subnet" {
  type = string
}

variable "identity_name" {
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
    