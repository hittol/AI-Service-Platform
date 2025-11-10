# ===================================================================
# Create Gateway Pip
# ===================================================================

resource "azurerm_public_ip" "gateway_pip" {
  name                = "${var.vpngateway_name}-pip"
  location            = var.location
  resource_group_name = var.rg_name
  sku                 = "Standard"
  zones               = ["1", "2", "3"]

  allocation_method   = var.public_ip_allocation_method
}

# ===================================================================


# ===================================================================
# Create Virtual Network Gateway
# ===================================================================

resource "azurerm_virtual_network_gateway" "vnet_gateway" {
  name                = var.vpngateway_name
  location            = var.location
  resource_group_name = var.rg_name

  type                = "Vpn"
  vpn_type            = "RouteBased"

  active_active       = var.active_active_enabled
  enable_bgp          = var.bgp_enabled
  sku                 = var.vpn_sku

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.gateway_pip.id
    subnet_id                     = var.hub_subnet_id

    private_ip_address_allocation = var.private_ip_allocation_method
  }
}

# ===================================================================


# ===================================================================
# Create Local Network Gateway
# ===================================================================

resource "azurerm_local_network_gateway" "on_premise_gateway" {
  name                = var.localgateway_name
  location            = var.location
  resource_group_name = var.rg_name

  gateway_address     = var.on_premise_public_ip
  address_space       = var.on_premise_address_space
}

# ===================================================================


# ===================================================================
# Create Connection
# ===================================================================

resource "azurerm_virtual_network_gateway_connection" "s2s_connection" {
  name                       = var.vpngateway_connection_name
  location                   = var.location
  resource_group_name        = var.rg_name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vnet_gateway.id
  local_network_gateway_id   = azurerm_local_network_gateway.on_premise_gateway.id
  shared_key                 = var.vpn_shared_key
}

# ===================================================================