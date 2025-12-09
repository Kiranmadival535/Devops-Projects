# Multi-Tier Application – Complete README (Markdown Version)

## 📘 1. INTRODUCTION
This project demonstrates a complete DevOps workflow:
- Java application built using Maven  
- Docker containerization  
- Trivy vulnerability scanning (Filesystem + Image)  
- SonarQube code quality analysis  
- Azure Artifacts Maven repository  
- Azure Container Registry (ACR)  
- Kubernetes deployment (AKS or any cluster)  
- Azure DevOps multi-stage CI/CD pipeline  

---

## 📘 2. TECHNOLOGY STACK

| Component | Technology |
|----------|------------|
| Language | Java |
| Build Tool | Maven |
| Containerization | Docker |
| FS & Image Scanning | Trivy |
| Code Quality | SonarQube |
| Artifact Repository | Azure Artifacts |
| Container Registry | Azure Container Registry |
| Deployment | Kubernetes |
| CI/CD | Azure DevOps |

---

## 📘 3. PREREQUISITES

### Local Tools
- Java JDK 17  
- Maven 3.x  
- Git  
- Docker  
- kubectl  
- Azure CLI (optional)  

### Azure DevOps Requirements
- Repo access  
- Azure Artifacts feed  
- ACR service connection (`docker-svc`)  
- Kubernetes service connection (`k8s-conn`)  
- SonarQube service connection (`sonarqube`)  
- Azure subscription connection  

---

## 📘 10. CI/CD PIPELINE – STAGE SUMMARY

### **Stage 1 – Maven Compile**
- Authenticates to Maven feed  
- Compiles code using Maven  

### **Stage 2 – Maven Test**
- Test the code 

### **Stage 3 – Trivy Filesystem Scan**
- Installs Trivy  
- Generates `fs.html` vulnerability report  

### **Stage 4 – SonarQube Analysis**
- Performs static code analysis  
- Sends results to SonarQube dashboard  

### **Stage 5 – Publish Build Artifacts**
- Deploys packages to Azure Artifacts feed  

### **Stage 6 – Docker Build & Push**
- Builds Docker image  
- Pushes image to ACR  

### **Stage 7 – Trivy Image Scan**
- Scans container image  
- Produces `image.html`  

### **Stage 8 – Deploy to Kubernetes**
- Uses manifest files  
- Deploys application to cluster  

---

## 📘 11. ARTIFACTS GENERATED

| Artifact | Description |
|----------|-------------|
| fs.html | Filesystem vulnerability scan report |
| image.html | Container image vulnerability scan |
| JAR file | Published to Azure Artifacts |

---

## 📘 12. SERVICE CONNECTIONS

| Name | Purpose |
|------|---------|
| maven | Azure Artifacts |
| docker-svc | ACR Authentication |
| k8s-conn | Kubernetes Deployment |
| sonarqube | Code Quality Analysis |
| Azure subscription | Build & deployment auth |

---

## 📘 13. TROUBLESHOOTING

### **Git Push Authentication Failed**
Use **PAT Token** instead of password.

### **Maven Dependencies Not Restoring**
Check:
- Feed permissions  
- MavenAuthenticate task  

### **Docker Push Failure**
Ensure:
- Correct ACR name  
- Right permissions  
- Correct tag format: `<registry>.azurecr.io/repo:tag`  

### **Kubernetes Deployment Fails**
Investigate:
```bash
kubectl describe pod <pod>
kubectl describe deployment <deployment>
```

### **Trivy Errors**
Fix by updating vulnerability DB:
```bash
trivy --download-db-only
```


