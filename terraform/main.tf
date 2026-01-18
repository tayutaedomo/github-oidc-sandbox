variable "aws_profile" {
  description = "AWS CLI Profile to use"
  type        = string
}

provider "aws" {
  region  = "us-east-1"
  profile = var.aws_profile
}

# OIDC Provider
resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  # thumbprint list of the server certificate.
  # 6938fd4d98bab03faadb97b34396831e3780aea1 is for token.actions.githubusercontent.com
  # 1c58a3a8518e8759bf075b76b750d4f2df264fcd is old certificate
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1", "1c58a3a8518e8759bf075b76b750d4f2df264fcd"]
}

# IAM Role
resource "aws_iam_role" "github_actions" {
  name = "github-oidc-verify-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com"
          }
          StringLike = {
            # Restrict to this repository
            "token.actions.githubusercontent.com:sub" : "repo:tayutaedomo/github-oidc-sandbox:*"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "github_actions_verify" {
  name = "github-oidc-verify-policy"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sts:GetCallerIdentity"
        Resource = "*"
      }
    ]
  })
}

# Outputs
output "role_arn" {
  description = "ARN of the IAM Role for GitHub Actions"
  value       = aws_iam_role.github_actions.arn
}
