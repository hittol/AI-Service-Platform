variable "rg_name" {
  type = string  
}

variable "location" {
  type = string  
}

variable "AKS_identity_name" {
  type = string   
}

variable "aks_name" {
    type        = string
}

variable "aks_tier" {
    type        = string
}

variable "nodepoolsize" {
    type        = string
}

variable "VNET_id" {
  type = string   
}

variable "AKS-subnet_id" {
  type = string   
}

variable "nodepool_01_name" {
  type = string   
}

variable "nodepool_01_size" {
  type = string   
}

variable "tenant_id" {
  type = string
  sensitive = true
}