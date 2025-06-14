# --- Backend resources for Affiliate Application ---
# This file contains all resources related to the backend API

# --- App Service Plan (for Backend API) ---
resource "azurerm_service_plan" "asp" {
  #checkov:skip=CKV_AZURE_211:Ensure App Service plan suitable for production use
  #checkov:skip=CKV_AZURE_212:Ensure App Service has a minimum number of instances for failover
  #checkov:skip=CKV_AZURE_225:Ensure the App Service Plan is zone redundant
  name                = var.resource_names.app_service_plan
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux" # Linux is more cost-effective than Windows
  sku_name            = "B1"    # Basic tier is sufficient for low traffic
  tags                = var.tags
}

# --- App Service (for Backend API) ---
resource "azurerm_linux_web_app" "backend_app" {
  #checkov:skip=CKV_AZURE_222:Ensure that Azure Web App public network access is disabled
  #checkov:skip=CKV_AZURE_17:Ensure the web app has 'Client Certificates (Incoming client certificates)' set
  #checkov:skip=CKV_AZURE_214:Ensure App Service is set to be always o
  name                = var.resource_names.backend_app
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_service_plan.asp.location
  service_plan_id     = azurerm_service_plan.asp.id
  https_only          = true

  # Enable managed identity for RBAC authentication to SQL Database
  identity {
    type = "SystemAssigned"
  }

  storage_account {
    name         = "websitecontent"
    type         = "AzureFiles"
    account_name = azurerm_storage_account.backend.name
    share_name   = azurerm_storage_share.website_content.name
    access_key   = azurerm_storage_account.backend.primary_access_key
    mount_path   = "/home/site/wwwroot"
  }

  site_config {
    ftps_state                        = "Disabled"
    minimum_tls_version               = "1.2"
    scm_minimum_tls_version           = "1.2"
    http2_enabled                     = true
    health_check_path                 = "/health"
    health_check_eviction_time_in_min = 5
    application_stack {
      dotnet_version = "8.0" # Use appropriate .NET version
    }
    always_on = false # Cost optimization: Allows the app to be unloaded when idle

    # CORS configuration - moved from slot directly to main app
    cors {
      allowed_origins     = ["https://${azurerm_linux_web_app.frontend_app.default_hostname}"]
      support_credentials = true
    }

    # Allow IPs from user-defined list
    dynamic "ip_restriction" {
      for_each = var.allowed_ip_addresses
      content {
        ip_address = can(regex("/", ip_restriction.value)) ? ip_restriction.value : format("%s/32", ip_restriction.value)
        action     = "Allow"
        priority   = 100 + index(var.allowed_ip_addresses, ip_restriction.value)
        name       = "AllowUserIP-${index(var.allowed_ip_addresses, ip_restriction.value)}"
      }
    }

    # Allow Azure backbone services
    ip_restriction {
      service_tag = "AzureCloud"
      action      = "Allow"
      priority    = 200
      name        = "AllowAzureServices"
    }

    # Allow frontend outbound IPs
    dynamic "ip_restriction" {
      # Get the outbound IPs from the frontend app
      for_each = toset(azurerm_linux_web_app.frontend_app.outbound_ip_addresses != null ? split(",", azurerm_linux_web_app.frontend_app.outbound_ip_addresses) : [])
      content {
        ip_address = format("%s/32", ip_restriction.value)
        action     = "Allow"
        priority   = 250 + index(split(",", azurerm_linux_web_app.frontend_app.outbound_ip_addresses), ip_restriction.value)
        name       = "AllowFrontendIP-${index(split(",", azurerm_linux_web_app.frontend_app.outbound_ip_addresses), ip_restriction.value)}"
      }
    }

    # Deny all other traffic
    ip_restriction {
      ip_address = "0.0.0.0/0"
      action     = "Deny"
      priority   = 300
      name       = "DenyAll"
    }
  }

  auth_settings {
    enabled                       = true
    default_provider              = "AzureActiveDirectory"
    issuer                        = "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}/v2.0"
    unauthenticated_client_action = "RedirectToLoginPage"
    token_store_enabled           = true

    active_directory {
      client_id         = azuread_application.app.client_id
      client_secret     = azuread_application_password.app.value
      allowed_audiences = ["api://${var.resource_names.backend_app}"]
    }
  }

  # Enable logging
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
  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"             = azurerm_application_insights.appi.instrumentation_key
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
    "APPLICATIONINSIGHTS_CONNECTION_STRING"      = "InstrumentationKey=${azurerm_application_insights.appi.instrumentation_key}"
    # Connection string using managed identity authentication (no password)
    "ConnectionStrings__DefaultConnection" = "Server=tcp:${azurerm_mssql_server.sqlserver.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.sqldb.name};Authentication=Active Directory Default;Encrypt=true;TrustServerCertificate=false;Connection Timeout=30;"
  }
  tags = var.tags

  # Ignore changes in logs that are managed by Azure portal
  lifecycle {
    ignore_changes = [
      logs
    ]
  }
}

# Configure backend app to serve frontend app from the same service plan
# This is an alternative approach to using Static Web Apps:
# 1. Build frontend app using CI/CD pipeline
# 2. Deploy static files to a virtual directory in the backend web app
# 3. Configure URL rewriting to serve frontend files
