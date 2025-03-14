# resources.tf

# Create an S3 bucket
resource "aws_s3_bucket" "my_kicsi_buket" {
  bucket = "my-new-terraform-bucket-batuisten-estobbis"
}

# Create an IAM role for GitHub Actions
resource "aws_iam_role" "github_actions_role" {
  name = "GithubActionsRole"

  assume_role_policy = <<EOF
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
  EOF
}

# Attach IAM policies to the GitHub Actions IAM role
resource "aws_iam_role_policy_attachment" "github_actions_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/AmazonRoute53FullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/IAMFullAccess",
    "arn:aws:iam::aws:policy/AmazonVPCFullAccess",
    "arn:aws:iam::aws:policy/AmazonSQSFullAccess",
    "arn:aws:iam::aws:policy/AmazonEventBridgeFullAccess"
  ])
  role       = aws_iam_role.github_actions_role.name
  policy_arn = each.value
}
