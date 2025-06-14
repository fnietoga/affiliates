#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Setup OIDC authentication between GitHub Actions and Azure AD
.DESCRIPTION
    This script automates the setup of OIDC authentication between GitHub Actions and Azure AD.
    It creates an Azure AD application, service principal, assigns necessary permissions,
    and configures federated credentials for GitHub Actions.
.PARAMETER SubscriptionId
    The Azure Subscription ID where the service principal will have permissions
.PARAMETER AppDisplayName
    The display name for the Azure AD application (default: GitHub-Terraform-OIDC)
.PARAMETER GitHubOrgRepo
    The GitHub organization/repository (format: org/repo)
.PARAMETER GitHubBranch
    The GitHub branch to configure for OIDC (default: main)
.EXAMPLE
    .\setup-oidc.ps1 -SubscriptionId "00000000-0000-0000-0000-000000000000" -GitHubOrgRepo "fnietoga/affiliates"
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$SubscriptionId,
    
    [Parameter(Mandatory = $false)]
    [string]$AppDisplayName = "GitHub-Terraform-OIDC",
    
    [Parameter(Mandatory = $true)]
    [string]$GitHubOrgRepo,
    
    [Parameter(Mandatory = $false)]
    [string]$GitHubBranch = "main"
)

# Check if az CLI is installed
try {
    az --version
}
catch {
    Write-Error "Azure CLI not found. Please install it: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
}

# Login check
Write-Host "Checking Azure CLI login status..." -ForegroundColor Cyan
$loginStatus = az account show --output json | ConvertFrom-Json
if (-not $loginStatus) {
    Write-Host "You need to login to Azure first. Running 'az login'..." -ForegroundColor Yellow
    az login
}

# Set the subscription
Write-Host "Setting subscription to $SubscriptionId..." -ForegroundColor Cyan
az account set --subscription $SubscriptionId
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to set subscription. Exiting."
    exit 1
}

# 1. Create the Azure AD application
Write-Host "Creating Azure AD application: $AppDisplayName..." -ForegroundColor Cyan

# Create the application
$app = az ad app create --display-name $AppDisplayName | ConvertFrom-Json
$appObjectId = $app.id
$appId = $app.appId
Write-Host "Application created with ID: $appId" -ForegroundColor Green

# Add required API permissions
Write-Host "Adding API permissions to the application..." -ForegroundColor Cyan

# Microsoft Graph API permissions
$graphApiId = "00000003-0000-0000-c000-000000000000" # Microsoft Graph API ID

# Application.ReadWrite.OwnedBy permission
$appReadWritePermission = az ad sp show --id $graphApiId --query "appRoles[?value=='Application.ReadWrite.OwnedBy'].id" -o tsv

# Group.ReadWrite.All permission
$groupReadWritePermission = az ad sp show --id $graphApiId --query "appRoles[?value=='Group.ReadWrite.All'].id" -o tsv

# Add permissions
az ad app permission add --id $appObjectId \
    --api $graphApiId \
    --api-permissions "$appReadWritePermission=Role $groupReadWritePermission=Role"

# Grant admin consent
Write-Host "Granting admin consent for API permissions..." -ForegroundColor Cyan
az ad app permission admin-consent --id $appObjectId

Write-Host "API permissions added and consent granted" -ForegroundColor Green

# 2. Create the service principal
Write-Host "Creating service principal for application ID: $appId..." -ForegroundColor Cyan
$sp = az ad sp create --id $appId | ConvertFrom-Json
$spObjectId = $sp.id
Write-Host "Service principal created with Object ID: $spObjectId" -ForegroundColor Green

# 3. Assign Contributor role to the service principal
Write-Host "Assigning Contributor role to service principal at subscription scope..." -ForegroundColor Cyan
# Assign Contributor role at subscription level
$roleAssignment = az role assignment create `
    --role "Contributor" `
    --scope "/subscriptions/$SubscriptionId" `
    --assignee-object-id $spObjectId `
    --assignee-principal-type ServicePrincipal | ConvertFrom-Json
