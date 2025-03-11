provider "aws" {
  region = "eu-west-2"
}
terraform {
  backend "s3" {
    bucket = "my-terraform-state-bucket-try1"
    key = "terraform.tfstate"
    region = "eu-west-2"
    encrypt = true
  }
}
resource "aws_s3_bucket" "my_kicsi_buket" {
  bucket = "my-new-terraform-bucket-batuisten-estobbis"
}