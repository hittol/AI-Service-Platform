output "vm_id" {
  value       = azurerm_linux_virtual_machine.JumpVM.id
}

output "private_ip_address" {
  value       = azurerm_network_interface.nic_JumpVM.private_ip_address
}