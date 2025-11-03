# ===================================================================
# Create VNet
# ===================================================================
resource "azurerm_virtual_network" "hub" {
  name                = var.hub_vnet_name
  address_space       = var.hub_vnet_address_space
  location            = var.location
  resource_group_name = var.Hub_rg_name
}

resource "azurerm_virtual_network" "aisvc" {
  name                = var.aisvc_vnet_name
  address_space       = var.aisvc_vnet_address_space
  location            = var.location
  resource_group_name = var.AISVC_rg_name
}

resource "azurerm_virtual_network" "aoai" {
  name                = var.aoai_vnet_name
  address_space       = var.aoai_vnet_address_space
  location            = var.location
  resource_group_name = var.AOAI_rg_name
}

resource "azurerm_virtual_network" "datastr" {
  name                = var.datastr_vnet_name
  address_space       = var.datastr_vnet_address_space
  location            = var.location
  resource_group_name = var.DataSTR_rg_name
}

# ===================================================================
# Create Subnet
# ===================================================================

resource "azurerm_subnet" "hub" {
  for_each             = var.hub_subnets
  name                 = each.key
  resource_group_name  = var.Hub_rg_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = each.value.address_prefixes
}


resource "azurerm_subnet" "aisvc" {
  for_each             = var.aisvc_subnets
  name                 = each.key
  resource_group_name  = var.AISVC_rg_name
  virtual_network_name = azurerm_virtual_network.aisvc.name
  address_prefixes     = each.value.address_prefixes

  default_outbound_access_enabled = each.value.default_outbound_access_enabled
  
  dynamic "delegation" {
    for_each = each.value.service_delegation_name != null ? [1] : []
    content {
      name = "${each.key}-delegation"
      service_delegation {
        name    = each.value.service_delegation_name
        actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      }
    }
  }
}

resource "azurerm_subnet" "aoai" {
  for_each             = var.aoai_subnets
  name                 = each.key
  resource_group_name  = var.AOAI_rg_name
  virtual_network_name = azurerm_virtual_network.aoai.name
  address_prefixes     = each.value.address_prefixes

  default_outbound_access_enabled = each.value.default_outbound_access_enabled
  
  dynamic "delegation" {
    for_each = each.value.service_delegation_name != null ? [1] : []
    content {
      name = "${each.key}-delegation"
      service_delegation {
        name    = each.value.service_delegation_name
        actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      }
    }
  }
}

resource "azurerm_subnet" "datastr" {
  for_each             = var.datastr_subnets
  name                 = each.key
  resource_group_name  = var.DataSTR_rg_name
  virtual_network_name = azurerm_virtual_network.datastr.name
  address_prefixes     = each.value.address_prefixes
}


# ===================================================================
# Create NSG
# ===================================================================

