# --- User Assignment Configuration ---
# This file contains resources for assigning specific users to the application

# Obtain user information from Azure AD
data "azuread_users" "authorized_users" {
  user_principal_names = var.authorized_app_users
}

# Create user assignments to the unified application with Frontend Access role
resource "azuread_app_role_assignment" "frontend_users" {
  for_each = toset(var.authorized_app_users)

  # Use the Frontend Access role ID
  app_role_id = "00000000-0000-0000-0000-000000000003" # Frontend.Access role
  principal_object_id = [
    for user in data.azuread_users.authorized_users.users :
    user.id if user.user_principal_name == each.value
  ][0]
  resource_object_id = azuread_service_principal.app.object_id

  # The assignment may need to be created after the service principal
  depends_on = [
    azuread_service_principal.app
  ]
}

# Create API user assignments if the same users need API access
resource "azuread_app_role_assignment" "api_users" {
  for_each = toset(var.authorized_app_users) # Reutilizamos la misma lista de usuarios

  # Use the API.Read role ID
  app_role_id = "00000000-0000-0000-0000-000000000001" # Api.Read role
  principal_object_id = [
    for user in data.azuread_users.authorized_users.users :
    user.id if user.user_principal_name == each.value
  ][0]
  resource_object_id = azuread_service_principal.app.object_id

  # The assignment may need to be created after the service principal
  depends_on = [
    azuread_service_principal.app
  ]
}
