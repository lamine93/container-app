output "resource_group" { value = azurerm_resource_group.rg.name }
output "acr_name"       { value = azurerm_container_registry.acr.name }
output "acr_login"      { value = azurerm_container_registry.acr.login_server }
output "aca_fqdn"       { value = azurerm_container_app.app.latest_revision_fqdn }
output "aca_name"       { value = azurerm_container_app.app.name }