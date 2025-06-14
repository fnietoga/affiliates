# --- Main Configuration ---
# This file contains the core infrastructure configuration and shared data sources

# --- Data sources for current client config and Azure AD ---
data "azurerm_client_config" "current" {}
data "azurerm_subscription" "primary" {}
data "http" "myip" {
  url = "https://ipv4.icanhazip.com"
}
locals {
  current_deployment_ip = chomp(data.http.myip.response_body)
}
# --- Core Resources ---
# Resource Group - All resources will be deployed into this group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_names.resource_group
  location = var.location
  tags     = var.tags
}

# --- Workspace Configuration ---
# This allows us to use workspaces for different environments (dev, staging, prod)
# The workspace name can be set via the TF_WORKSPACE environment variable or 
# using the terraform workspace commands

# --- Module References ---
# This section can be used to reference any modules if needed in the future
# For example, if you create modules for networking, monitoring, etc.

# module "networking" {
#   source = "./modules/networking"
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_resource_group.rg.location
#   tags                = var.tags
# }

