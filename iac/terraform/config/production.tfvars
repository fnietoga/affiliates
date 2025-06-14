# Production Environment Configuration

# Resource Naming
resource_names = {
  resource_group          = "rg-prod-affiliates"
  app_service_plan        = "asp-prod-affiliates"
  frontend_app            = "app-prod-affiliates"
  backend_app             = "app-prod-affiliates-api"
  frontend_static_app     = "stapp-prod-affiliates"
  sql_server              = "sql-prod-affiliates"
  sql_database            = "db-prod-affiliates"
  key_vault               = "kv-prod-affiliates"
  app_insights            = "appi-prod-affiliates"
  logs_storage            = "stprodaffiliateslogs"
  azure_ad_app            = "auth-prod-affiliates"
  log_analytics_workspace = "law-pro-affiliates"
}

# Location
location = "northeurope"

# Tags
tags = {
  Environment = "Production"
  Project     = "AffiliatesApp"
  ManagedBy   = "Terraform"
  CostCenter  = "IT-OptimizedInfra"
}

# SQL Server Configuration
sql_admin_login = "sqladmin"

# IP Restrictions
# Add your production IPs here
allowed_ip_addresses = [
  "88.26.131.209"
]

# Budget Configuration
budget_config = {
  amount                   = 50 # EUR per month
  alert_email              = "fnietoga@gmail.com"
  alert_threshold_percents = [50, 75, 90, 100]
}
