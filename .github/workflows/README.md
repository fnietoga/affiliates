# GitHub Actions CI/CD Workflows

This document provides detailed information about the CI/CD workflows in this project.

## Overview

This project includes four main GitHub Actions workflows:

1. **Terraform IaC Deployment**: Manages infrastructure as code deployment
2. **Database Migration**: Manages database schema migrations with Flyway
3. **Backend API**: Builds and deploys the .NET API
4. **Frontend React App**: Builds and deploys the React frontend application

## Required Secrets

For these workflows to function correctly, you need to set up the following GitHub secrets:

### Terraform Workflow
- `AZURE_CLIENT_ID`: Service Principal ID for Azure authentication
- `AZURE_CLIENT_SECRET`: Service Principal secret
- `AZURE_SUBSCRIPTION_ID`: Azure subscription ID
- `AZURE_TENANT_ID`: Azure tenant ID
- `SQL_ADMIN_PASSWORD`: SQL Server admin password for Terraform

### Database Migration Workflow
- `FLYWAY_URL`: JDBC URL for the database
- `FLYWAY_USER`: Database user for migrations
- `FLYWAY_PASSWORD`: Database password for migrations

### Backend API Workflow
- `AZURE_WEBAPP_NAME` (optional variable): Azure Web App name (default: app-afiliados-api)
- `AZURE_WEBAPP_PUBLISH_PROFILE`: Publish profile for Azure Web App

### Frontend React App Workflow
- `AZURE_STATIC_WEB_APP_NAME` (optional variable): Static Web App name (default: stapp-afiliados-frontend)  
- `AZURE_STATIC_WEB_APPS_API_TOKEN`: Deployment token for Static Web App
- `REACT_APP_API_BASE_URL`: Backend API URL for frontend configuration

## Workflow Triggers

Each workflow is triggered by:

1. Pushes to the `main` branch that change files in the respective project directory
2. Pull requests to the `main` branch that change files in the respective project directory
3. Manual triggers using the "workflow_dispatch" event

## Deployment Process

1. **Infrastructure**: First, deploy infrastructure using Terraform
2. **Database**: Once infrastructure is in place, apply database migrations
3. **Backend**: Deploy the .NET API to Azure App Service
4. **Frontend**: Deploy the React app to Azure Static Web App

## Customizing Workflows

To customize these workflows:

1. Edit the YAML files in the `.github/workflows/` directory
2. Adjust environment variables, steps, or triggers as needed
3. For different Azure resource types, modify the deployment steps accordingly

## Local Testing

You can test these workflows locally using [act](https://github.com/nektos/act), a tool for running GitHub Actions locally:

```bash
# Install act
brew install act  # macOS
# or download from https://github.com/nektos/act/releases for other platforms

# Run a specific workflow
act -j build-and-deploy -W .github/workflows/backend.yml
```
