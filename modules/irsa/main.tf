locals {
  oidc_issuer_hostpath = replace(var.oidc_issuer_url, "https://", "")
}

resource "aws_iam_policy" "s3_access" {
  name        = "${var.name_prefix}-s3-access"
  description = "S3 access policy for backend services"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          var.s3_bucket_arn,
          "${var.s3_bucket_arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "dynamodb_access" {
  name        = "${var.name_prefix}-container-provisioner-ddb"
  description = "DynamoDB access policy for container-provisioner"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DynamoDBAccessForContainerProvisioner"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:TransactWriteItems"
        ]
        Resource = [
          var.dynamodb_table_arn,
          "${var.dynamodb_table_arn}/index/*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "ecr_access" {
  name        = "${var.name_prefix}-ecr-access"
  description = "ECR read access for backend services"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:DescribeRepositories",
          "ecr:ListImages"
        ]
        Resource = var.ecr_repository_arns
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "cloudwatch_logs" {
  name        = "${var.name_prefix}-cloudwatch-logs"
  description = "CloudWatch Logs access for Fluent Bit"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:PutRetentionPolicy"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "alb_controller" {
  name        = "${var.name_prefix}-alb-controller"
  description = "ALB controller policy"
  policy      = jsonencode(var.alb_policy_json)
}

resource "aws_iam_role" "irsa_alb" {
  name = "${var.name_prefix}-irsa-alb"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRoleWithWebIdentity"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${local.oidc_issuer_hostpath}:aud" = "sts.amazonaws.com",
            "${local.oidc_issuer_hostpath}:sub" = "system:serviceaccount:${var.irsa_alb_namespace}:${var.irsa_service_accounts.alb_controller}"
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "irsa_alb" {
  role       = aws_iam_role.irsa_alb.name
  policy_arn = aws_iam_policy.alb_controller.arn
}

resource "aws_iam_role" "irsa_fluentbit" {
  name = "${var.name_prefix}-irsa-fluentbit"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRoleWithWebIdentity"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${local.oidc_issuer_hostpath}:aud" = "sts.amazonaws.com",
            "${local.oidc_issuer_hostpath}:sub" = "system:serviceaccount:${var.irsa_logging_namespace}:${var.irsa_service_accounts.fluentbit}"
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "irsa_fluentbit_cloudwatch" {
  role       = aws_iam_role.irsa_fluentbit.name
  policy_arn = aws_iam_policy.cloudwatch_logs.arn
}

resource "aws_iam_role" "irsa_container_provisioner" {
  name = "${var.name_prefix}-irsa-container-provisioner"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRoleWithWebIdentity"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${local.oidc_issuer_hostpath}:aud" = "sts.amazonaws.com",
            "${local.oidc_issuer_hostpath}:sub" = "system:serviceaccount:${var.irsa_namespace}:${var.irsa_service_accounts.container_provisioner}"
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "irsa_container_provisioner" {
  role       = aws_iam_role.irsa_container_provisioner.name
  policy_arn = aws_iam_policy.dynamodb_access.arn
}

resource "aws_iam_role" "irsa_backend" {
  name = "${var.name_prefix}-irsa-backend"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRoleWithWebIdentity"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${local.oidc_issuer_hostpath}:aud" = "sts.amazonaws.com",
            "${local.oidc_issuer_hostpath}:sub" = "system:serviceaccount:${var.irsa_namespace}:${var.irsa_service_accounts.backend_service}"
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "irsa_backend_s3" {
  role       = aws_iam_role.irsa_backend.name
  policy_arn = aws_iam_policy.s3_access.arn
}

resource "aws_iam_role_policy_attachment" "irsa_backend_ecr" {
  role       = aws_iam_role.irsa_backend.name
  policy_arn = aws_iam_policy.ecr_access.arn
}
