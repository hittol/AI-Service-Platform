output "vm_id" {
  value       = azurerm_windows_virtual_machine.Jump.id
}

output "private_ip_address" {
  value       = azurerm_network_interface.nic-JumpVM.private_ip_address
}