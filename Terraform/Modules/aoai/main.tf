# ===================================================================
# Private DNS Zone Create
# ===================================================================

resource "azurerm_private_dns_zone" "aoai" {
  name                = "privatelink.openai.azure.com"
  resource_group_name = var.rg_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "spoke_vnet_link" {
  name                  = "aoai-link-spoke"
  resource_group_name   = var.rg_name
  private_dns_zone_name = azurerm_private_dns_zone.aoai.name
  virtual_network_id    = var.aoai_vnet_id
}

# ===================================================================


# ===================================================================
# OpenAI Create
# ===================================================================

resource "azurerm_cognitive_account" "aoai" {
  for_each            = var.aoai_instance 

  name                          = each.value.account_name
  location                      = var.location
  resource_group_name           = var.rg_name
  kind                          = "OpenAI"
  sku_name                      = each.value.sku_name

  public_network_access_enabled = false
  custom_subdomain_name         = each.value.custom_subdomain_name

  network_acls {
    default_action = "Deny"
    bypass         = "None"
    ip_rules       = []
  }
}

resource "azurerm_cognitive_deployment" "model" {
  for_each              = var.aoai_instance

  name                  = each.value.deployment_name
  cognitive_account_id  = azurerm_cognitive_account.aoai[each.key].id
  
  model {
    format  = "OpenAI"
    name    = each.value.model_name
    version = each.value.model_version
  } 
  sku {
    name     = each.value.sku.name
    capacity = each.value.sku.capacity
  }
}

# ===================================================================


# ===================================================================
# Private Link Create
# ===================================================================

resource "azurerm_private_endpoint" "aoai_pe" {
  for_each            = var.aoai_instance 
  name                = "${each.value.account_name}-PE"
  location            = var.location
  resource_group_name = var.rg_name
  subnet_id           = var.aoai_subnet_id

  private_service_connection {
    name                           = "${each.value.account_name}-psc"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_cognitive_account.aoai[each.key].id
    subresource_names              = ["account"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.aoai.id]
  }
}