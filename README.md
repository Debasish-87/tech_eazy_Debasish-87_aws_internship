# DevOps Assignment – Automate EC2 Deployment on AWS

This project automates the deployment of a Java Spring Boot application on an AWS EC2 instance using Terraform. It sets up the infrastructure, installs Java, deploys the app, and shuts down the instance automatically after some time.

---

## Objective

This project does the following:

1. Creates an EC2 instance inside a custom VPC
2. Installs Java 19 on the instance
3. Clones a GitHub Spring Boot app and starts it
4. Makes the app available on port 80
5. Shuts down the EC2 instance after a set time
6. Uses separate configuration files for Dev and Prod
7. Keeps AWS credentials safe using environment variables
8. Includes a Postman file for testing the app

---

## Tools Used

* Terraform for automation
* AWS EC2 to run the app
* Shell script for setup and deployment
* GitHub for the app source code
* Postman for testing the APIs

---

## Project Structure

```
tech_eazy_Debasish-87_aws_devops/
├── main.tf                  # Terraform infrastructure setup
├── variables.tf             # Input variables
├── outputs.tf               # Outputs like EC2 IP
├── user_data.sh             # EC2 startup script
├── dev_config.tfvars        # Dev environment configuration
├── resources/
│   └── postman_collection.json  # Postman API test file
└── README.md                # Project documentation
```

---

## How to Use

### Step 1: Clone the Repository

```
git clone https://github.com/Debasish-87/tech_eazy_Debasish-87_aws_devops.git
cd tech_eazy_Debasish-87_aws_devops
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

* Create VPC, subnet, and security group
* Launch an EC2 instance
* Install Java 19
* Clone and start the Spring Boot app
* Schedule automatic shutdown

### Step 5: Access the Application

After deployment, open the app in your browser using the public IP:

```
http://<instance_public_ip>
```

You will see the public IP in the Terraform output.

---

## API Testing

Open the following Postman collection file to test the app:

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

## Submission Instructions

1. Push the project to a public GitHub repo named:

```
tech_eazy_<your-github-username>_aws_internship
```

Example: `tech_eazy_Debasish-87_aws_internship`

2. Submit the GitHub repo URL in the form:

[https://forms.gle/9DfAcyCHsTiQ8qaW7](https://forms.gle/9DfAcyCHsTiQ8qaW7)

---

## Author

Debasish Mohanty
Cloud DevSecOps | Terraform | AWS | CI/CD
GitHub: [https://github.com/Debasish-87](https://github.com/Debasish-87)

---
