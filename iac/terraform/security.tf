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

  tags = var.tags

  # Access policy for the deployment identity
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get", "List", "Set", "Delete", "Purge", "Recover"
    ]
  }
  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules = concat(
      var.allowed_ip_addresses,
      [local.current_deployment_ip]
    )
  }
}
