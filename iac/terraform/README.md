# Infrastructure Deployment with Terraform

This directory contains the Terraform scripts to define and deploy the Afiliados application infrastructure on Azure with support for multiple environments (development, production).

## Prerequisites

1. **Install Terraform CLI**: Download and install Terraform from [terraform.io](https://www.terraform.io/downloads.html).
2. **Azure CLI**: Ensure you have Azure CLI installed and configured. Log in with `az login`.
3. **Configure Terraform Variables**:
   * Review and adjust environment-specific values in `config/development.tfvars` and `config/production.tfvars`.
   * For sensitive variables like `sql_admin_password`, create a file named `terraform.tfvars` (or `personal.auto.tfvars`) in this directory (`iac/terraform/`) and define the variable there. This file is ignored by Git thanks to the `.gitignore` in this same directory.

      **Example of `terraform.tfvars`**:
      ```terraform
      sql_admin_password = "YourSuperSecurePassword123!"

      # Ensure these names are globally unique if the defaults are not:
      # backend_app_service_name       = "app-afiliados-api-youruniquelas"
      # frontend_static_web_app_name = "stapp-afiliados-frontend-youruniquelas"
      # sql_server_name                = "sql-afiliados-server-youruniquelas"
      # key_vault_name                 = "kv-afiliados-secrets-youruniquelas"
      ```

## Local Development

### Azure Authentication

To run Terraform locally, you need to configure the `ARM_SUBSCRIPTION_ID` environment variable with your Azure subscription ID:

```bash
# In Windows PowerShell
$env:ARM_SUBSCRIPTION_ID="your-subscription-id"

# In Linux/macOS
export ARM_SUBSCRIPTION_ID="your-subscription-id"
```

This variable is necessary for Terraform to correctly access your Azure subscription.

### Backend Configuration

The backend configuration for storing Terraform state in Azure Storage requires specifying the correct environment variables:

1. **Initialize Terraform with Development Backend**:
   ```bash
   terraform init \
     -backend-config="backend/development.tfvars" \
     -backend-config="storage_account_name=<your-dev-storage-account>" \
   ```

2. **Initialize Terraform with Production Backend**:
   ```bash
   terraform init \
     -backend-config="backend/production.tfvars" \
     -backend-config="storage_account_name=<your-prod-storage-account>" \
   ```

### Apply Changes Locally

When working with different environments, specify the appropriate variable file:

```bash
# For development environment
terraform plan -var-file="./config/development.tfvars" -out="dev.tfplan"
terraform apply "dev.tfplan"

# For production environment
terraform plan -var-file="./config/production.tfvars" -out="prod.tfplan"
terraform apply "prod.tfplan"
```

## CI/CD with GitHub Actions

This project implements a secure CI/CD pipeline using GitHub Actions for deploying to multiple environments:

1. **Workflow File**: Located at `.github/workflows/terraform.yml`
2. **Authentication**: Uses OpenID Connect (OIDC) for secure, passwordless authentication to Azure
3. **Multi-Environment Support**: Separate deployment jobs for development and production environments
4. **Security Features**: Sensitive parameters stored as GitHub Secrets, not in code

### GitHub Secrets Required

The following secrets must be configured in your GitHub repository:

- `AZURE_CLIENT_ID`: The client ID for GitHub Actions OIDC authentication
- `AZURE_TENANT_ID`: Your Azure tenant ID
- `AZURE_SUBSCRIPTION_ID`: Your Azure subscription ID
- `AZURE_TERRAFORM_STATE_DEV_RESOURCE_ID`: The full Azure Resource ID of the storage account for dev environment state
- `AZURE_TERRAFORM_STATE_PROD_RESOURCE_ID`: The full Azure Resource ID of the storage account for prod environment state

Example Resource ID format:
```
/subscriptions/{subscription-id}/resourceGroups/{resource-group-name}/providers/Microsoft.Storage/storageAccounts/{storage-account-name}
```

### OIDC Setup

To set up OIDC authentication:

1. Run the `setup-oidc.ps1` script from the `iac/scripts/` directory
2. Follow the prompts to create the Azure AD application with federation credentials for GitHub Actions
3. Add the output values to your GitHub repository secrets

## Multi-Environment Setup

This project supports multiple environments (dev, prod) using environment-specific configurations and state files.

### Environment-Specific Configuration

- Non-sensitive backend configurations are stored in the `backend/` directory as `.tfvars` files:
  - `dev.tfvars`: Configuration for development environment
  - `prod.tfvars`: Configuration for production environment
- Only non-sensitive parameters like `container_name` and `key` are stored in these files
- Sensitive parameters like `resource_group_name` and `storage_account_name` are derived at runtime from the Resource ID

### Backend Configuration

- The Terraform state is stored in Azure Storage, with separate state files for each environment
- Backend configuration is dynamically constructed in the GitHub Actions pipeline by:
  1. Extracting resource group name and storage account name from the Azure Resource ID
  2. Reading non-sensitive values from the appropriate `.tfvars` file
  3. Combining them for the Terraform init command

### Local Development

For local development and testing:

1. Create a local `backend.tf` file with your Azure Storage configuration
2. Use the format:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "your-resource-group"
    storage_account_name = "yourstorageaccount"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
    use_azuread_auth     = true
  }
}
```

## Terraform Commands for Local Development

### Local Terraform Workflow

1. **Initialize Terraform**:
   ```powershell
   terraform init
   ```

2. **Validate Configuration**:
   ```powershell
   terraform validate
   ```

3. **Create an Execution Plan**:
   ```powershell
   terraform plan -out=tfplan
   ```

4. **Apply the Plan**:
   ```powershell
   terraform apply "tfplan"
   ```

5. **View Outputs**:
   ```powershell
   terraform output
   ```
   Displays the output values defined in `outputs.tf` (e.g., URLs, resource names).

### Working with Different Environments Locally

To work with different environments locally:

1. Modify your `backend.tf` to point to the appropriate state file:
   ```hcl
   key = "dev.terraform.tfstate"  # For development
   ```
   or
   ```hcl
   key = "prod.terraform.tfstate"  # For production
   ```

2. Use environment-specific variable files with the `-var-file` flag:
   ```powershell
   terraform plan -var-file="config/dev.tfvars" -out="dev.tfplan"
   terraform apply "dev.tfplan"
   ```

6. **Destroy Infrastructure**:
   **WARNING!** This command will delete all Terraform-managed resources in Azure according to the current configuration. Use with caution.
   ```powershell
   terraform destroy
   ```

## GitHub Actions Workflow

### Main Features

1. **Triggers**:
   - Pushes to `main`, `feat/*`, and `fix/*` branches
   - Pull requests against `main`
   - Manual workflow dispatch

2. **Jobs**:
   - `validate-and-plan`: Validates Terraform files and creates a plan
   - `deploy-dev`: Deploys to development environment (automatic on push to specified branches)
   - `deploy-prod`: Deploys to production (requires manual approval via GitHub Environments)

3. **Security**:
   - Uses OIDC authentication (no stored credentials)
   - Extracts sensitive backend values from GitHub Secrets
   - Enables Azure AD authentication for Terraform state access

## Important Notes

* **Globally Unique Names**: Several Azure resources (App Services, SQL Server, Key Vault, Static Web Apps) require globally unique names. Ensure you adjust the default values in `variables.tf` or in your `.tfvars` file to avoid conflicts.

* **Secure Backend Configuration**: The backend configuration security has been improved by:
  - Storing sensitive values (resource group name, storage account name) as GitHub Secrets
  - Dynamically parsing these values from Resource IDs
  - Only using `.tfvars` files for non-sensitive parameters

* **Key Vault and Secrets**: The scripts create an Azure Key Vault. The intention is to store secrets like the database connection string in Key Vault and have your applications (App Service) access them via Managed Identities.

* **CI/CD Integration**: This project includes a complete GitHub Actions workflow for continuous integration and deployment, with separate environments and approval gates.
