# --- Database resources for Affiliate Application ---
# This file contains all resources related to the SQL Server and Database

# --- Azure SQL Server ---
resource "azurerm_mssql_server" "sqlserver" {
  #checkov:skip=CKV_AZURE_113:Ensure that SQL server disables public network access
  #checkov:skip=CKV_AZURE_23:Ensure that 'Auditing' is set to 'On' for SQL servers
  #checkov:skip=CKV_AZURE_24:Ensure that 'Auditing' Retention is 'greater than 90 days' for SQL servers
  #checkov:skip=CKV2_AZURE_45:Ensure Microsoft SQL server is configured with private endpoint
  #checkov:skip=CKV2_AZURE_2:Ensure that Vulnerability Assessment (VA) is enabled on a SQL server by setting a Storage Account ##TODO
  name                                 = var.resource_names.sql_server
  resource_group_name                  = azurerm_resource_group.rg.name
  location                             = azurerm_resource_group.rg.location
  version                              = "12.0" # Standard SQL Server version
  minimum_tls_version                  = "1.2"
  public_network_access_enabled        = true
  outbound_network_restriction_enabled = true
  administrator_login                  = var.sql_admin_login
  administrator_login_password         = random_password.sql_admin_password.result

  # Enable Azure AD authentication using the administrators group
  azuread_administrator {
    login_username              = azuread_group.sql_admins.display_name
    object_id                   = azuread_group.sql_admins.object_id
    tenant_id                   = data.azurerm_client_config.current.tenant_id
    azuread_authentication_only = false
  }

  tags = var.tags

  depends_on = [
    azuread_group.sql_admins,
    random_password.sql_admin_password
  ]
}

# --- Generate Random Password for SQL Server ---
resource "random_password" "sql_admin_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?" # Avoid characters that might cause shell escaping issues
}

# --- Store database credentials in Key Vault ---

# Store SQL admin password
resource "azurerm_key_vault_secret" "sql_admin_password" {
  #checkov:skip=CKV_AZURE_41:Ensure that the expiration date is set on all secrets
  name         = "sql-admin-password"
  value        = random_password.sql_admin_password.result
  key_vault_id = azurerm_key_vault.kv.id
  content_type = "password"

  depends_on = [
    azurerm_key_vault.kv,
    azurerm_role_assignment.kv_admin_role
  ]
}

# Store SQL admin username
resource "azurerm_key_vault_secret" "sql_admin_username" {
  #checkov:skip=CKV_AZURE_41:Ensure that the expiration date is set on all secrets
  name         = "sql-admin-username"
  value        = var.sql_admin_login
  key_vault_id = azurerm_key_vault.kv.id
  content_type = "username"

  depends_on = [
    azurerm_key_vault.kv,
    azurerm_role_assignment.kv_admin_role
  ]
}

# Store JDBC connection string for Flyway
resource "azurerm_key_vault_secret" "jdbc_connection_string" {
  #checkov:skip=CKV_AZURE_41:Ensure that the expiration date is set on all secrets
  name         = "jdbc-connection-string"
  value        = "jdbc:sqlserver://${azurerm_mssql_server.sqlserver.fully_qualified_domain_name};databaseName=${azurerm_mssql_database.sqldb.name};encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;"
  key_vault_id = azurerm_key_vault.kv.id
  content_type = "jdbc-connection-string"

  depends_on = [
    azurerm_key_vault.kv,
    azurerm_mssql_server.sqlserver,
    azurerm_mssql_database.sqldb,
    azurerm_role_assignment.kv_admin_role
  ]
}

# Configure SQL Firewall for App Service outbound IPs using null_resource and Azure CLI
# This approach avoids using count/foreach with dynamic IPs that are only known after deployment
resource "null_resource" "configure_sql_firewall_rules" {
  # Trigger this resource whenever the App Service or SQL Server changes
  triggers = {
    app_service_id = azurerm_linux_web_app.backend_app.id
    sql_server_id  = azurerm_mssql_server.sqlserver.id
  }

  # Execute Azure CLI commands to configure firewall rules
  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = <<-EOT
      # Get outbound IP addresses from App Service
      OUTBOUND_IPS=$(az webapp show --resource-group ${azurerm_resource_group.rg.name} \
        --name ${azurerm_linux_web_app.backend_app.name} \
        --query outboundIpAddresses --output tsv)
      
      echo "Configuring firewall rules for App Service outbound IPs: $OUTBOUND_IPS"
      
      # Remove existing App Service IP rules (if any) to avoid duplicates
      az sql server firewall-rule list --resource-group ${azurerm_resource_group.rg.name} \
        --server ${azurerm_mssql_server.sqlserver.name} | \
        grep -i "AppServiceOutboundIP" | \
        jq -r '.[].name' | \
        while read -r rule_name; do \
          echo "Removing existing rule: $rule_name" && \
          az sql server firewall-rule delete \
            --resource-group ${azurerm_resource_group.rg.name} \
            --server ${azurerm_mssql_server.sqlserver.name} \
            --name "$rule_name" \
            --output none; \
        done || echo "No existing rules to remove"
      
      # Add new rules for each outbound IP
      IFS=',' read -ra IP_ARRAY <<< "$OUTBOUND_IPS"
      IP_COUNT=0
      for IP in $OUTBOUND_IPS; do
        echo "Adding firewall rule for IP: $IP"
        az sql server firewall-rule create \
          --resource-group ${azurerm_resource_group.rg.name} \
          --server ${azurerm_mssql_server.sqlserver.name} \
          --name "AppServiceOutboundIP-$IP_COUNT" \
          --start-ip-address "$IP" \
          --end-ip-address "$IP" \
          --output none
        IP_COUNT=$((IP_COUNT+1))
      done
      
      echo "SQL Firewall configuration completed"
    EOT
  }

  # Ensure this runs after both the App Service and SQL Server are created
  depends_on = [
    azurerm_linux_web_app.backend_app,
    azurerm_mssql_server.sqlserver
  ]
}

