output "hub_vnet_id" {
  value       = azurerm_virtual_network.hub.id
}

output "hub_subnet_ids" {
  value = {
    for k, v in azurerm_subnet.hub : k => v.id
  }
}

output "hub_subnet_cidrs" {
  value       = { for k, s in azurerm_subnet.hub : k => s.address_prefixes[0] }
}

output "aisvc_vnet_id" {
  value       = azurerm_virtual_network.aisvc.id
}

output "aisvc_subnet_ids" {
  value = {
    for k, v in azurerm_subnet.aisvc : k => v.id
  }
}

output "aisvc_subnet_cidrs" {
  value       = { for k, s in azurerm_subnet.aisvc : k => s.address_prefixes[0] }
}

output "aoai_vnet_id" {
  value       = azurerm_virtual_network.aoai.id
}

output "aoai_subnet_ids" {
  value = {
    for k, v in azurerm_subnet.aoai : k => v.id
  }
}

output "aoai_subnet_cidrs" {
  value       = { for k, s in azurerm_subnet.aoai : k => s.address_prefixes[0] }
}

output "datastr_vnet_id" {
  value       = azurerm_virtual_network.datastr.id
}

output "datastr_subnet_ids" {
  value = {
    for k, v in azurerm_subnet.datastr : k => v.id
  }
}

output "datastr_subnet_cidrs" {
  value       = { for k, s in azurerm_subnet.datastr : k => s.address_prefixes[0] }
}