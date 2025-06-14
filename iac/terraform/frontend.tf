# --- Frontend resources for Affiliate Application ---
# This file contains all resources related to the frontend Web App

# --- Azure Linux Web App (for Frontend) ---
resource "azurerm_linux_web_app" "frontend_app" {
  #checkov:skip=CKV_AZURE_222:Ensure that Azure Web App public network access is disabled
  #checkov:skip=CKV_AZURE_17:Ensure the web app has 'Client Certificates (Incoming client certificates)' set
  #checkov:skip=CKV_AZURE_214:Ensure App Service is set to be always o
  #checkov:skip=CKV_AZURE_213:Ensure that App Service configures health check
  name                = var.resource_names.frontend_app
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_service_plan.asp.location
  service_plan_id     = azurerm_service_plan.asp.id
  https_only          = true

  # Enable managed identity for secure authentication
  identity {
    type = "SystemAssigned"
  }

  # Mount storage account for website content
  storage_account {
    name         = "frontendcontent"
    type         = "AzureFiles"
    account_name = azurerm_storage_account.backend.name
    share_name   = azurerm_storage_share.frontend_content.name
    access_key   = azurerm_storage_account.backend.primary_access_key
    mount_path   = "/home/site/wwwroot"
  }

  site_config {
    ftps_state          = "Disabled"
    minimum_tls_version = "1.2"
    http2_enabled       = true
    always_on           = false # Cost optimization: Allows the app to be unloaded when idle

    application_stack {
      node_version = "18-lts" # Use appropriate Node.js version for frontend
    }
  }

  # Enable authentication using EntraID (Azure AD) with unified app
  auth_settings {
    enabled                       = true
    default_provider              = "AzureActiveDirectory"
    issuer                        = "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}/v2.0"
    unauthenticated_client_action = "RedirectToLoginPage"
    token_store_enabled           = true

    active_directory {
      client_id     = azuread_application.app.client_id
      client_secret = azuread_application_password.app.value
      #allowed_audiences = ["api://${var.resource_names.backend_app}"]
    }
  }

  # Enable logging for the frontend app
  logs {
    failed_request_tracing  = true
    detailed_error_messages = true
    http_logs {
      azure_blob_storage {
        retention_in_days = 4
        sas_url           = data.azurerm_storage_account_sas.logs_sas.sas
      }
    }
    application_logs {
      file_system_level = "Warning"
      azure_blob_storage {
        level             = "Warning"
        retention_in_days = 4
        sas_url           = data.azurerm_storage_account_sas.logs_sas.sas
      }
    }
  }

  # App settings for frontend (API_BASE_URL will be added separately via azapi)
  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"             = azurerm_application_insights.appi.instrumentation_key
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
    "APPLICATIONINSIGHTS_CONNECTION_STRING"      = "InstrumentationKey=${azurerm_application_insights.appi.instrumentation_key}"
    "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"   = azuread_application_password.app.value
    # La autenticación ya está habilitada a través del bloque auth_settings
  }

  tags = var.tags

  # Ignore changes in API_BASE_URL managed by azapi_resource_action and logs managed by Azure portal
  lifecycle {
    ignore_changes = [
      app_settings["API_BASE_URL"],
      logs
    ]
  }
}
