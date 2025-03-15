# provider.tf

# AWS provider configuration
provider "aws" {
  region = "eu-west-2"
}

# Backend configuration to store Terraform state in an S3 bucket
terraform {
  backend "s3" {
    bucket  = "my-terraform-state-bucket-try1"
    key     = "terraform.tfstate"
    region  = "eu-west-2"
    encrypt = true
  }
}
