data "azuread_service_principal" "sp" {
  client_id = local.azure.clientId
}

