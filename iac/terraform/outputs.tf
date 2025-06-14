output "resource_group_name" {
  description = "Name of the resource group."
  value       = azurerm_resource_group.rg.name
}

output "backend_app_service_hostname" {
  description = "Hostname of the backend App Service."
  value       = azurerm_linux_web_app.backend_app.default_hostname
}

output "frontend_app_service_hostname" {
  description = "URL of the frontend Static Web App."
  value       = azurerm_linux_web_app.frontend_app.default_hostname
}

output "sql_server_fqdn" {
  description = "FQDN of the Azure SQL server."
  value       = azurerm_mssql_server.sqlserver.fully_qualified_domain_name
}

output "sql_database_name" {
  description = "Name of the Azure SQL Database."
  value       = azurerm_mssql_database.sqldb.name
}

output "key_vault_uri" {
  description = "URI of the Azure Key Vault."
  value       = azurerm_key_vault.kv.vault_uri
}

output "application_insights_instrumentation_key" {
  description = "Instrumentation key for Application Insights."
  value       = azurerm_application_insights.appi.instrumentation_key
  sensitive   = true
}

# Outputs from auth.tf
output "backend_app_id" {
  description = "The Application (client) ID of the app registration"
  value       = azuread_application.app.client_id
}

output "backend_tenant_id" {
  description = "The Directory (tenant) ID"
  value       = data.azurerm_client_config.current.tenant_id
}

# Outputs from logs_storage.tf
output "logs_storage_account_name" {
  description = "Name of the storage account for logs and website content"
  value       = azurerm_storage_account.backend.name
}

output "logs_sas_url_http" {
  description = "SAS URL for HTTP logs container"
  value       = "${azurerm_storage_account.backend.primary_blob_endpoint}${azurerm_storage_container.http_logs.name}${data.azurerm_storage_account_sas.logs_sas.sas}"
  sensitive   = true
}

output "logs_sas_url_app" {
  description = "SAS URL for application logs container"
  value       = "${azurerm_storage_account.backend.primary_blob_endpoint}${azurerm_storage_container.app_logs.name}${data.azurerm_storage_account_sas.logs_sas.sas}"
  sensitive   = true
}
