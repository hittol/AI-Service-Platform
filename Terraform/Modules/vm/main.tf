# ===================================================================
# Create NIC
# ===================================================================

resource "azurerm_network_interface" "nic_JumpVM"{
    name                        = "${var.vm_name}-nic"
    location                    = var.location
    resource_group_name         = var.rg_name

    ip_configuration {
        name                            = var.ip_config_name
        subnet_id                       = var.vnet-subnet_id
        private_ip_address_allocation   = var.ip_address_allocation
        private_ip_address              = var.private_ip_address
  }
}

# ===================================================================


# ===================================================================
# Create VM
# ===================================================================

resource "azurerm_linux_virtual_machine" "JumpVM" {
    name                    = var.vm_name
    location                = var.location
    resource_group_name     = var.rg_name
    network_interface_ids   = [azurerm_network_interface.nic_JumpVM.id]
    size                    = var.VM_Size
    admin_username          = var.admin_username 

    os_disk {
        name                    = "${var.vm_name}_osdisk"
        caching                 = var.vm_caching
        storage_account_type    = var.storage_account_type
    }

    source_image_reference {
        publisher = var.UbuntuServer.publisher
        offer     = var.UbuntuServer.offer
        sku       = var.UbuntuServer.sku
        version   = var.UbuntuServer.version
    }

    identity {
      type = "SystemAssigned"
    }
}

# ===================================================================

# ===================================================================
# Add Entra ID Login Extension
# ===================================================================

resource "azurerm_virtual_machine_extension" "entra_login" {
  name                      = "AADSSHLoginForLinux"
  virtual_machine_id        = azurerm_virtual_machine.MarketVM.id
  publisher                 = "Microsoft.Azure.ActiveDirectory"
  type                      = "AADSSHLoginForLinux"
  type_handler_version      = "1.0"
}

# ===================================================================