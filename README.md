# Terraform Dev → Prod CI/CD Pipeline

This repository contains a complete infrastructure-as-code (IaC) setup using **Terraform** for provisioning AWS resources and a **GitHub Actions CI/CD pipeline** for deploying a Java-based web application across multiple environments (`dev` and `prod`).

---

## Table of Contents

1. Project Overview  
2. Features  
3. Prerequisites  
4. Directory Structure  
5. Terraform Usage (Manual)  
6. GitHub Actions Workflow  
7. CI/CD Deployment Flow  
8. Application Health Check  
9. Auto Shutdown  
10. Log Storage  
11. Postman Collection  
12. License

---

## 1. Project Overview

This project automates the process of:
- Creating EC2 infrastructure using Terraform
- Installing dependencies and deploying a Java app using a startup script
- Uploading system and application logs to S3
- Validating app readiness via a health check
- Promoting changes from `dev` to `prod` using GitHub Actions

---

## 2. Features

- Separate Terraform configurations for `dev` and `prod`
- Auto-provisioning EC2, IAM roles, VPC, and S3 buckets
- GitHub Actions for CI/CD automation
- Auto-shutdown mechanism to control costs
- Upload logs and deployment status to S3
- Workspace-based isolation for environments

---

## 3. Prerequisites

Before using this project, ensure the following:

- [Terraform CLI](https://developer.hashicorp.com/terraform/downloads) installed
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) configured with appropriate IAM access
- GitHub repository with the following secrets set:

| Secret Name              | Description                                      |
|--------------------------|--------------------------------------------------|
| `AWS_ACCESS_KEY_ID`      | AWS access key                                  |
| `AWS_SECRET_ACCESS_KEY`  | AWS secret key                                  |
| `PRIVATE_REPO_TOKEN`     | GitHub token to access private repositories     |
| `PRIVATE_REPO`           | e.g., `username/repository` (Java app repo URL) |

---

## 4. Directory Structure

```

.
├── dev\_config.tfvars            # Dev environment variables
├── prod\_config.tfvars           # Prod environment variables
├── main.tf                      # EC2 provisioning
├── vpc.tf                       # Networking setup
├── iam\_roles.tf                 # IAM roles for EC2
├── iam\_instance\_profile.tf      # EC2 instance profile
├── s3.tf                        # S3 bucket creation
├── outputs.tf                   # Output variables
├── variables.tf                 # Input variables
├── user\_data.sh.tftpl           # Startup script to deploy the app
├── config/
│   ├── dev.json
│   └── prod.json
├── resources/
│   └── techeazy-app.postman\_collection.json
└── .github/workflows/
└── deploy.yml               # GitHub Actions workflow file

````

---

## 5. Terraform Usage (Manual)

**Initialize Terraform and Create Dev Workspace**

```bash
terraform init
terraform workspace new dev
````

**Apply Dev Configuration**

```bash
terraform apply -var-file=dev_config.tfvars
```

**For Production**

```bash
terraform workspace new prod
terraform apply -var-file=prod_config.tfvars \
  -var="stage=prod" \
  -var="github_token=<your-token>" \
  -var="github_private_repo=<your-user>/<your-private-repo>"
```

---

## 6. GitHub Actions Workflow

### Trigger Dev Deployment:

Push to the branch `feature/assignment-4`:

```bash
git push origin feature/assignment-4
```

### Trigger Prod Deployment:

Create and push the tag `deploy-prod`:

```bash
git tag deploy-prod
git push origin deploy-prod
```

You can also manually trigger the workflow from the **GitHub Actions → Run workflow** button using `workflow_dispatch`.

---

## 7. CI/CD Deployment Flow

1. `dev` stage is deployed using `dev_config.tfvars`
2. Application is validated via HTTP health check
3. On success, `prod` stage is automatically deployed using `prod_config.tfvars`
4. Application readiness is confirmed by checking:

   * S3 path: `s3://<bucket>/prod/status/app_ready.txt`
   * Health check returns HTTP 200
5. Logs are uploaded to S3
6. EC2 instance is scheduled to auto-shutdown

---

## 8. Application Health Check

The GitHub workflow performs health checks by sending a request to:

```
http://<INSTANCE_PUBLIC_IP>
```

It retries up to 10 times with a 10-second delay between attempts.

---

## 9. Auto Shutdown

To save AWS costs, the EC2 instance is automatically shut down after a default period (30 minutes).

You can configure this using the Terraform variable:

```hcl
shutdown_after_minutes = 30
```

---

## 10. Log Storage

Application and system logs are uploaded to S3:

```
s3://<bucket-name>/<stage>/logs/app_logs/
s3://<bucket-name>/<stage>/logs/system_logs/
```

---


## Screenshot -

![Screenshot from 2025-06-28 04-29-30](https://github.com/user-attachments/assets/0675449e-3081-46a5-a8b5-91ca1ec3975b)

![Screenshot from 2025-06-28 04-29-44](https://github.com/user-attachments/assets/4c2304c2-089a-409c-8663-2fe770bbbcda)

![Screenshot from 2025-06-28 04-29-57](https://github.com/user-attachments/assets/c5126108-ee0a-4a34-b838-0dfa57717b04)


![Screenshot from 2025-06-28 04-31-39](https://github.com/user-attachments/assets/b82bb809-065a-4103-9194-32b1db198678)


![Screenshot from 2025-06-28 04-32-00](https://github.com/user-attachments/assets/068ff02a-7def-4ea5-9f18-47297d0c23d3)


![Screenshot from 2025-06-28 04-32-19](https://github.com/user-attachments/assets/69460d2b-8e0a-4596-97be-45755e1ae84c)



![Screenshot from 2025-06-28 04-32-30](https://github.com/user-attachments/assets/867f6b7a-f646-40ba-a98d-08b11ba294b3)


![Screenshot from 2025-06-28 04-32-47](https://github.com/user-attachments/assets/cd611aa8-f0cf-4e70-9a02-5ff2001c2d56)


![Screenshot from 2025-06-28 04-32-57](https://github.com/user-attachments/assets/84f67970-de05-453d-a44d-c00ceb979136)

### Dev Stage APP deploy -

![Screenshot from 2025-06-28 04-31-09](https://github.com/user-attachments/assets/3ef985e7-407e-4a96-9fb9-854d1c918fa7)

### Prod Stage APP deploy -

![Screenshot from 2025-06-28 04-31-19](https://github.com/user-attachments/assets/2a875196-d793-443d-ac66-309149c74fee)





## 11. Postman Collection

Use the following file to test your application manually:

```
resources/techeazy-app.postman_collection.json
```

Import it into Postman and execute test cases as needed.

---

## 12. License

This project is licensed under the MIT License.

---
