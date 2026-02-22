# DevOps Assignment – Automate EC2 Deployment on AWS

## Objective

This project automates the provisioning of an EC2 instance on AWS using Terraform and deploys a Java Spring Boot application. It ensures secure AWS usage, cost control through auto-shutdown, and environment-specific configurations (Dev/Prod).

---

## What This Project Does

1. Creates an EC2 instance inside a custom VPC
2. Installs Java 19/21 on the instance
3. Clones a GitHub Spring Boot application and starts it
4. Makes the app available on port 80
5. Shuts down the EC2 instance automatically after a defined time
6. Uses separate configuration files for Dev and Prod environments
7. Keeps AWS credentials secure using environment variables
8. Includes a Postman collection for API testing

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

tech_eazy_Debasish-87_aws_internship/

├── main.tf                  # Core infrastructure
├── variables.tf             # Input variables
├── outputs.tf               # EC2 output values
├── user_data.sh             # EC2 startup automation
├── dev_config.tfvars        # Dev environment configuration
├── resources/
│   └── postman_collection.json
└── README.md

```

---

## How to Deploy

### Step 1: Clone the Repository

```

git clone https://github.com/Debasish-87/tech_eazy_Debasish-87_aws_internship.git
cd tech_eazy_Debasish-87_aws_internship

```

### Step 2: Set AWS Credentials

Export your AWS credentials using environment variables:

```

export AWS_ACCESS_KEY_ID=your-access-key
export AWS_SECRET_ACCESS_KEY=your-secret-key

```

### Step 3: Initialize Terraform

```

terraform init

```

### Step 4: Apply Configuration

Run this command for the Dev environment:

```

terraform apply -var-file="dev_config.tfvars"

```

Terraform will:

- Create VPC, subnet, and security group
- Launch an EC2 instance
- Install Java
- Clone and start the Spring Boot app
- Schedule automatic shutdown

---

## Access the Application

After deployment, open the app in your browser using the public IP:

```

http://<public-ec2-ip>

```

The public IP will be visible in the Terraform output as `instance_public_ip`.

---

## API Testing

Use the Postman collection provided:

```

resources/postman_collection.json

```

Import it into Postman and send requests to the application.

---

## Cleanup

To delete everything and avoid AWS charges:

```

terraform destroy -var-file="dev_config.tfvars"

```

---

## Highlights

- Modular environment-based Terraform setup
- Secure handling of AWS credentials
- Auto-shutdown to reduce idle cost
- App publicly accessible on port 80
- Postman collection included for quick testing

---

## Submission Instructions

1. Push the project to a public GitHub repository named:

```

tech_eazy_<your-github-username>_aws_internship

```

Example: `tech_eazy_Debasish-87_aws_internship`

2. Submit the GitHub repo URL in the form:

https://forms.gle/9DfAcyCHsTiQ8qaW7

---

## Author

Debasish Mohanty  
Cloud DevSecOps | Terraform | AWS | CI/CD  
GitHub: https://github.com/Debasish-87
```

---
