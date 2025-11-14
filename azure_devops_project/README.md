# Architecture diagram used in the video

!# Azure DevOps CI/CD Project

This project implements a complete CI/CD pipeline using **Azure DevOps**, **Terraform**, **Docker**, and **Azure Kubernetes Service (AKS)**.  
It automates infrastructure provisioning, image build/push, application deployment, and multi-environment workflows (Dev → Stage), including a safe destroy pipeline.

---

## 📌 Architecture Diagram

![Architecture Diagram](azure_devops_project/architecture.png)

---

## 📌 CI/CD Flow Diagram

![CI/CD Flow Diagram](azure_devops_project/flowchart.png)

---

## 📌 End-to-End DevOps Pipeline Diagram

![DevOps Architecture](azure_devops_project/devops_architecture.png)

---

## 📁 Repository Structure

azure_devops_project/
│
├── app/ # Application source code + Dockerfile
├── dev/ # Terraform for Development environment
├── staging/ # Terraform for Staging environment
├── k8s/ # Kubernetes manifests
├── modules/ # Reusable Terraform modules
├── pipeline/ # Optional helper scripts
│
├── architecture.png # Architecture diagram (inline)
├── flowchart.png # Pipeline flow diagram (inline)
├── devops_architecture.png # DevOps architecture diagram (inline)
│
├── azure-pipelines-build.yml # Main CI/CD pipeline
└── azure-pipelines-destroy.yml # Manual destroy pipeline

yaml
Copy code

---

## 🚀 CI/CD Pipeline Overview

### 1. **Build Stage**
- Checkout repository  
- Build Docker image from `app/Dockerfile`  
- Push to Docker Hub  

### 2. **Validate Stage**
- Install Terraform  
- `terraform init` using Dev backend  
- `terraform validate`  

### 3. **Dev Deployment**
- `terraform apply` for Dev infra  
- Provision AKS, networking, storage  
- Deploy workloads to Dev AKS cluster  
- Validate using `kubectl`  

### 4. **Stage Deployment**
Triggered only when Dev succeeds:
- `terraform apply` for Stage infra  
- Deploy to Stage AKS cluster  
- Validate pods & services  

### 5. **Destroy Pipeline**
- Manual execution  
- Select environment (dev/stage)  
- Runs `terraform destroy`  

---

## 🧱 Infrastructure (Terraform)

- Separate backends for Dev & Stage  
- Remote state stored in Azure Storage  
- AKS cluster provisioning  
- Resource groups, network, node pools, and supporting resources  

---

## 🐳 Containers (Docker)

- Image built from `app/Dockerfile`  
- Auto-tagged (`latest` + build ID)  
- Pushed to Docker Hub repository  
- Pulled during AKS deployment  

---

## ☸ Kubernetes Deployment

- Manifests under `k8s/`  
- File substitution for environment values  
- Deployments managed using `KubernetesManifest` task  
- Cluster credentials acquired via Azure CLI  

---

## 🔐 Secrets & Service Connections

- Azure Subscription (ARM) Service Connection  
- Docker Registry Service Connection  
- Pipeline variables securely stored  
- No secrets stored in source control  

---

## 🧪 Deployment Validation

After each deployment, the pipeline runs:

kubectl get nodes
kubectl get pods -o wide
kubectl get svc

yaml
Copy code

Ensures:
- Cluster health  
- Pod scheduling  
- Service exposure  

---

## 🛠 Technology Stack

| Category | Tools |
|---------|-------|
| CI/CD | Azure DevOps Pipelines |
| IaC | Terraform |
| Compute | AKS |
| Containerization | Docker |
| Deployment | Kubernetes, kubectl |
| Automation | Azure CLI |
| Agents | Self-hosted agent pool |

---

## 📞 Contact

**Kiran Madival**
