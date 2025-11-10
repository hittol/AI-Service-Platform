# ===================================================================
# VNET Peering
# ===================================================================

resource "azurerm_virtual_network_peering" "hub_to_aisvc" {
  name                         = var.hub_to_aisvc_name
  resource_group_name          = var.Hub_rg_name
  virtual_network_name         = var.hub_vnet_name
  remote_virtual_network_id    = var.AISVC_vnet_id

  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
  allow_gateway_transit        = true
}

resource "azurerm_virtual_network_peering" "aisvc_to_hub" {
  name                         = var.aisvce-to-hub_name
  resource_group_name          = var.AISVC_rg_name
  virtual_network_name         = var.AISVC_vnet_name
  remote_virtual_network_id    = var.hub_vnet_id

  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
  use_remote_gateways          = true
}

resource "azurerm_virtual_network_peering" "hub_to_datastr" {
  name                         = var.hub-to-datastr_name
  resource_group_name          = var.Hub_rg_name
  virtual_network_name         = var.hub_vnet_name
  remote_virtual_network_id    = var.DataSTR_vnet_id

  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
  allow_gateway_transit        = true
}

resource "azurerm_virtual_network_peering" "datastr_to_hub" {
  name                         = var.datastr_to_hub_name
  resource_group_name          = var.DataSTR_rg_name
  virtual_network_name         = var.DataSTR_vnet_name
  remote_virtual_network_id    = var.hub_vnet_id

  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
  use_remote_gateways          = true
}

# ===================================================================