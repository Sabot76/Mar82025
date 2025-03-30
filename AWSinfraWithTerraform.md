# AWS Networking Infrastructure Setup with Terraform

## Overview 🚀

This project sets up a basic AWS networking infrastructure using Terraform.  
The infrastructure includes:

- **VPC (Virtual Private Cloud)**
- **2 Public Subnets (Different AZs)**
- **2 Private Subnets (Different AZs)**
- **Internet Gateway**
- **1 NAT Gateway (cost-optimized)**
- **Proper Route Tables and Associations**

This setup is ideal for hosting Kubernetes clusters or any cloud resources requiring secure, highly available networking.

---

## Architecture

```bash
[VPC]
 ├── Public Subnet A (AZ1)  --> Internet Gateway
 ├── Public Subnet B (AZ2)  --> Internet Gateway
 ├── Private Subnet A (AZ1) --> NAT Gateway (via Public Subnet A)
 └── Private Subnet B (AZ2) --> NAT Gateway (via Public Subnet A)
```

---

## Visual Networking Diagram

```bash
AWS Region (eu-west-2)
│
├── VPC: 10.0.0.0/16
│   ├── Internet Gateway (attached to VPC)
│   ├── NAT Gateway (in Public Subnet A)
│   │
│   ├── Public Subnet A (10.0.1.0/24, AZ1)
│   │   └── Route Table: 0.0.0.0/0 -> Internet Gateway
│   ├── Public Subnet B (10.0.2.0/24, AZ2)
│   │   └── Route Table: 0.0.0.0/0 -> Internet Gateway
│   │
│   ├── Private Subnet A (10.0.3.0/24, AZ1)
│   │   └── Route Table: 0.0.0.0/0 -> NAT Gateway
│   └── Private Subnet B (10.0.4.0/24, AZ2)
│       └── Route Table: 0.0.0.0/0 -> NAT Gateway
```

---

## Components Breakdown 🧩

| Component            | Purpose                                                        | Free? |
|---------------------|----------------------------------------------------------------|-------|
| **VPC**              | Private network                                                | ✅    |
| **2 Public Subnets** | For Load Balancers, Bastion hosts, internet-facing resources   | ✅    |
| **2 Private Subnets**| For internal, secure resources                                 | ✅    |
| **Internet Gateway** | Provides outbound internet access to public subnets            | ✅    |
| **1 NAT Gateway**    | Allows private subnets to access the internet securely         | ❌    |
| **Route Tables**     | Controls routing between subnets and gateways                  | ✅    |

---

## Terraform File Structure 📂

| File              | Purpose                                                                |
|-------------------|-----------------------------------------------------------------------|
| `main.tf`         | Minimal configuration, references other files.                        |
| `provider.tf`     | AWS provider setup and backend configuration.                         |
| `variables.tf`    | All reusable variables (VPC CIDRs, subnet CIDRs, AZs, etc.).           |
| `resources.tf`    | AWS resources like IAM roles, S3, and now networking resources.        |
| `terraform.tfvars`| Actual values for the defined variables.                              |
| `.github/workflows`| Contains CI/CD workflow for Terraform deployment.                    |

---

## Next Steps

### 1️⃣ Infrastructure Setup

The Terraform code provisions:

- VPC
- 2 Public Subnets in different AZs
- 2 Private Subnets in different AZs
- Internet Gateway
- NAT Gateway (single instance for cost efficiency)
- Route Tables & Associations

### 2️⃣ Connectivity Test

To verify the setup:

1. Launch one EC2 instance in a **Public Subnet** → Check internet access (ping `8.8.8.8`).
2. Launch one EC2 instance in a **Private Subnet** → Should access internet via NAT Gateway.
