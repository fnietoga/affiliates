terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.33"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~>3.4"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "~>2.4"
    }
  }
}

# --- Provider Configuration ---
# Azure Provider configuration is typically in a separate file (provider.tf)
# but we keep it here for simplicity in this example

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
  # If using Azure CLI for authentication, this is the simplest configuration.
  # You can also configure authentication using Service Principal, Managed Identity, etc.
  # subscription_id = "YOUR_SUBSCRIPTION_ID" # Optional if using Azure CLI with the correct subscription selected
  # client_id       = "YOUR_CLIENT_ID"       # For Service Principal
  # client_secret   = "YOUR_CLIENT_SECRET"   # For Service Principal
  # tenant_id       = "YOUR_TENANT_ID"       # For Service Principal
}

provider "azuread" {
  # Uses the same authentication as azurerm provider
  # This will be used for Azure AD operations needed for RBAC
}

provider "azapi" {
  # Uses the same authentication as azurerm provider
}

# --- Backend Configuration ---
terraform {
  backend "azurerm" {
    use_azuread_auth = true                # Can also be set via `ARM_USE_AZUREAD` environment variable.
    key              = "terraform.tfstate" # Can be passed via `-backend-config=`"key=<blob key name>"` in the `init` command.
  }
}