output "endpoint" {
  value = {
    for k,v in azurerm_cognitive_account.aoai : k => v.endpoint
  }
}

output "deployment_name" {
  value = {
    for k,v in azurerm_cognitive_deployment.model : k => v.name
  }
}

