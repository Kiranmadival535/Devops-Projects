# DevOps Project Documentation: Voting & Result Application

## 1. **Project Overview**
This project implements a complete CI/CD pipeline for a microservices-based Voting Application consisting of:
- **Vote Service** (frontend service for user voting)
- **Result Service** (frontend for displaying aggregated votes)
- **Worker Service** (processes votes between frontend and Redis)
- **Redis** (for storing vote data)
- **Azure Container Registry (ACR)** for storing built Docker images
- **ArgoCD** for GitOps-based continuous delivery to Kubernetes

---

## 2. **Architecture Diagram**
*(Add your 3D or flow architecture diagram here later)*

---

## 3. **Repository Structure**
```
devops-voting-app-project/
│
├── .github/
├── .vscode/
├── healthchecks/
├── k8s-specifications/
│   ├── vote-deployment.yaml
│   ├── result-deployment.yaml
│   ├── worker-deployment.yaml
│   ├── redis-deployment.yaml
│   └── services.yaml
│
├── vote/ (Vote service source)
├── result/ (Result service source)
├── worker/ (Backend Processor)
├── scripts/
├── seed-data/
├── azure-pipelines-1.yml
├── azure-pipelines-2.yml
├── azure-pipelines-3.yml
└── azure-pipelines-4.yml (ArgoCD update stage)
```

---

## 4. **CI Pipeline (Azure DevOps)**
Each microservice has its own pipeline:
- **voting-service**
- **result-service**
- **worker-service**

### Pipeline Stages
#### **1. Build Stage**
- Builds Docker image
- Runs unit tests (if configured)
- Creates tagged image using commit ID

#### **2. Push Stage**
- Pushes the built image to ACR

#### **3. Update Kubernetes Stage**
- Pipeline automatically updates ArgoCD-managed manifest files with the new image tags
- GitOps takes care of syncing cluster state

---

### Example pipeline (vote service)
Below is the pipeline you provided (kept as-is for reference). It triggers on changes under `vote/*` and performs Build → Push → Update (which clones the repo, updates the k8s manifest and pushes the change back).

```yaml
trigger:
  paths:
    include:
      - vote/*

resources:
- repo: self

variables:
  dockerRegistryServiceConnection: '7f1b178e-f463-4b01-a8e6-2fbd61111933'
  imageRepository: 'votingapp'
  containerRegistry: 'kiranazurecicd.azurecr.io'
  dockerfilePath: '$(Build.SourcesDirectory)/vote/Dockerfile'
  tag: '$(Build.BuildId)'
  imageFullPath: '$(containerRegistry)/$(imageRepository)'

stages:
- stage: Build
  displayName: Build stage
  jobs:
  - job: Build
    pool:
      name: azureagent
    steps:
      - task: Docker@2
        displayName: Build image
        inputs:
          containerRegistry: '$(dockerRegistryServiceConnection)'
          repository: '$(imageRepository)'
          command: 'build'
          Dockerfile: 'vote/Dockerfile'
          tags: '$(tag)'

- stage: Push
  displayName: Push stage
  jobs:
  - job: Push
    pool:
      name: azureagent
    steps:
      - task: Docker@2
        displayName: Push image
        inputs:
          containerRegistry: '$(dockerRegistryServiceConnection)'
          repository: '$(imageRepository)'
          command: 'push'
          tags: '$(tag)'

- stage: Update
  displayName: Update Kubernetes Manifests
  dependsOn: Push
  jobs:
  - job: Update
    pool:
      name: azureagent
    steps:
      - checkout: self

      - script: |
          set -xe
          
          SERVICE="vote"
          IMAGE="votingapp"
          TAG="$(Build.BuildId)"
          REPO_URL="https://<PERSONAL_ACCESS_TOKEN>@dev.azure.com/.../devops-voting-app-project/_git/devops-voting-app-project"

          if [ -d /tmp/temp_repo ]; then
            echo "Cleaning old temp repo..."
            rm -rf /tmp/temp_repo
          fi

          git clone "$REPO_URL" /tmp/temp_repo
          cd /tmp/temp_repo

          git config user.email "ci-bot@example.com"
          git config user.name "CI Bot"

          FILE="k8s-specifications/${SERVICE}-deployment.yaml"
          if [[ ! -f "$FILE" ]]; then
            echo "File not found: $FILE"
            ls -R k8s-specifications
            exit 1
          fi

          echo "Updating image in $FILE"
          sed -i "s|image:.*|image: kiranazurecicd.azurecr.io/${IMAGE}:${TAG}|g" "$FILE"

          git add "$FILE"
          git commit -m "Update Kubernetes manifest to tag: ${TAG}"
          git push

          cd /
          rm -rf /tmp/temp_repo
        displayName: "Update K8s Manifest (Inline)"
```

