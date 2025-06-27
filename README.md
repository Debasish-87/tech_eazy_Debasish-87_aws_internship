# DevOps Assignment – Multi-Stage EC2 Java App Deployment using Terraform & GitHub Actions

## Overview
This project provisions and deploys a Spring Boot Java application to EC2 using Terraform and GitHub Actions. Logs are uploaded to S3. It supports **multi-stage deployment** for `dev` and `prod`.

---

## Components Used
- **Terraform**: AWS infrastructure provisioning
- **EC2**: Hosts the Spring Boot app
- **S3**: Stores logs per stage (e.g., `logs/dev/`, `logs/prod/`)
- **GitHub Actions**: Automates CI/CD pipeline
- **Spring Boot**: Java backend application

---

## Folder Structure
```
.
├── main.tf
├── variables.tf
├── dev_config.tfvars
├── prod_config.tfvars
├── user_data.sh
├── iam_roles.tf
├── s3.tf
├── data.tf
├── outputs.tf
├── .github/workflows/deploy.yml
```

---

## Workflow Summary
1. On push to `feature/devops-assignment-3-final`, deploys **dev** stage.
2. If `dev` is successful:
   - Triggers **prod** deployment.
3. Logs and status are uploaded to S3 bucket:
   - `s3://<bucket>/logs/dev/...`
   - `s3://<bucket>/logs/prod/...`

---

## GitHub Secrets Required
| Name                | Description                          |
|---------------------|--------------------------------------|
| `AWS_ACCESS_KEY_ID`     | AWS IAM Access Key                   |
| `AWS_SECRET_ACCESS_KEY` | AWS IAM Secret Key                   |
| `GITHUB_PAT`            | GitHub Personal Access Token (for private repo cloning) |

---

## Terraform Input Files
- `dev_config.tfvars`: Used for Dev deployment
- `prod_config.tfvars`: Used for Prod deployment

---

## 🔐 IAM & Security
- IAM roles created:
  - **Read-only** role for log verification
  - **Write-only** role for log upload
- Lifecycle policy deletes logs after **7 days**

---

## Sample Usage
### 1. Trigger from GitHub Actions
Push to `feature/devops-assignment-3-final` to run:
```bash
git checkout -b feature/devops-assignment-3-final
# make changes
git push origin feature/devops-assignment-3-final
```

---

## Validation Steps
- Application health check via `curl` on port 80
- EC2 instance auto shutdown after 30 minutes
- Logs uploaded to S3 with date stamps
- Signal file `app_ready.txt` used to confirm EC2 setup success

---

## 👤 Author
**Debasish Mohanty**  
DevSecOps Intern @ TechEazy Consulting
# Triggering pipeline
