# Terraform Project - AWS Infrastructure Deployment

## Overview 🚀

This project focuses on setting up an AWS infrastructure using Terraform, ensuring automation, security, and a smooth deployment process through GitHub Actions. The goal was to create an IAM role for GitHub Actions to interact with AWS securely using OpenID Connect (OIDC) and to provision AWS resources like an S3 bucket for Terraform state management.

## What I Have Done ✅

### 1. Installed and Configured Required Software

- Installed AWS CLI and configured it to work with my AWS account.
- Installed Terraform (version 1.6+) to define and manage AWS resources.
- (Optional) Set up `tfenv` to manage Terraform versions easily.

### 2. Set Up AWS Account and IAM User

- Created a new IAM user with the following permissions:
  - AmazonEC2FullAccess
  - AmazonRoute53FullAccess
  - AmazonS3FullAccess
  - IAMFullAccess
  - AmazonVPCFullAccess
  - AmazonSQSFullAccess
  - AmazonEventBridgeFullAccess
- Configured MFA (Multi-Factor Authentication) for both the root user and the new IAM user.
- Generated AWS access keys for CLI authentication.
- Configured AWS CLI to use the new user’s credentials and verified access.

### 3. Created an S3 Bucket for Terraform State

- Used best practices for Terraform state management:
  - Enabled versioning and encryption for security.
  - Defined the backend in Terraform to store the state remotely in S3.
  - Ensured proper IAM permissions for state access.

### 4. Set Up IAM Role for GitHub Actions

- Created an IAM role (`GithubActionsRole`) with the same permissions as the IAM user.
- Configured an Identity Provider (OIDC) for GitHub Actions to allow secure access.
- Updated the IAM trust policy to allow GitHub Actions to assume the role securely:
  ```json
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "arn:aws:iam::${var.aws_account_id}:oidc-provider/token.actions.githubusercontent.com"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "token.actions.githubusercontent.com:sub": "repo:${var.github_usr}/${var.github_repo}:ref:refs/heads/main",
            "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
          }
        }
      }
    ]
  }
  ```

### 5. Automated Terraform Deployment with GitHub Actions

- Created a GitHub repository to store Terraform code.
- Defined a GitHub Actions workflow to handle infrastructure deployment in a single job:
  - **Checkout Code:** Uses `actions/checkout@v4` to pull the latest code.
  - **Install Terraform:** Uses `hashicorp/setup-terraform@v3`.
  - **Format Check:** Runs `terraform fmt -check`.
  - **Configure AWS Credentials:** Uses OIDC to authenticate with AWS securely.
  - **Initialize Terraform:** Runs `terraform init`.
  - **Validate Terraform Configuration:** Runs `terraform validate`.
  - **Run Terraform Plan:** Runs `terraform plan`.
  - **Apply Terraform Changes:** Runs `terraform apply -auto-approve`.
- Used GitHub Secrets to store sensitive AWS configurations.
- Ensured each step runs in the correct order to avoid errors.

## Challenges & Solutions 🛠️

### 1️⃣ Making OIDC Authentication Work

**Problem:** Initially, GitHub Actions failed to assume the IAM role due to missing OIDC provider configuration.
**Solution:** Manually set up an OIDC provider in AWS IAM and updated the trust policy correctly.

### 2️⃣ Keeping Terraform State Secure

**Problem:** Managing Terraform state in a safe and collaborative way.
**Solution:** Stored the state file in an S3 bucket with versioning and encryption enabled.

### 3️⃣ Ensuring Terraform Applied Correctly in CI/CD

**Problem:** The `terraform apply` step initially failed due to state lock issues.
**Solution:** Ensured the `terraform init` step runs first and that AWS credentials are correctly configured.

## Files & Structure 👤

```
.
├── main.tf            # Reference file (empty or minimal configuration)
├── provider.tf        # AWS provider setup and backend configuration
├── variables.tf       # Variables for better reusability
├── resources.tf       # Contains all AWS resources (IAM, S3, etc.)
├── terraform.tfvars   # Values for Terraform variables
├── .github/workflows  # GitHub Actions workflow for Terraform deployment
├── README.md          # This file 😎
```

## Lessons Learned 🎓

- **OIDC authentication** is a more secure alternative to static AWS credentials.
- **Splitting Terraform configurations** into different files improves readability and maintainability.
- **CI/CD automation** with GitHub Actions simplifies infrastructure management but requires careful structuring to avoid errors.
- **Terraform state management** is crucial for consistency and should be handled securely with S3 and proper IAM policies.
- **GitHub Actions troubleshooting** helped in understanding execution order and dependencies in workflows.

## Next Steps 🔁

- Expand the infrastructure by adding more AWS resources (e.g., EC2, RDS, Lambda, etc.).
- Improve error handling and logging in GitHub Actions.
- Implement monitoring solutions (e.g., AWS CloudWatch) for better observability.
- Explore Terraform modules to make configurations more reusable and scalable.

---

That’s it! If you’re checking out this project as a potential employer, I hope this gives you a clear picture of what I built, how I solved challenges, and what I learned along the way. 😊

