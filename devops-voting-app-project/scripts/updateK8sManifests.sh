#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

###############################################
# Args
###############################################
APP_NAME="$1"
IMAGE_REPO="$2"
IMAGE_TAG="$3"

###############################################
# Validation
###############################################
if [ -z "${SYSTEM_ACCESSTOKEN:-}" ]; then
    echo "❌ ERROR: SYSTEM_ACCESSTOKEN is not set."
    exit 1
fi

if [ -z "$APP_NAME" ] || [ -z "$IMAGE_REPO" ] || [ -z "$IMAGE_TAG" ]; then
    echo "Usage: $0 <app-name> <image-repo> <image-tag>"
    exit 1
fi

###############################################
# Repo Values
###############################################
ORG="practice-devops-projects"
PROJECT="devops-voting-app-project"
REPO="devops-voting-app-project"
REPO_URL="https://dev.azure.com/${ORG}/${PROJECT}/_git/${REPO}"

###############################################
# Clone Repo
###############################################
echo "➡️  Cloning repository..."
git -c http.extraheader="AUTHORIZATION: bearer ${SYSTEM_ACCESSTOKEN}" \
    clone "${REPO_URL}" /tmp/temp_repo

cd /tmp/temp_repo

# Git identity
git config user.email "azure-devops-ci@example.com"
git config user.name "Azure DevOps CI"

###############################################
# Update Manifest
###############################################
TARGET_FILE="k8s-specifications/${APP_NAME}-deployment.yaml"

if [ ! -f "$TARGET_FILE" ]; then
    echo "❌ ERROR: File not found → $TARGET_FILE"
    exit 1
fi

echo "✅ Updating image → ${IMAGE_REPO}:${IMAGE_TAG}"

# Update image field
sed -i "s|image:.*|image: ${IMAGE_REPO}:${IMAGE_TAG}|g" "$TARGET_FILE"

###############################################
# Commit + Push
###############################################
git add "$TARGET_FILE"
git commit -m "Update ${APP_NAME} → ${IMAGE_REPO}:${IMAGE_TAG}"
git push

###############################################
# Cleanup
###############################################
cd /
rm -rf /tmp/temp_repo

echo "✅ Manifest updated & pushed successfully!"