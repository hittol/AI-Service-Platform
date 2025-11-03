# ===================================================================
# Private DNS Zone Create
# ===================================================================

resource "azurerm_private_dns_zone" "apim" {
  name                = "privatelink.azure-api.net"
  resource_group_name = var.rg_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "hub_vnet_link" {
  name                  = "apim-link-hub"
  resource_group_name   = var.rg_name
  private_dns_zone_name = azurerm_private_dns_zone.apim.name
  virtual_network_id    = var.hub_vnet_id
}
# ===================================================================



# ===================================================================
# ManagedIdentity Create
# ===================================================================

data "azurerm_role_definition" "openai_user_role" {
  name = "Cognitive Services OpenAI User"
}

data "azurerm_subscription" "primary" {}

resource "random_uuid" "role_assignment_name" {}

resource "azurerm_user_assigned_identity" "ManagedID" {
  name                = var.identity_name
  location            = var.location
  resource_group_name = var.rg_name
}

resource "azurerm_role_assignment" "ManagedID_Assign" {
  name               = random_uuid.role_assignment_name.result
  scope              = data.azurerm_subscription.primary.id
  role_definition_id = data.azurerm_role_definition.openai_user_role.id
  principal_id       = azurerm_user_assigned_identity.ManagedID.principal_id
}

# ===================================================================


# ===================================================================
# Application Insights
# ===================================================================

resource "azurerm_application_insights" "apim_applicationinsights" {
  name                = "${azapi_resource.apim_v2.name}-appinsights"
  location            = var.location
  resource_group_name = var.rg_name
  application_type    = "other"
}

# ===================================================================


# ===================================================================
# API Management Create
# ===================================================================

resource "azurerm_public_ip" "apim_pip" {
  name                = "${var.apim_name}-pip"
  location            = var.location
  resource_group_name = var.rg_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azapi_resource" "apim_v2" {
  type                = "Microsoft.ApiManagement/service@2024-05-01"
  name                = var.apim_name
  location            = var.location
  parent_id           = var.rg_id

  body = {
    sku = {
      name     = var.apim_sku
      capacity = 1
    }
    properties = {
      publisherEmail      = var.publisher_email
      publisherName       = var.publisher_name 
      publicIpAddressId   = azurerm_public_ip.apim_pip.id
    }
    identity = {
      type                = "UserAssigned"
      userAssignedIdentities = {
        "${azurerm_user_assigned_identity.ManagedID.id}" = {}
      }
    }  
  }
}

# ===================================================================


# ===================================================================
# Private Link Create
# ===================================================================

resource "azurerm_private_endpoint" "apim_inbound" {
  name                = "${var.apim_name}-PE"
  location            = var.location
  resource_group_name = var.rg_name
  subnet_id           = var.apim_pe_subnet_id

  private_service_connection {
    name                           = "${var.apim_name}-inbound-psc"
    is_manual_connection           = false
    private_connection_resource_id = azapi_resource.apim_v2.id
    subresource_names              = ["Gateway"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.apim.id]
  }
}

# ===================================================================


# ===================================================================
# Named Value Configure
# ===================================================================

resource "azurerm_api_management_named_value" "user_managed_id" {
  name                = "user_managed_id"
  api_management_name = azapi_resource.apim_v2.name
  resource_group_name = var.rg_name
  display_name        = "user_managed_id"
  value               = azurerm_user_assigned_identity.ManagedID.client_id
  secret              = true
}

resource "azurerm_api_management_named_value" "entra_authen" {
  name                = "entra_authen"
  api_management_name = azapi_resource.apim_v2.name
  resource_group_name = var.rg_name
  display_name        = "entra_authen"
  value               = var.entra_auth
  secret              = false
}

# ===================================================================


# ===================================================================
# APIM Product Configure
# ===================================================================

resource "azurerm_api_management_product" "main" {
  product_id            = "aoai_product"
  api_management_name   = azapi_resource.apim_v2.name
  resource_group_name   = var.rg_name
  display_name          = "aoai_product"
  subscription_required = true
  approval_required     = false
  published             = true
}

# ===================================================================


# ===================================================================
# APIM Subscription Configure
# ===================================================================

resource "azurerm_api_management_subscription" "main" {
  subscription_id       = "aoai-master-key"
  api_management_name   = azapi_resource.apim_v2.name
  resource_group_name   = var.rg_name
  product_id            = azurerm_api_management_product.main.id

  display_name          = "aoai-master-key"
  user_id               = "${azapi_resource.apim_v2.id}/users/1"
  state                 = "active"
}

# ===================================================================


# ===================================================================
# Backend Configure
# ===================================================================

resource "azurerm_api_management_backend" "apim_backend" {
  for_each            = var.aoai_backend

  resource_group_name = var.rg_name
  api_management_name = azapi_resource.apim_v2.name

  name                = each.value.backend_name
  protocol            = each.value.backend_protocol
  url                 = each.value.backend_url
  tls {
    validate_certificate_chain = each.value.validate_certificate_chain
    validate_certificate_name  = each.value.validate_certificate_name 
  }
}

# ===================================================================


# ===================================================================
# APIM API Configure
# ===================================================================

resource "azurerm_api_management_api" "aoai" {
  name                = var.openapi_name
  api_management_name = azapi_resource.apim_v2.name
  resource_group_name = var.rg_name
  revision            = "1"
  display_name        = var.openapi_name
  protocols           = var.openapi_protocols
  path                = var.openapi_path

  subscription_key_parameter_names {
    header            = var.openapi_header
    query             = "subscription-key"
  }

  import {
    content_format    = "openapi+json"
    content_value     = file("${path.module}/openapi/inference.json") 
  }
}

resource "azurerm_api_management_product_api" "link" {
  api_management_name = azapi_resource.apim_v2.name
  resource_group_name = var.rg_name
  product_id          = azurerm_api_management_product.main.product_id
  api_name            = azurerm_api_management_api.aoai.name
}

resource "azurerm_api_management_api_policy" "api_policy" {
  api_name            = azurerm_api_management_api.aoai.name
  api_management_name = azapi_resource.apim_v2.name
  resource_group_name = var.rg_name
  
  xml_content = templatefile("${path.module}/policies/aoai_chat_policy.xml", {
  })
}

# ===================================================================


# ===================================================================
# APIM Logger
# ===================================================================

resource "azurerm_api_management_logger" "apim_logger_app" {
  name                  = "appinsight-logger"
  api_management_name   = azapi_resource.apim_v2.name
  resource_group_name   = var.rg_name
  resource_id           = azurerm_application_insights.apim_applicationinsights.id

  application_insights {
    instrumentation_key = azurerm_application_insights.apim_applicationinsights.instrumentation_key
  }

  depends_on = [azurerm_api_management_api_policy.api_policy]
}


# ===================================================================


# ===================================================================
# APIM Logger
# ===================================================================

resource "azurerm_api_management_api_diagnostic" "apim_api_diag" {
  identifier                = "applicationinsights"
  resource_group_name       = var.rg_name
  api_management_name       = azapi_resource.apim_v2.name
  api_name                  = azurerm_api_management_api.aoai.name
  api_management_logger_id  = azurerm_api_management_logger.apim_logger_app.id

  sampling_percentage       = 5.0
  always_log_errors         = true
  log_client_ip             = true
  verbosity                 = "verbose"
  http_correlation_protocol = "W3C"

  frontend_request {
    body_bytes = 32
    headers_to_log = [
      "content-type",
      "accept",
      "origin",
    ]
  }

  frontend_response {
    body_bytes = 32
    headers_to_log = [
      "content-type",
      "content-length",
      "origin",
    ]
  }

  backend_request {
    body_bytes = 32
    headers_to_log = [
      "content-type",
      "accept",
      "origin",
    ]
  }

  backend_response {
    body_bytes = 32
    headers_to_log = [
      "content-type",
      "content-length",
      "origin",
    ]
  }
}

# ===================================================================


# ===================================================================
# VNET Integration 
# ===================================================================

resource "azapi_update_resource" "apim_network_patch" {
  type        = "Microsoft.ApiManagement/service@2023-05-01-preview"
  resource_id = azapi_resource.apim_v2.id

  body = {
    properties = {
      publicNetworkAccess = var.apimpublicaccess
      virtualNetworkType  = "External"
      virtualNetworkConfiguration = {
        subnetResourceId = var.apim_integration_subnet_id
      }
    }
  }

  depends_on = [azurerm_private_endpoint.apim_inbound ,azurerm_api_management_logger.apim_logger_app]
}


# ===================================================================