> **Important security note:** the example above embeds an access token directly in `REPO_URL`. **Do not hardcode personal access tokens or credentials** in pipeline code. See recommended, safer alternative below.

---

### Recommended improvements & safer Update stage
1. **Use the built-in `System.AccessToken`**
   - Enable **Allow scripts to access the OAuth token** in the pipeline options.
   - Use an extra HTTP header when running `git` so pushes authenticate via `$(System.AccessToken)`.
2. **Avoid cloning with plain HTTPS+token** — use `checkout: self` and modify files in the working directory, or clone using the OAuth flow.
3. **Prefer `git` changes via pipeline workspace**: modify files directly (no temporary /tmp clone) and `git push` from the pipeline agent using the token header.
4. **Consider committing image-tag updates to a separate branch** and create a PR, or use a GitOps approach where pipeline writes the new image tag to a dedicated manifests repo and ArgoCD syncs it.

#### Example safer Update script (replace inline token)
```bash
# prerequisites: set Allow scripts to access the OAuth token = true
SERVICE="vote"
TAG="$(Build.BuildId)"
cd $(Build.SourcesDirectory)

git config user.email "ci-bot@example.com"
git config user.name "CI Bot"

FILE="k8s-specifications/${SERVICE}-deployment.yaml"
if [[ ! -f "$FILE" ]]; then
  echo "File not found: $FILE"
  exit 1
fi

sed -i "s|image:.*|image: ${containerRegistry}/${imageRepository}:${TAG}|g" "$FILE"

git add "$FILE"
git commit -m "Update Kubernetes manifest to tag: ${TAG}"
# use System.AccessToken for auth
git -c http.extraheader="AUTHORIZATION: bearer ${SYSTEM_ACCESSTOKEN}" push origin HEAD:main
```

> Note: `${SYSTEM_ACCESSTOKEN}` is provided by Azure Pipelines when **Allow scripts to access the OAuth token** is enabled and referenced in the pipeline as `$(System.AccessToken)`.

---

### Other suggestions
- Add **imagePullSecrets** for pulling images from private ACR if not public.
- Tag images with both `$(Build.BuildId)` and a semantic tag (e.g. `v1.2.3` or `$(Build.SourceBranchName)`).
- Add a **manifest test / dry-run** step before pushing commits.
- Use a **separate manifests repository** (GitOps pattern) so the build/push pipeline updates *only* the manifest repo; ArgoCD tracks manifests repo.

---


## 5. **CD Using ArgoCD**
ArgoCD monitors the Git repo and automatically syncs Kubernetes resources.

### Features observed:
- Application health is **Healthy**
- Sync status is **Synced**
- ArgoCD tree view shows:
  - Deployments
  - ReplicaSets
  - Pods
  - Services
  - ConfigMaps

ArgoCD refreshes and applies any new image tags automatically.

---

## 6. **Application Access**
### Vote Application URL
```
http://<public-ip>:31000
```
Users can vote for **CATS** or **DOGS**.

### Result Application URL
```
http://<public-ip>:31001
```
Shows real-time results processed by Redis and Worker Service.

---

## 7. **Pipeline Run Example Screenshots**
(Add screenshots: build stage, push stage, ArgoCD sync state, running application UI)

---

## 8. **How the Application Works (Flow)**
1. Vote service collects user input
2. Worker service sends vote data to Redis
3. Result service fetches updated counts from Redis
4. UI displays real-time results

---

## 9. **Kubernetes Deployment Flow**
1. YAML manifest updates via Azure pipeline
2. Git repo change triggers ArgoCD sync
3. ArgoCD deploys to Kubernetes cluster
4. Monitoring dashboards show health

---

## 10. Final Output
- Application deployed successfully
- Fully automated CI/CD
- Real-time voting system functioning
- Clean separation of microservices

---

Let me know if you'd like to add **diagrams, 3D illustrations, architecture pictures, emojis, LinkedIn post format**, or **more detailed YAML examples**.

