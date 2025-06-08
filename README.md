# 🚀 DevOps Assignment – Automate EC2 Deployment on AWS

This project demonstrates infrastructure automation using **Terraform** to deploy a **Java 19/21 Spring Boot** application on an **AWS EC2** instance. The setup ensures modularity, environment-specific configurations, secure AWS credential handling, and cost-optimized resource usage.

---

## 📌 Project Objective

Automate the following tasks end-to-end using Infrastructure as Code:

1. Spin up an EC2 instance in a custom VPC.
2. Install required dependencies (Java 19).
3. Clone a remote GitHub repo and deploy the application.
4. Ensure the app is reachable via port 80.
5. Auto-shutdown the instance after a configured time.
6. Use environment-specific configurations (e.g., `Dev`, `Prod`).
7. Avoid hardcoding sensitive credentials.
8. Provide API testing artifacts (Postman collection).

---

## 🧾 Tech Stack

| Tool/Service    | Purpose                          |
|------------------|----------------------------------|
| **Terraform**    | Infrastructure automation        |
| **AWS EC2**      | Compute resource (server)        |
| **Shell Script** | EC2 bootstrap / app deployment   |
| **GitHub**       | Source control & app repo        |
| **Postman**      | API testing                      |

---

## 🗂️ Project Structure

```plaintext
tech_eazy_Debasish-87_aws_devops/
├── main.tf                  # Core infrastructure definitions
├── variables.tf             # Input variables
├── outputs.tf               # Output values (e.g., IP, instance ID)
├── user_data.sh             # EC2 bootstrapping script
├── dev_config.tfvars        # Config for Dev environment
├── terraform.tfstate        # Terraform state file
├── terraform.tfstate.backup
├── resources/
│   └── postman_collection.json
└── README.md                # This documentation
````

---

## 🔧 Configuration Files

### `dev_config.tfvars`

```hcl
instance_type     = "t2.micro"
stage             = "dev"
app_repo_url      = "https://github.com/techeazy-consulting/techeazy-devops"
shutdown_minutes  = 30
```

🔄 **Create `prod_config.tfvars` similarly** to manage Prod stage values.

---

## ⚙️ Deployment Workflow

### 1️⃣ Clone the Repo

```bash
git clone https://github.com/Debasish-87/tech_eazy_Debasish-87_aws_devops.git
cd tech_eazy_Debasish-87_aws_devops
```

### 2️⃣ Set Up AWS Credentials (Environment-Based)

Ensure AWS credentials are **exported as environment variables**:

```bash
export AWS_ACCESS_KEY_ID=your-access-key
export AWS_SECRET_ACCESS_KEY=your-secret-key
```

### 3️⃣ Initialize Terraform

```bash
terraform init
```

### 4️⃣ Apply Terraform Configuration

Run with environment config (e.g., Dev):

```bash
terraform apply -var-file="dev_config.tfvars"
```

This will:

* Create a VPC, Subnet, Internet Gateway, Security Group
* Launch an EC2 instance
* Execute `user_data.sh` to:

  * Install Java 19/21
  * Clone the GitHub repo
  * Start the app on port 80
  * Schedule automatic shutdown after `shutdown_minutes`

---

## 📡 Accessing the Application

After deployment, visit:

```
http://<instance_public_ip>
```

💡 Public IP is shown in Terraform output as `instance_public_ip`.

---

## 🧪 API Testing with Postman

Use the provided collection in:

```
resources/techeazy-app.postman_collection.json
```

Import it into Postman to test the backend APIs once the app is running.

---

## 🛑 Destroy Resources (Cleanup)

To avoid charges on AWS:

```bash
terraform destroy -var-file="dev_config.tfvars"
```

---

## 💡 Key Highlights

* ✅ Modular and reusable Terraform code
* ✅ Stage-aware configurations using `.tfvars`
* ✅ No secrets or keys hardcoded
* ✅ App runs on port 80 (as required)
* ✅ Auto-shutdown to save AWS cost
* ✅ Postman collection included for API validation

---

## 📫 Submission Instructions

1. Push your code to a **public GitHub repository** with the naming convention:

```
tech_eazy_<your-github-username>_aws_internship
```

✅ Your repo: `tech_eazy_Debasish-87_aws_internship`

2. Submit the GitHub repo URL in this form:
   👉 [https://forms.gle/9DfAcyCHsTiQ8qaW7](https://forms.gle/9DfAcyCHsTiQ8qaW7)

---

## 👨‍💻 Author

**Debasish Mohanty**
Cloud DevSecOps Enthusiast | Terraform | AWS | CI/CD
GitHub: [Debasish-87](https://github.com/Debasish-87)

---

```

---

Let me know if you'd like a badge section, GitHub Actions CI setup, or if you're planning to convert this into a full CI/CD pipeline project.
```
