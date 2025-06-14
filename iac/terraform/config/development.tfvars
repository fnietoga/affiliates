# Development Environment Configuration

# Resource Naming
resource_names = {
  resource_group          = "rg-dev-affiliates"
  app_service_plan        = "asp-dev-affiliates"
  frontend_app            = "app-dev-affiliates"
  backend_app             = "app-dev-affiliates-api"
  frontend_static_app     = "stapp-dev-affiliates"
  sql_server              = "sql-dev-affiliates"
  sql_database            = "db-dev-affiliates"
  key_vault               = "kv-dev-affiliates"
  app_insights            = "appi-dev-affiliates"
  logs_storage            = "stdevaffiliateslogs"
  azure_ad_app            = "auth-dev-affiliates"
  log_analytics_workspace = "law-dev-affiliates"
}

# Location
location = "northeurope"

# Tags
tags = {
  Environment = "Development"
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
  alert_threshold_percents = [50, 75, 90]
}
