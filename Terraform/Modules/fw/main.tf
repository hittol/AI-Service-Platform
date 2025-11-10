# ===================================================================
# Create NIC
# ===================================================================

resource "azurerm_public_ip" "fw-pip" {
  name                = "${var.fw_name}-pip"
  resource_group_name = var.rg_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "managed-fw-pip" {
  name                = "${var.fw_name}-managed-pip"
  resource_group_name = var.rg_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# ===================================================================

# ===================================================================
# Create Firewall&Policy
# ===================================================================

resource "azurerm_firewall_policy" "fw_policy" {
  name                = "${var.fw_name}-policy"
  resource_group_name = var.rg_name
  location            = var.location
}

resource "azurerm_firewall" "fw" {
  name                = var.fw_name
  resource_group_name = var.rg_name
  location            = var.location
  sku_name            = "AZFW_VNet"
  sku_tier            = var.fw_sku

  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.hub_fw_subnet_id
    public_ip_address_id = azurerm_public_ip.fw-pip.id
  }

  management_ip_configuration {
    name                 = "managedConfiguration"
    subnet_id            = var.hub_manfw_subnet_id
    public_ip_address_id = azurerm_public_ip.managed-fw-pip.id
  }
  
  firewall_policy_id = azurerm_firewall_policy.fw_policy.id

}

# ===================================================================
# Create Firewall Policy Rule
# ===================================================================

resource "azurerm_firewall_policy_rule_collection_group" "app_rule_groups" {
  for_each           = var.app_rule_collection_groups
  name               = each.key
  firewall_policy_id = azurerm_firewall_policy.fw_policy.id
  priority           = each.value.priority

  application_rule_collection {
    name     = each.value.collection.name
    priority = each.value.collection.priority
    action   = each.value.collection.action

    dynamic "rule" {
      for_each = each.value.collection.rules
      content {
        name              = rule.value.name
        source_addresses  = rule.value.source_addresses
        destination_fqdns = rule.value.destination_fqdns
        
        dynamic "protocols" {
          for_each = rule.value.protocols
          content {
            type = protocols.value.type
            port = protocols.value.port
          }
        }
      }
    }
  }
}

resource "azurerm_firewall_policy_rule_collection_group" "network_rule_groups" {
  for_each           = var.network_rule_collection_groups
  name               = each.key
  firewall_policy_id = azurerm_firewall_policy.fw_policy.id
  priority           = each.value.priority

  network_rule_collection {
    name     = each.value.collection.name
    priority = each.value.collection.priority
    action   = each.value.collection.action

    dynamic "rule" {
      for_each = each.value.collection.rules
      content {
        name                  = rule.value.name
        protocols             = rule.value.protocols
        source_addresses      = rule.value.source_addresses
        destination_addresses = rule.value.destination_addresses
        destination_ports     = rule.value.destination_ports
      }
    }
  }
}

/*
resource "azurerm_firewall_policy_rule_collection_group" "dnat_rule" {
  name = "DefaultDnatRuleCollectionGroup"
  firewall_policy_id = azurerm_firewall_policy.fw_policy.id
  priority = 100
  nat_rule_collection {
    name = "DNAT-RC1"
    priority = 1000
    action = "Dnat"
    rule {
      name                = var.dnat_rule_name
      protocols           = var.dnat_protocols
      source_addresses    = var.dnat_source_addresses
      destination_address = azurerm_public_ip.fw-pip.ip_address
      destination_ports   = var.dnat_destination_ports
      translated_address  = var.jumpvm_ip
      translated_port     = var.dnat_translated_port
    }
  }
}
*/

# ===================================================================


# ===================================================================
# Create UDR
# ===================================================================

resource "azurerm_route_table" "rt_jump" {
  name                = var.routetable_name_JUMP
  resource_group_name = var.rg_name
  location            = var.location

  route {
    name                   = "To-Internet"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.fw.ip_configuration[0].private_ip_address
  }
}

resource "azurerm_subnet_route_table_association" "rt_jump_asso" {
  subnet_id      = var.jump_subnet_id
  route_table_id = azurerm_route_table.rt_jump.id

}

resource "azurerm_route_table" "rt_aks" {
  name                = var.routetable_name_AISVC
  resource_group_name = var.rg_name
  location            = var.location

  route {
    name                   = "To-App"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.fw.ip_configuration[0].private_ip_address
  }
}

resource "azurerm_subnet_route_table_association" "rt_aks_asso" {
  subnet_id      = var.aks_subnet_id
  route_table_id = azurerm_route_table.rt_aks.id
}

resource "azurerm_route_table" "rt_app" {
  name                = var.routetable_name_AISVC
  resource_group_name = var.rg_name
  location            = var.location

  route {
    name                   = "To-AKS"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.fw.ip_configuration[0].private_ip_address
  }
}

resource "azurerm_subnet_route_table_association" "rt_app_asso" {
  subnet_id      = var.app_subnet_id
  route_table_id = azurerm_route_table.rt_app.id
}

resource "azurerm_route_table" "rt_apim" {
  name                = var.routetable_name_AOAI
  resource_group_name = var.rg_name
  location            = var.location

  route {
    name                   = "To-Internet"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.fw.ip_configuration[0].private_ip_address
  }
}

resource "azurerm_subnet_route_table_association" "rt_apim_asso" {
  subnet_id      = var.apim_subnet_id
  route_table_id = azurerm_route_table.rt_apim.id
}
