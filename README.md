# Terraform Project - AWS Infrastructure Deployment

## Overview 🚀

This project focuses on setting up an AWS infrastructure using Terraform, ensuring automation, security, and a smooth deployment process through GitHub Actions. The goal was to create an IAM role for GitHub Actions to interact with AWS securely using OpenID Connect (OIDC) and to provision AWS resources like an S3 bucket for Terraform state management. Additionally, I focused on optimizing the Terraform execution process, handling Git LFS for large files, and ensuring best practices for long-term infrastructure scalability.

## What I Have Done ✅

### 1. Installed and Configured Required Software

- Installed AWS CLI and configured it to work with my AWS account.
- Installed Terraform (version 1.6+) to define and manage AWS resources.
- Verified installations and ensured all dependencies were correctly configured to prevent any compatibility issues.

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
- Ensured security best practices were followed by restricting IAM policies to the minimum required privileges.

### 3. Created an S3 Bucket for Terraform State

- Used best practices for Terraform state management:
  - Enabled versioning and encryption for security.
  - Defined the backend in Terraform to store the state remotely in S3.
  - Ensured proper IAM permissions for state access.
  - Configured state locking mechanisms to prevent simultaneous conflicting updates.
  - Implemented lifecycle policies for better state file management.

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
- Optimized workflow execution by reducing redundant actions and improving caching mechanisms.

## Challenges & Solutions 🛠️

### 1️⃣ Making OIDC Authentication Work

**Problem:** Initially, GitHub Actions failed to assume the IAM role due to missing OIDC provider configuration.

**Solution:** I manually set up an OIDC provider in AWS IAM and updated the trust policy correctly, ensuring GitHub Actions had the proper permissions to authenticate and deploy infrastructure securely.

### 2️⃣ Keeping Terraform State Secure

**Problem:** Managing Terraform state in a safe and collaborative way.

**Solution:** I stored the state file in an S3 bucket with versioning and encryption enabled, applied strict IAM policies, and enabled state locking to avoid inconsistencies in deployment.

### 3️⃣ Ensuring Terraform Applied Correctly in CI/CD

**Problem:** The `terraform apply` step initially failed due to state lock issues.

**Solution:** I ensured the `terraform init` step runs first and that AWS credentials are correctly configured. Additionally, I verified that Terraform had proper permissions to access the remote backend and resolve state conflicts.

### 4️⃣ Optimizing GitHub Actions with Environment Variables

**Problem:** Initially, Terraform ran very slowly in GitHub Actions because secrets had to be fetched multiple times from GitHub Secrets storage. Each time a Terraform step needed `aws_account_id`, it triggered an API call to retrieve the secret, slowing down the workflow significantly.

**Solution:** I optimized the process by storing the secret as an environment variable at the beginning of the workflow using `$GITHUB_ENV`. Instead of querying GitHub Secrets every time, I wrote the value once and used it throughout all Terraform steps:

```yaml
      - name: Write AWS Account ID to env file
        run: echo "TF_VAR_aws_account_id=${{ secrets.AWS_ACCOUNT_ID }}" >> $GITHUB_ENV

      - name: Run Terraform
        run: |
          terraform init
          terraform fmt -check
          terraform validate
          terraform plan
          terraform apply -auto-approve
        env:
          TF_VAR_aws_account_id: ${{ env.TF_VAR_aws_account_id }}
```

This significantly reduced execution time, optimized workflow efficiency, and eliminated unnecessary API calls to GitHub Secrets.

## Files & Structure 👤

```bash
.
├── main.tf            # Reference file (empty or minimal configuration)
├── provider.tf        # AWS provider setup and backend configuration
├── variables.tf       # Variables for better reusability
├── resources.tf       # Contains all AWS resources (IAM, S3, etc.)
├── terraform.tfvars   # Values for Terraform variables
├── .github/workflows  # GitHub Actions workflow for Terraform deployment
├── .gitattributes     # Git LFS configuration to manage large files like .terraform/
├── README.md          
```

## Lessons Learned 🎓

- **OIDC authentication** is a more secure alternative to static AWS credentials.
- **Splitting Terraform configurations** into different files improves readability and maintainability.
- **CI/CD automation** with GitHub Actions simplifies infrastructure management but requires careful structuring to avoid errors.
- **Terraform state management** is crucial for consistency and should be handled securely with S3 and proper IAM policies.
- **GitHub Actions optimization** by using `$GITHUB_ENV` significantly improves performance by reducing redundant API calls.
- **Git LFS is useful for handling large files**, such as `.terraform/`, ensuring they do not slow down the repository.
- **Caching Terraform dependencies** helped improve workflow speed and reduced unnecessary installations.
