output "subscription_key" {
  value       = azurerm_api_management_subscription.main.primary_key
  sensitive   = true
}