#!/bin/bash

# This script deploys a custom auth.json configuration to restrict access to AFFILIATES_USERS group
# Parameters:
# $1: Frontend app name
# $2: Resource group name
# $3: Tenant ID
# $4: Client ID
# $5: Affiliates Users Group ID

# Exit on error
set -e

echo "Deploying custom auth configuration to $1"

# Create temporary auth.json with correct values
cat > /tmp/auth.json << EOL
{
  "routes": [
    {
      "path_prefix": "/",
      "policies": {
        "signedIn": { 
          "requirements": {
            "claim": "groups",
            "operator": "contains",
            "value": "${5}"
          }
        }
      }
    }
  ],
  "auth": {
    "identityProviders": {
      "azureActiveDirectory": {
        "registration": {
          "openIdIssuer": "https://login.microsoftonline.com/${3}/v2.0",
          "clientId": "${4}",
          "clientSecretSettingName": "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"
        },
        "validation": {
          "allowedAudiences": [
            "api://${4}"
          ]
        }
      }
    }
  }
}
EOL

# Upload the auth.json file to the frontend app's wwwroot/.auth directory
az webapp deploy --resource-group "${2}" --name "${1}" \
  --src-path "/tmp/auth.json" --target-path "/home/site/.auth/auth.json" \
  --type static

echo "Custom auth configuration deployed successfully"
