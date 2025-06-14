# --- Post-deployment application configuration ---
# This file contains resources that depend on both frontend and backend apps
# to avoid circular dependencies

# Use azapi to set frontend API_BASE_URL after both apps are deployed
# This breaks the circular dependency between frontend and backend
resource "azapi_resource_action" "set_frontend_api_url" {
  type        = "Microsoft.Web/sites/config@2022-03-01"
  resource_id = "${azurerm_linux_web_app.frontend_app.id}/config/appsettings"
  method      = "PUT"

  # We need to include all existing app settings to avoid overwriting them
  body = {
    properties = merge(
      azurerm_linux_web_app.frontend_app.app_settings,
      {
        "API_BASE_URL" = "https://${azurerm_linux_web_app.backend_app.default_hostname}"
      }
    )
  }

  # Ensure both resources are created first
  depends_on = [
    azurerm_linux_web_app.frontend_app,
    azurerm_linux_web_app.backend_app
  ]
}