# Allow to assign non-privileged roles
$roleAssignment = az role assignment create `
    --role "Role Based Access Control Administrator" `
    --scope "/subscriptions/$SubscriptionId" `
    --condition-version 2 `
    --condition "((!(ActionMatches{'Microsoft.Authorization/roleAssignments/write'})) OR (@Request[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAllValues:GuidNotEquals {8e3af657-a8ff-443c-a75c-2fe8c4bcb635, 18d7d88d-d35e-4fb5-a5c3-7773c20a72d9, f58310d9-a9f6-439a-9e8d-f62e7b41a168})) AND ((!(ActionMatches{'Microsoft.Authorization/roleAssignments/delete'})) OR (@Resource[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAllValues:GuidNotEquals {8e3af657-a8ff-443c-a75c-2fe8c4bcb635, 18d7d88d-d35e-4fb5-a5c3-7773c20a72d9, f58310d9-a9f6-439a-9e8d-f62e7b41a168}))" `
    --assignee-object-id $spObjectId `
    --assignee-principal-type ServicePrincipal | ConvertFrom-Json

# NOTE: The service principal also needs the following permissions on the Terraform state storage account:
# - Reader role at the storage account scope
# - Storage Blob Data Contributor role at the container scope
# These permissions must be granted manually or through additional Azure CLI commands

Write-Host "Role assignment created" -ForegroundColor Green

# 4. Create federation credentials for GitHub Actions (main branch)
Write-Host "Creating federated credentials for GitHub Actions (main branch)..." -ForegroundColor Cyan

# Create a temporary JSON file for the federation credentials
$fedCredentialsPath = Join-Path -Path $env:TEMP -ChildPath "fed-credentials.json"
@"
{
    "name": "github-actions",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:${GitHubOrgRepo}:ref:refs/heads/${GitHubBranch}",
    "audiences": ["api://AzureADTokenExchange"],
    "description": "GitHub Actions for Terraform deployment"
}
"@ | Out-File -FilePath $fedCredentialsPath -Encoding utf8

az ad app federated-credential create --id $appId --parameters $fedCredentialsPath
Write-Host "Federated credentials for main branch created" -ForegroundColor Green

# Create federated credentials for pull requests if desired
$createPRCredentials = Read-Host "Do you want to create federated credentials for pull requests? (y/n)"
if ($createPRCredentials -eq 'y') {
    Write-Host "Creating federated credentials for pull requests..." -ForegroundColor Cyan
    @"
{
    "name": "github-actions-pull-requests",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:${GitHubOrgRepo}:pull_request",
    "audiences": ["api://AzureADTokenExchange"],
    "description": "GitHub Actions for Terraform plan on pull requests"
}
"@ | Out-File -FilePath $fedCredentialsPath -Encoding utf8

    az ad app federated-credential create --id $appId --parameters $fedCredentialsPath
    Write-Host "Federated credentials for pull requests created" -ForegroundColor Green
}

# Clean up
Remove-Item $fedCredentialsPath -Force

# Display summary and next steps
Write-Host @"

┌─────────────────────────────────────────────────────────────────────────┐
│                       OIDC Configuration Complete                       │
└─────────────────────────────────────────────────────────────────────────┘

Please add the following secrets to your GitHub repository:

AZURE_CLIENT_ID       : $appId
AZURE_TENANT_ID       : $($loginStatus.tenantId)
AZURE_SUBSCRIPTION_ID : $SubscriptionId

Make sure the workflow YAML file has these permissions:

permissions:
  id-token: write
  contents: read

And the following environment variables:

env:
  ARM_USE_OIDC: true
  ARM_CLIENT_ID: `${{ secrets.AZURE_CLIENT_ID }}
  ARM_TENANT_ID: `${{ secrets.AZURE_TENANT_ID }}
  ARM_SUBSCRIPTION_ID: `${{ secrets.AZURE_SUBSCRIPTION_ID }}

"@ -ForegroundColor Green
