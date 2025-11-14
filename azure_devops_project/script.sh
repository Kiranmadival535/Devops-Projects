#!/bin/bash
set -e  # stop if any command fails

# ==============================================
# VARIABLES
# ==============================================
RESOURCE_GROUP_NAME="terraform-state-rg"
CONTAINER_NAME="tfstate"
LOCATION="centralindia"

# Generate unique globally valid storage account names
STAGE_SA_ACCOUNT="tfstagebackenddevops123"
DEV_SA_ACCOUNT="tfdevbackenddevops123"

echo "🟢 Using storage accounts:"
echo "   Staging: $STAGE_SA_ACCOUNT"
echo "   Dev:     $DEV_SA_ACCOUNT"
echo

# ==============================================
# AUTHENTICATION CHECK
# ==============================================
echo "🔐 Checking Azure login..."
if ! az account show >/dev/null 2>&1; then
  echo "You are not logged in. Logging in now..."
  az login --use-device-code
fi

# Confirm current subscription
echo "📦 Current Azure subscription:"
az account show --query "{Name:name, ID:id, Tenant:tenantId}" -o table

read -p "➡️  Continue with this subscription? (y/n): " confirm
if [[ $confirm != [yY] ]]; then
  echo "Exiting. Use 'az account set --subscription <id>' to switch and rerun."
  exit 1
fi

# ==============================================
# CREATE RESOURCE GROUP
# ==============================================
echo "🏗️  Creating resource group: $RESOURCE_GROUP_NAME ..."
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION

# ==============================================
# CREATE STORAGE ACCOUNTS
# ==============================================
echo "💾 Creating storage account for STAGE..."
az storage account create \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $STAGE_SA_ACCOUNT \
  --sku Standard_LRS \
  --encryption-services blob

echo "💾 Creating storage account for DEV..."
az storage account create \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $DEV_SA_ACCOUNT \
  --sku Standard_LRS \
  --encryption-services blob

# ==============================================
# CREATE CONTAINERS USING AAD LOGIN
# ==============================================
echo "📂 Creating blob container '$CONTAINER_NAME' in STAGE account..."
az storage container create \
  --name $CONTAINER_NAME \
  --account-name $STAGE_SA_ACCOUNT \
  --auth-mode login

echo "📂 Creating blob container '$CONTAINER_NAME' in DEV account..."
az storage container create \
  --name $CONTAINER_NAME \
  --account-name $DEV_SA_ACCOUNT \
  --auth-mode login

# ==============================================
# OUTPUT INFO
# ==============================================
echo
echo "✅ Setup complete!"
echo "Resource Group: $RESOURCE_GROUP_NAME"
echo "STAGE Storage Account: $STAGE_SA_ACCOUNT"
echo "DEV Storage Account:   $DEV_SA_ACCOUNT"
echo "Container Name:        $CONTAINER_NAME"
echo
echo "💡 Next step:"
echo "Use these names in your Terraform backend configuration."

