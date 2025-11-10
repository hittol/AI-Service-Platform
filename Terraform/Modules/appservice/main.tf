# ===================================================================
# Private DNS Zone Create
# ===================================================================

resource "azurerm_private_dns_zone" "appservice" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = var.rg_hub_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "hub_vnet_link" {
  name                  = "apim-link-hub"
  resource_group_name   = var.rg_hub_name
  private_dns_zone_name = azurerm_private_dns_zone.appservice.name
  virtual_network_id    = var.hub_vnet_id
}


# ===================================================================
# App Service Plan Create
# ===================================================================

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


resource "azurerm_linux_web_app" "webapp_prd" {
  name                  = var.app_name
  resource_group_name   = var.app_rg_name
  location              = var.location
  service_plan_id       = azurerm_service_plan.service_plan_prd.id
  depends_on            = [azurerm_service_plan.service_plan_prd]
  https_only            = true
  site_config { 
  }
}


# ===================================================================
# App Service Integration
# ===================================================================

resource "azurerm_app_service_virtual_network_swift_connection" "prd_integration" {
  app_service_id  = azurerm_linux_web_app.webapp_prd.id
  subnet_id       = var.app_inte_subnet
}

# ===================================================================
# Private Link
# ===================================================================

resource "azurerm_private_endpoint" "prd-pe" {
  name                = "pe-${azurerm_linux_web_app.webapp_prd.name}"
  resource_group_name = var.app_rg_name
  location            = var.location
  subnet_id           = var.app_pe_subnet

  private_dns_zone_group {
    name = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.appservice.id]
  }

  private_service_connection {
    name = "pe-conn-${azurerm_linux_web_app.webapp_prd.name}"
    private_connection_resource_id = azurerm_linux_web_app.webapp_prd.id
    subresource_names = ["sites"]
    is_manual_connection = false
  }
}

# ===================================================================