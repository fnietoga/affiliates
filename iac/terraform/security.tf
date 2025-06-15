# --- Security resources for Affiliate Application ---
# This file contains all resources related to security, such as Key Vault and Azure AD

# --- Azure Key Vault for Secrets ---
resource "azurerm_key_vault" "kv" {
  #checkov:skip=CKV_AZURE_110:Ensure that key vault enables purge protection
  #checkov:skip=CKV_AZURE_189:Ensure that Azure Key Vault disables public network access
  #checkov:skip=CKV2_AZURE_32:Ensure private endpoint is configured to key vault
  #checkov:skip=CKV_AZURE_42: "Ensure the key vault is recoverable"
  name                       = var.resource_names.key_vault
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days = 7
  purge_protection_enabled   = false # Consider enabling for production
  sku_name                   = "standard"
  enable_rbac_authorization  = true # Enable RBAC-based authorization

  tags = var.tags

  # Access is now controlled via RBAC instead of access policies
  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules = concat(
      var.allowed_ip_addresses,
      [local.current_deployment_ip]
    )
  }
}

# --- RBAC role assignments for Key Vault ---

# Assign Key Vault Administrator role to the deployment identity
resource "azurerm_role_assignment" "kv_admin_role" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Assign Key Vault Secrets Officer role to the backend app's managed identity
resource "azurerm_role_assignment" "app_secrets_role" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = azurerm_linux_web_app.backend_app.identity[0].principal_id

  depends_on = [
    azurerm_linux_web_app.backend_app
  ]
}
