# ===================================================================
# Create SSH Key
# ===================================================================

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key_pem" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "./.key/azure_aks_key.pem"
  file_permission = "0600"
}

resource "azurerm_ssh_public_key" "vm_ssh_key" {
  name                = "aks-admin-key"
  resource_group_name = var.rg_name
  location            = var.location
  public_key          = tls_private_key.ssh_key.public_key_openssh
}

# ===================================================================
# Create Private DNS Zone
# ===================================================================

resource "azurerm_private_dns_zone" "aks_dns" {
  name                = "privatelink.koreacentral.azmk8s.io"
  resource_group_name = var.rg_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "hub_vnet_link" {
  name                  = "link-VNET"
  resource_group_name   = var.rg_name
  private_dns_zone_name = azurerm_private_dns_zone.aks_dns.name
  virtual_network_id    = var.VNET_id
}

# ===================================================================
# ManagedIdentity Create
# ===================================================================

resource "azurerm_user_assigned_identity" "aks_ManagedID" {
  name                  = var.AKS_identity_name
  location              = var.location
  resource_group_name   = var.rg_name
}

resource "azurerm_role_assignment" "aks_role_assign" {
  scope                = azurerm_private_dns_zone.aks_dns.id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_ManagedID.principal_id
}


# ===================================================================
# Create aks cluster
# ===================================================================

resource "azurerm_kubernetes_cluster" "aks" {
  name                                = var.aks_name
  resource_group_name                 = var.rg_name
  location                            = var.location
  sku_tier                            = var.aks_tier

  oidc_issuer_enabled                 = true
  workload_identity_enabled           = true

  private_cluster_enabled             = true
  private_cluster_public_fqdn_enabled = false
  private_dns_zone_id                 = azurerm_private_dns_zone.aks_dns.id

  dns_prefix          = "testaksdns"

  default_node_pool {
    name            = "syspool"
    node_count      = 2
    vm_size         = var.nodepoolsize
    zones           = ["1"]
    vnet_subnet_id  = var.AKS-subnet_id
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    load_balancer_sku   = "standard"
    service_cidr        = "10.2.0.0/16"
    dns_service_ip      = "10.2.0.10"
  } 

  azure_active_directory_role_based_access_control {
    azure_rbac_enabled  = true
    tenant_id           = var.tenant_id
  }

  identity {
    type          = "UserAssigned"
    identity_ids  = [azurerm_user_assigned_identity.aks_ManagedID.id]
  }

  linux_profile {
    admin_username = "useradmin"
    ssh_key {
      key_data = azurerm_ssh_public_key.vm_ssh_key.public_key
    }
  }

  depends_on = [
    azurerm_role_assignment.aks_role_assign,
    azurerm_private_dns_zone_virtual_network_link.hub_vnet_link
  ]

}

# ===================================================================
# Create Node Pool
# ===================================================================

resource "azurerm_kubernetes_cluster_node_pool" "nodepool_01" {
  name                  = var.nodepool_01_name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.nodepool_01_size
  node_count            = 1
  zones                 = ["1"] 
  mode                  = "User"
  vnet_subnet_id        = var.AKS-subnet_id
}