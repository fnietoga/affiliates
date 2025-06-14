# --- Monitoring resources for Affiliate Application ---
# This file contains all resources related to monitoring and cost management

# --- Log Analytics Workspace ---
resource "azurerm_log_analytics_workspace" "law" {
  name                = var.resource_names.log_analytics_workspace
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018" # Most cost-effective SKU
  retention_in_days   = 30          # Minimum retention to reduce costs
  tags                = var.tags
}

# --- Application Insights (for monitoring with cost-optimized sampling) ---
resource "azurerm_application_insights" "appi" {
  name                = var.resource_names.app_insights
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.law.id # Conectar con Log Analytics
  sampling_percentage = 5                                      # Cost optimization: 5% sampling rate
  retention_in_days   = 30                                     # Minimum retention to reduce costs
  tags                = var.tags
}

# --- Cost Management: Budget and Spending Alerts ---
resource "time_static" "budget_start" {}

locals {
  first_day_of_month = formatdate("YYYY-MM-01'T'00:00:00Z", time_static.budget_start.rfc3339)
}
resource "azurerm_consumption_budget_resource_group" "budget" {
  name              = "budget-${var.resource_names.resource_group}"
  resource_group_id = azurerm_resource_group.rg.id

  amount     = var.budget_config.amount
  time_grain = "Monthly"

  time_period {
    start_date = local.first_day_of_month
    # No end date means the budget will continue indefinitely
  }

  # Generate notifications at configured threshold percentages
  dynamic "notification" {
    for_each = toset(var.budget_config.alert_threshold_percents)
    content {
      enabled        = true
      threshold      = notification.value
      operator       = "GreaterThanOrEqualTo"
      threshold_type = "Actual"

      contact_emails = [
        var.budget_config.alert_email
      ]

      contact_groups = []
      contact_roles = [
        "Owner"
      ]
    }
  }
}
