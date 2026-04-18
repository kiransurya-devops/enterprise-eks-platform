# =============================================================
# IRSA (IAM Roles for Service Accounts) Module
# Author: Kiran S | AU Technology Consulting
#
# Resolved critical cloud security audit finding:
# Eliminated node-level instance profile abuse
# Each pod gets its own least-privilege IAM role
# =============================================================

# Payment Service Role — S3 read for configs only
resource "aws_iam_role" "payment_service" {
  name = "${var.cluster_name}-payment-service"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = var.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${var.oidc_provider}:aud" = "sts.amazonaws.com"
          "${var.oidc_provider}:sub" = "system:serviceaccount:production:payment-service"
        }
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "payment_service" {
  name = "payment-service-policy"
  role = aws_iam_role.payment_service.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # Read config from specific S3 prefix only
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = "arn:aws:s3:::${var.config_bucket}/payment-service/*"
      },
      {
        # Read secrets from Secrets Manager
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = "arn:aws:secretsmanager:${var.aws_region}:${var.aws_account_id}:secret:prod/payment/*"
      }
    ]
  })
}

# Fluent Bit Role — CloudWatch and S3 log shipping
resource "aws_iam_role" "fluent_bit" {
  name = "${var.cluster_name}-fluent-bit"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = var.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${var.oidc_provider}:sub" = "system:serviceaccount:logging:fluent-bit"
        }
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "fluent_bit" {
  name = "fluent-bit-policy"
  role = aws_iam_role.fluent_bit.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.log_archive_bucket}",
          "arn:aws:s3:::${var.log_archive_bucket}/*"
        ]
      }
    ]
  })
}
