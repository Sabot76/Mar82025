🚀 Overview
This project is an automation setup for deploying AWS resources using Terraform, integrated with GitHub Actions. 
My goal was to make infrastructure management smooth and automated, particularly around deploying resources like S3 buckets and IAM roles for CI/CD pipelines.

🛠️ How I Handled the Task
The project started with the need to automate AWS infrastructure deployment. 
I had to manage resources like S3 buckets and IAM roles, which would interact with GitHub Actions to trigger the deployment pipeline.

Breaking It Down:
I first split the Terraform configuration into logical pieces to make it more organized. I put the provider and backend configurations in provider.tf and the actual resource definitions (S3 bucket, IAM roles) into resources.tf. I even left main.tf intentionally empty since I didn’t need anything in it for this setup.
Variables like aws_account_id, github_usr, and github_repo were set in a separate variables.tf to avoid hardcoding sensitive information.

The GitHub Actions Workflow:
The next challenge was setting up GitHub Actions for continuous deployment. I wanted to ensure that every time a change was pushed to the main branch or a pull request was opened, the Terraform workflow would automatically run.
I integrated terraform fmt, terraform plan, and terraform apply in a sequence so that the changes would be automatically formatted, planned, and applied to AWS, reducing manual intervention.

Connecting to AWS:
The tricky part was setting up AWS access securely. I used OIDC (OpenID Connect) to allow GitHub Actions to assume a role in AWS without needing long-lived AWS credentials. This took some time to figure out, especially because AWS requires the correct configuration for the OIDC provider and policies attached to the role.
Once the permissions were sorted out, I set up the IAM role to allow GitHub Actions to assume it securely using OIDC.

State Management:
To avoid managing state files locally, I configured the S3 backend for Terraform to store the state remotely. This way, I could collaborate without worrying about local state conflicts and kept the state safe and centralized.

⚡ Challenges I Encountered
Configuring AWS Permissions:
One of the toughest challenges was getting the right AWS permissions for the IAM roles. I needed to make sure the GitHub Actions role had access to the correct AWS services, like EC2, S3, and IAM. Initially, I didn’t realize I had to create the IAM policies manually before attaching them to the role, which delayed progress a bit.
OIDC Integration:
Setting up OIDC (OpenID Connect) for GitHub Actions to assume the role in AWS was another challenge. The official AWS documentation was helpful, but the process was still tricky to get right, especially in terms of setting up the right conditions in the role policy for GitHub Actions.
Terraform State Management:
Configuring the remote state using S3 and DynamoDB for locking was another part of the puzzle. I needed to ensure that multiple collaborators wouldn’t interfere with each other’s work while managing the state file. Getting the backend configuration in place was essential for smooth collaboration.
Automation Workflow:
Making sure the GitHub Actions workflow ran seamlessly after a push or pull request took some troubleshooting. There were a few errors where I didn’t have the correct dependencies set up in the workflow, but I resolved them by adjusting the job sequence and permissions.
