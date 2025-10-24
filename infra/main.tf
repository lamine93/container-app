resource "random_id" "suffix" {
  byte_length = 3
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.project}-rg"
  location = var.location   
}

# Workspace logs analytics
resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.project}-law"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days  = 30
}

# Environment container app
resource "azurerm_container_app_environment" "env" {
  name                = "${var.project}-env"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
}

# Registry (ACR)
resource "azurerm_container_registry" "acr" {
  name                     = "${var.project}acr${random_id.suffix.hex}"
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  sku                      = "Basic"
  admin_enabled            = true
}


# Container App
resource "azurerm_container_app" "app" {
    name                = "${var.project}-app"
    resource_group_name = azurerm_resource_group.rg.name
    container_app_environment_id = azurerm_container_app_environment.env.id
    revision_mode      = "Single"

    identity {
         type = "SystemAssigned"
    }

    registry {
         server   = azurerm_container_registry.acr.login_server
         identity = "system"
    }

    template {
        container {
            name   = "web"
            image  = "${azurerm_container_registry.acr.login_server}/aca-demo:42c78a8b035a557c8a9b51a0f4a87605e18ffb9e"
            cpu    = 0.5
            memory = "1Gi"
            env {
                name  = "MESSAGE"
                value = "Hello from ACA!"
            }
        }
        http_scale_rule {
             name                = "httpscale"
             concurrent_requests = 50
        }
    }
    
    ingress {
        external_enabled = true
        target_port     = 8080
        transport       = "auto"
        traffic_weight {
          latest_revision = true
          percentage = 100
        }
    }

    depends_on = [azurerm_container_registry.acr]
}


resource "azurerm_role_assignment" "acrpull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = data.azuread_service_principal.sp.object_id
  depends_on = [azurerm_container_app.app]
}


resource "azurerm_role_assignment" "acrpush" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPush"
  principal_id         = data.azuread_service_principal.sp.object_id
  depends_on = [azurerm_container_app.app]
}