resource "azurerm_network_security_group" "hub_nsg" {
  for_each            = var.network_security_groups_rule
  name                = each.key
  location            = var.location
  resource_group_name = var.Hub_rg_name

  dynamic "security_rule" {
    for_each = each.value.rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}

resource "azurerm_network_security_group" "apim_intg_nsg" {
  name                = var.apim_intg_nsg_name
  location            = var.location
  resource_group_name = var.AOAI_rg_name
}

# ===================================================================
# Connect NSG to Subnet
# ===================================================================

resource "azurerm_subnet_network_security_group_association" "hub_nsg_assoc" {
  for_each = { for k, v in var.hub_subnets : k => v if v.nsg_key != null }
  subnet_id                 = azurerm_subnet.hub[each.key].id
  network_security_group_id = azurerm_network_security_group.hub_nsg[each.value.nsg_key].id
}

resource "azurerm_subnet_network_security_group_association" "apim_intg_nsg_assoc" {
  subnet_id                 = azurerm_subnet.aoai["APIMINTGSubnet"].id
  network_security_group_id = azurerm_network_security_group.apim_intg_nsg.id
}

# ===================================================================
# VNET Peering
# ===================================================================

resource "azurerm_virtual_network_peering" "hub_to_aisvc" {
  name                         = var.hub_to_aisvc_name
  resource_group_name          = var.Hub_rg_name
  virtual_network_name         = azurerm_virtual_network.hub.name
  remote_virtual_network_id    = azurerm_virtual_network.aisvc.id

  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
  allow_gateway_transit        = true
  depends_on                   = [azurerm_subnet.aisvc]
}

resource "azurerm_virtual_network_peering" "aisvc_to_hub" {
  name                         = var.aisvce-to-hub_name
  resource_group_name          = var.AISVC_rg_name
  virtual_network_name         = azurerm_virtual_network.aisvc.name
  remote_virtual_network_id    = azurerm_virtual_network.hub.id

  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
  use_remote_gateways          = true
  depends_on                   = [azurerm_subnet.aisvc]
}

resource "azurerm_virtual_network_peering" "aoai_to_aisvc" {
  name                         = var.aoai_to_aisvc_name
  resource_group_name          = var.AOAI_rg_name
  virtual_network_name         = azurerm_virtual_network.aoai.name
  remote_virtual_network_id    = azurerm_virtual_network.aisvc.id

  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
  allow_gateway_transit        = true
  depends_on                   = [azurerm_subnet.aisvc]
}

resource "azurerm_virtual_network_peering" "aisvc_to_aoai" {
  name                         = var.aisvce-to-aoai_name
  resource_group_name          = var.AISVC_rg_name
  virtual_network_name         = azurerm_virtual_network.aisvc.name
  remote_virtual_network_id    = azurerm_virtual_network.aoai.id

  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
  use_remote_gateways          = true
  depends_on                   = [azurerm_subnet.aisvc]
}

resource "azurerm_virtual_network_peering" "aoai_to_datastr" {
  name                         = var.aoai_to_datastr_name
  resource_group_name          = var.AOAI_rg_name
  virtual_network_name         = azurerm_virtual_network.aoai.name
  remote_virtual_network_id    = azurerm_virtual_network.datastr.id

  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
  allow_gateway_transit        = true
  depends_on                   = [azurerm_subnet.aoai]
}

resource "azurerm_virtual_network_peering" "datastr_to_aoai" {
  name                         = var.datastr-to-aoai_name
  resource_group_name          = var.DataSTR_rg_name
  virtual_network_name         = azurerm_virtual_network.datastr.name
  remote_virtual_network_id    = azurerm_virtual_network.aoai.id

  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
  use_remote_gateways          = true
  depends_on                   = [azurerm_subnet.aoai]
}
     
resource "azurerm_virtual_network_peering" "aisvc_to_datastr" {
  name                         = var.aisvce-to-datastr_name
  resource_group_name          = var.AISVC_rg_name
  virtual_network_name         = azurerm_virtual_network.aisvc.name
  remote_virtual_network_id    = azurerm_virtual_network.datastr.id

  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
  allow_gateway_transit        = true
  depends_on                   = [azurerm_subnet.aisvc]
}

resource "azurerm_virtual_network_peering" "datastr_to_aisvc" {
  name                         = var.datastr_to_aisvc_name
  resource_group_name          = var.DataSTR_rg_name
  virtual_network_name         = azurerm_virtual_network.datastr.name
  remote_virtual_network_id    = azurerm_virtual_network.aisvc.id

  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
  use_remote_gateways          = true
  depends_on                   = [azurerm_subnet.aisvc]
}     

resource "azurerm_virtual_network_peering" "hub_to_datastr" {
  name                         = var.hub-to-datastr_name
  resource_group_name          = var.Hub_rg_name
  virtual_network_name         = azurerm_virtual_network.hub.name
  remote_virtual_network_id    = azurerm_virtual_network.datastr.id

  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
  allow_gateway_transit        = true
  depends_on                   = [azurerm_subnet.hub]
}

resource "azurerm_virtual_network_peering" "datastr_to_aisvc" {
  name                         = var.datastr_to_hub_name
  resource_group_name          = var.DataSTR_rg_name
  virtual_network_name         = azurerm_virtual_network.datastr.name
  remote_virtual_network_id    = azurerm_virtual_network.hub.id

  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
  use_remote_gateways          = true
  depends_on                   = [azurerm_subnet.hub]
}
    