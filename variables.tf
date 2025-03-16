variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}
variable "github_usr" {
  description = "GitHub Organization or Username"
  type        = string
}
variable "github_repo" {
  description = "GitHub Repository Name"
  type        = string
}

# VPC and Subnet Variables

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}
variable "public_subnet_a_cidr" {
  description = "CIDR block for Public Subnet A"
  type        = string
}
variable "public_subnet_b_cidr" {
  description = "CIDR block for Public Subnet B"
  type        = string
}
variable "private_subnet_a_cidr" {
  description = "CIDR block for Private Subnet A"
  type        = string

}
variable "private_subnet_b_cidr" {
  description = "CIDR block for Private Subnet B"
  type        = string
}
variable "az1" {
  description = "Availability Zone 1"
  type        = string
}
variable "az2" {
  description = "Availability Zone 2"
  type        = string
}