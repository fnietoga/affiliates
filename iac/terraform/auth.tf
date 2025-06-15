# --- Authentication Configuration ---
# This file contains resources for Azure AD (Entra ID) authentication for both frontend and backend

# Unified Azure AD App Registration for the application
resource "azuread_application" "app" {
  display_name     = var.resource_names.azure_ad_app
  identifier_uris  = ["api://${var.resource_names.backend_app}"]
  owners           = [data.azurerm_client_config.current.object_id]
  sign_in_audience = "AzureADMyOrg" # Only users in your organization can sign in

  api {
    mapped_claims_enabled          = true
    requested_access_token_version = 2
  }

  # Define roles for the application
  app_role {
    allowed_member_types = ["User"]
    description          = "Allow the application to access the Affiliates API on behalf of the signed-in user."
    display_name         = "Access Affiliates API"
    enabled              = true
    id                   = "00000000-0000-0000-0000-000000000001" # Custom UUID
    value                = "Api.Read"
  }

  app_role {
    allowed_member_types = ["User"]
    description          = "Allow the application to write to the Affiliates API on behalf of the signed-in user."
    display_name         = "Write to Affiliates API"
    enabled              = true
    id                   = "00000000-0000-0000-0000-000000000002" # Custom UUID
    value                = "Api.Write"
  }

  app_role {
    allowed_member_types = ["User"]
    description          = "Allows users to access the frontend application."
    display_name         = "Frontend Access"
    enabled              = true
    id                   = "00000000-0000-0000-0000-000000000003" # Custom UUID
    value                = "Frontend.Access"
  }

  web {
    homepage_url = "https://${var.resource_names.frontend_app}.azurewebsites.net"
    redirect_uris = [
      "https://${var.resource_names.backend_app}.azurewebsites.net/.auth/login/aad/callback",
      "https://${var.resource_names.frontend_app}.azurewebsites.net/.auth/login/aad/callback"
    ]

    implicit_grant {
      id_token_issuance_enabled     = true
      access_token_issuance_enabled = true
    }
  }

  # Microsoft Graph permissions
  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph

    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d" # User.Read
      type = "Scope"
    }
  }

  tags = ["Terraform", "API", "Frontend", "Affiliates"]
}

# Unified Service Principal for the application
resource "azuread_service_principal" "app" {
  client_id = azuread_application.app.client_id
  # Require users to be assigned to the app for both backend and frontend
  app_role_assignment_required = true

  tags = ["Terraform", "API", "Frontend", "Affiliates"]
}

# Create app password for client authentication
resource "time_rotating" "app_expiration" {
  rotation_months = 6
}

resource "azuread_application_password" "app" {
  #checkov:skip=CKV_SECRET_6:Consider adding expiration date to sensitive credentials
  display_name   = "Terraform-managed app secret"
  application_id = azuread_application.app.id
  rotate_when_changed = {
    rotation = time_rotating.app_expiration.id
  }
}

# Store the app credentials in Key Vault
resource "azurerm_key_vault_secret" "app_client_id" {
  #checkov:skip=CKV_AZURE_41:Ensure that the expiration date is set on all secrets
  name         = "app-client-id"
  value        = azuread_application.app.client_id
  key_vault_id = azurerm_key_vault.kv.id
  content_type = "client-id"

  depends_on = [
    azurerm_key_vault.kv,
    azurerm_role_assignment.kv_admin_role
  ]
}

resource "azurerm_key_vault_secret" "app_client_secret" {
  name            = "app-client-secret"
  value           = azuread_application_password.app.value
  key_vault_id    = azurerm_key_vault.kv.id
  content_type    = "client-secret"
  expiration_date = time_rotating.app_expiration.id

  depends_on = [
    azurerm_key_vault.kv,
    azurerm_role_assignment.kv_admin_role
  ]
}
