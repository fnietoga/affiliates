# --- Storage Account for Application Logs ---
# This file contains resources for storing application and http logs

# Create a storage account for logs and content
resource "azurerm_storage_account" "backend" {
  #checkov:skip=CKV_AZURE_206:Ensure that Storage Accounts use replication
  #checkov:skip=CKV_AZURE_33: "Ensure Storage logging is enabled for Queue service for read, write and delete requests"
  #checkov:skip=CKV_AZURE_59: "Ensure that Storage accounts disallow public access"
  #checkov:skip=CKV2_AZURE_1: "Ensure storage for critical data are encrypted with Customer Managed Key"
  #checkov:skip=CKV2_AZURE_41: "Ensure storage account is configured with SAS expiration policy"
  #checkov:skip=CKV2_AZURE_33: "Ensure storage account is configured with private endpoint"
  #checkov:skip=CKV2_AZURE_40: "Ensure storage account is not configured with Shared Key authorization"
  name                            = var.resource_names.logs_storage
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices", "Logging", "Metrics"]
    ip_rules = concat(
      var.allowed_ip_addresses,
      [local.current_deployment_ip]
    )
  }
  # Enable blob service for logs
  blob_properties {
    delete_retention_policy {
      days = 7
    }
    container_delete_retention_policy {
      days = 7
    }
  }

  # Enable file shares for website content
  share_properties {
    retention_policy {
      days = 7
    }
  }

  tags = var.tags
}

# Create containers for different types of logs and content
resource "azurerm_storage_container" "http_logs" {
  #checkov:skip=CKV2_AZURE_21: "Ensure Storage logging is enabled for Blob service for read requests"
  name                  = "http-logs"
  storage_account_id    = azurerm_storage_account.backend.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "app_logs" {
  #checkov:skip=CKV2_AZURE_21: "Ensure Storage logging is enabled for Blob service for read requests"
  name                  = "app-logs"
  storage_account_id    = azurerm_storage_account.backend.id
  container_access_type = "private"
}

# Create file shares for website content mounting
resource "azurerm_storage_share" "website_content" {
  name               = "website-content"
  storage_account_id = azurerm_storage_account.backend.id
  quota              = 5 # 5GB quota
}

# Create a file share for frontend content
resource "azurerm_storage_share" "frontend_content" {
  name               = "frontend-content"
  storage_account_id = azurerm_storage_account.backend.id
  quota              = 5 # 5GB quota
}

# Generate SAS token for the backend storage account
data "azurerm_storage_account_sas" "logs_sas" {
  connection_string = azurerm_storage_account.backend.primary_connection_string
  https_only        = true
  signed_version    = "2019-12-12"

  resource_types {
    service   = false
    container = true
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = "2023-01-01"
  expiry = "2030-01-01"

  permissions {
    read    = true
    write   = true
    delete  = true
    list    = true
    add     = true
    create  = true
    update  = true
    process = false
    tag     = false
    filter  = false
  }
}


