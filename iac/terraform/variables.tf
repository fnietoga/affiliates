variable "location" {
  description = "Azure location where resources will be deployed."
  type        = string
  default     = "northeurope" # Change to your preferred region
}

# Grouped resource names
variable "resource_names" {
  description = "Object containing all resource names used in the deployment"
  type = object({
    resource_group          = string
    app_service_plan        = string
    frontend_app            = string
    backend_app             = string
    frontend_static_app     = string
    sql_server              = string
    sql_database            = string
    key_vault               = string
    app_insights            = string
    logs_storage            = string
    azure_ad_app            = string
    log_analytics_workspace = string
  })
}

variable "sql_admin_login" {
  description = "Username for the Azure SQL Server administrator."
  type        = string
}

variable "tags" {
  description = "Common tags to apply to resources."
  type        = map(string)
  default     = {}
}

variable "allowed_ip_addresses" {
  description = "List of IP addresses allowed to access the backend API"
  type        = list(string)
  default     = []
}

variable "authorized_app_users" {
  description = "Lista de nombres principales de usuario (emails) autorizados para acceder al frontend y con permisos de lectura en la API"
  type        = list(string)
  default     = []
}

variable "budget_config" {
  description = "Configuration for the resource group budget and alerts."
  type = object({
    amount                   = number       # Monthly budget amount in EUR
    alert_email              = string       # Email to send alerts to
    alert_threshold_percents = list(number) # Percentages to trigger alerts at
  })
  default = {
    amount                   = 50                  # Slightly above expected monthly cost
    alert_email              = "admin@example.com" # Change this to your actual email
    alert_threshold_percents = [70, 90, 100]       # Standard thresholds for notifications
  }
}
