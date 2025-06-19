# DevOps Assignment – EC2 Automation with Terraform

## Objective

This project automates the provisioning of an EC2 instance on AWS using Terraform and deploys a Java Spring Boot application. It ensures secure AWS usage, cost control through auto-shutdown, and environment-specific configurations (Dev/Prod).

---

## What This Project Does

* Provisions an EC2 instance inside a custom VPC using Terraform
* Installs Java 19 or 21 on the EC2 instance
* Clones a Spring Boot application from GitHub
* Runs the app on port 80
* Schedules EC2 shutdown after a defined time (e.g., 30 minutes)
* Allows Dev/Prod environment config via separate `.tfvars` files
* Uses no hardcoded AWS credentials (relies on environment variables)
* Provides a Postman collection to test the application APIs

---

## Tech Used

| Tool         | Role                        |
| ------------ | --------------------------- |
| Terraform    | Infrastructure provisioning |
| AWS EC2      | Compute resource            |
| Shell Script | App deployment on EC2       |
| GitHub       | App source & versioning     |
| Postman      | API testing                 |

---

## Project Structure

```
tech_eazy_Debasish-87_aws_devops/
├── main.tf
├── variables.tf
├── outputs.tf
├── user_data.sh
├── dev_config.tfvars
├── terraform.tfstate
├── resources/
│   └── postman_collection.json
└── README.md
```

---

## How to Deploy

### 1. Clone the Repository

```bash
git clone https://github.com/Debasish-87/tech_eazy_Debasish-87_aws_devops.git
cd tech_eazy_Debasish-87_aws_devops
```

### 2. Set AWS Credentials

```bash
export AWS_ACCESS_KEY_ID=your-access-key
export AWS_SECRET_ACCESS_KEY=your-secret-key
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Apply Configuration

```bash
terraform apply -var-file="dev_config.tfvars"
```

This will:

* Create networking (VPC, Subnet, IGW, Security Group)
* Launch the EC2 instance
* Run the startup script (`user_data.sh`) that:

  * Installs Java
  * Clones the Spring Boot app
  * Starts the app
  * Schedules shutdown (default: 30 minutes)

---

## Access the App

Once deployed, open in your browser:

```
http://<public-ec2-ip>
```

The public IP will be printed in Terraform output as `instance_public_ip`.

---

## API Testing

Use the Postman collection provided:

```
resources/postman_collection.json
```

Import it into Postman to test your app endpoints.

---

## Cleanup (Important)

Run this to destroy all resources and avoid AWS billing:

```bash
terraform destroy -var-file="dev_config.tfvars"
```

---

## Highlights

* Modular, environment-based Terraform setup
* Secure handling of AWS credentials
* Auto-shutdown to avoid idle cost
* App is publicly reachable on port 80
* Postman collection available for quick testing

---

## Submission

1. Push the project to GitHub in the following format:

```
tech_eazy_<your-github-username>_aws_internship
```

✅ Example: `tech_eazy_Debasish-87_aws_internship`

2. Submit the GitHub URL here:
   👉 [https://forms.gle/9DfAcyCHsTiQ8qaW7](https://forms.gle/9DfAcyCHsTiQ8qaW7)

---

## Author

**Debasish Mohanty**
Cloud | DevSecOps | Terraform | AWS | CI/CD
GitHub: [Debasish-87](https://github.com/Debasish-87)

---
