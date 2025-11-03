variable "rg_name" {
  type = string  
}

variable "rg_id" {
  type = string  
}

variable "location" {
  type = string  
}

variable "apim_name" {
  type = string
}

variable "publisher_name" {
  type = string
}

variable "publisher_email" {
  type = string
}

variable "apim_pe_subnet_id" {
  type = string
}

variable "apim_integration_subnet_id" {
  type = string
}

variable "hub_vnet_id" {
  type = string
}

variable "identity_name" {
  type = string  
}

variable "apim_sku" {
  type = string
}

variable "entra_auth" {
  type = bool
}

variable "apimpublicaccess" {
  type = string
}

variable "firewall_trigger" {
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

variable "aoai_backend" {
  type = map(object({
    backend_name               = string
    backend_protocol           = string
    backend_url                = string
    validate_certificate_chain = bool
    validate_certificate_name  = bool
  }))
}