# Add firewall rule to allow Azure services via private links (Service endpoints)
resource "azurerm_mssql_firewall_rule" "azure_backbone" {
  #checkov:skip=CKV2_AZURE_34:Ensure Azure SQL server firewall is not overly permissive
  name             = "AllowAzureBackbone"
  server_id        = azurerm_mssql_server.sqlserver.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}
# resource "azurerm_mssql_firewall_rule" "current_deployment_ip" {
#   name             = "CurrentDeploymentIP"
#   server_id        = azurerm_mssql_server.sqlserver.id
#   start_ip_address = local.current_deployment_ip
#   end_ip_address   = local.current_deployment_ip
# }
resource "azurerm_mssql_firewall_rule" "allowed_ips" {
  count            = length(var.allowed_ip_addresses)
  name             = "AllowedIP-${count.index}"
  server_id        = azurerm_mssql_server.sqlserver.id
  start_ip_address = var.allowed_ip_addresses[count.index]
  end_ip_address   = var.allowed_ip_addresses[count.index]
}

# --- Azure SQL Database (Basic tier) ---
resource "azurerm_mssql_database" "sqldb" {
  #checkov:skip=CKV_AZURE_224:Ensure that the Ledger feature is enabled on database that requires cryptographic proof and nonrepudiation of data integrity
  #checkov:skip=CKV_AZURE_229:Ensure the Azure SQL Database Namespace is zone redundant
  name        = var.resource_names.sql_database
  server_id   = azurerm_mssql_server.sqlserver.id
  collation   = "SQL_Latin1_General_CP1_CI_AS"
  sku_name    = "GP_S_Gen5_1" # 1 vCore General Purpose Serverless
  max_size_gb = 32            # Adjust as needed for your data requirements
  tags        = var.tags

  # Cost optimization: Serverless with auto-pause for intermittent workloads
  auto_pause_delay_in_minutes = 60  # Auto-pause after 1 hour of inactivity
  min_capacity                = 0.5 # Minimum capacity in vCores
}

# Add a resource lock to prevent accidental deletion of the database
# resource "azurerm_management_lock" "database_lock" {
#   name       = "${var.resource_names.sql_database}-delete-lock"
#   scope      = azurerm_mssql_database.sqldb.id
#   lock_level = "CanNotDelete"
#   notes      = "Prevent accidental deletion of the database. Remove this lock before attempting to delete the database."
# }

# Create an Entra ID (Azure AD) group for SQL Server Administrators
resource "azuread_group" "sql_admins" {
  display_name     = "${upper(var.resource_names.sql_server)}_SQL_ADMINS"
  security_enabled = true
  description      = "SQL Server administrators for the affiliates application"
}

# Add the current deployment identity to the SQL administrators group
resource "azuread_group_member" "current_user_as_admin" {
  group_object_id  = azuread_group.sql_admins.object_id
  member_object_id = data.azurerm_client_config.current.object_id
}

# Assign SQL DB Contributor role to the backend app's managed identity
# This enables passwordless connections using the system-assigned managed identity
resource "azurerm_role_assignment" "backend_sql_contributor" {
  scope                = azurerm_mssql_database.sqldb.id
  role_definition_name = "SQL DB Contributor"
  principal_id         = azurerm_linux_web_app.backend_app.identity[0].principal_id

  depends_on = [
    azurerm_linux_web_app.backend_app,
    azurerm_mssql_database.sqldb
  ]
}

# Grant additional permissions for the managed identity in SQL
# Note: Some database permissions need to be granted with SQL commands
# which would typically be handled during database deployment
