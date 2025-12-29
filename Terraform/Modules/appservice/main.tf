# ===================================================================
# Private DNS Zone Create
# ===================================================================

resource "azurerm_private_dns_zone" "appservice" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = var.rg_hub_name
}

resource "azurerm_private_dns_zone" "acr" {
  name                = "privatelink.azurecr.io"
  resource_group_name = var.rg_hub_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "app_hub_link" {
  name                  = "app-link-hub"
  resource_group_name   = var.rg_hub_name
  private_dns_zone_name = azurerm_private_dns_zone.appservice.name
  virtual_network_id    = var.hub_vnet_id
}

resource "azurerm_private_dns_zone_virtual_network_link" "app_aisvc_link" {
  name                  = "app-link-aisvc"
  resource_group_name   = var.rg_hub_name
  private_dns_zone_name = azurerm_private_dns_zone.appservice.name
  virtual_network_id    = var.aisvc_vnet_id
}

resource "azurerm_private_dns_zone_virtual_network_link" "acr_aisvc_link" {
  name                  = "acr-link-aisvc"
  resource_group_name   = var.rg_hub_name
  private_dns_zone_name = azurerm_private_dns_zone.acr.name
  virtual_network_id    = var.aisvc_vnet_id
}


# ===================================================================
# ACR Create
# ===================================================================

resource "azurerm_container_registry" "acr" {
  name                          = var.acr_name
  resource_group_name           = var.app_rg_name
  location                      = var.location
  sku                           = "Premium"
  admin_enabled                 = false
  public_network_access_enabled = false
}

# ===================================================================
# ManagedID Create
# ===================================================================

resource "azurerm_user_assigned_identity" "ManagedID" {
  name                = var.identity_name
  resource_group_name = var.app_rg_name
  location            = var.location
}

resource "azurerm_role_assignment" "ManagedID_Push_Assign" {
  scope                 = azurerm_container_registry.acr.id
  role_definition_name  = "AcrPush"
  principal_id          = azurerm_user_assigned_identity.ManagedID.principal_id
}

resource "azurerm_role_assignment" "ManagedID_Pull_Assign" {
  scope                 = azurerm_container_registry.acr.id
  role_definition_name  = "AcrPull"
  principal_id          = azurerm_user_assigned_identity.ManagedID.principal_id
}


# ===================================================================
# App Service Plan Create
# ===================================================================W

resource "azurerm_service_plan" "service_plan_prd" {
  name                = var.app_plan_name
  resource_group_name = var.app_rg_name
  location            = var.location
  os_type             = var.plan_os
  sku_name            = var.plan_sku
}

# ===================================================================
# App Service Create
# ===================================================================

resource "azurerm_linux_web_app" "front_app" {
  name                          = var.front_name
  resource_group_name           = var.app_rg_name
  location                      = var.location
  service_plan_id               = azurerm_service_plan.service_plan_prd.id
  https_only                    = true
  public_network_access_enabled = false

  identity {
    type          = "UserAssigned"
    identity_ids  = [azurerm_user_assigned_identity.ManagedID.id]
  }

  site_config { 
    vnet_route_all_enabled = true

    application_stack {
      docker_registry_url = var.docker_registry_url
      docker_image_name   = "${var.docker_image_name}:${var.docker_image_tag}"   
    }
  }

  depends_on                    = [azurerm_service_plan.service_plan_prd]
}

resource "azurerm_linux_web_app" "back_app" {
  name                          = var.back_name
  resource_group_name           = var.app_rg_name
  location                      = var.location
  service_plan_id               = azurerm_service_plan.service_plan_prd.id
  https_only                    = true
  public_network_access_enabled = false

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.ManagedID.id]
  }

  site_config { 
    vnet_route_all_enabled = true
    
    application_stack {
      docker_registry_url = var.docker_registry_url
      docker_image_name   = "${var.docker_image_name}:${var.docker_image_tag}"   
    }
  }

  depends_on                    = [azurerm_service_plan.service_plan_prd]
}


# ===================================================================
# App Service Integration
# ===================================================================

resource "azurerm_app_service_virtual_network_swift_connection" "front_integration" {
  app_service_id  = azurerm_linux_web_app.front_app.id
  subnet_id       = var.front_inte_subnet
}

resource "azurerm_app_service_virtual_network_swift_connection" "back_integration" {
  app_service_id  = azurerm_linux_web_app.back_app.id
  subnet_id       = var.back_inte_subnet
}

# ===================================================================
# Private Link
# ===================================================================

resource "azurerm_private_endpoint" "acr-pe" {
  name                = "pe-${var.acr_name}"
  resource_group_name = var.app_rg_name
  location            = var.location
  subnet_id           = var.app_pe_subnet

  private_dns_zone_group {
    name = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.acr.id]
  }

  private_service_connection {
    name = "pe-conn-${var.acr_name}"
    private_connection_resource_id = azurerm_container_registry.acr.id
    subresource_names = ["registry"]
    is_manual_connection = false
  }
}

resource "azurerm_private_endpoint" "front-pe" {
  name                = "pe-${azurerm_linux_web_app.front_app.name}"
  resource_group_name = var.app_rg_name
  location            = var.location
  subnet_id           = var.app_pe_subnet

  private_dns_zone_group {
    name = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.appservice.id]
  }

  private_service_connection {
    name = "pe-conn-${azurerm_linux_web_app.front_app.name}"
    private_connection_resource_id = azurerm_linux_web_app.front_app.id
    subresource_names = ["sites"]
    is_manual_connection = false
  }
}

resource "azurerm_private_endpoint" "back-pe" {
  name                = "pe-${azurerm_linux_web_app.back_app.name}"
  resource_group_name = var.app_rg_name
  location            = var.location
  subnet_id           = var.app_pe_subnet

  private_dns_zone_group {
    name = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.appservice.id]
  }

  private_service_connection {
    name = "pe-conn-${azurerm_linux_web_app.back_app.name}"
    private_connection_resource_id = azurerm_linux_web_app.back_app.id
    subresource_names = ["sites"]
    is_manual_connection = false
  }
}

# ===================================================================