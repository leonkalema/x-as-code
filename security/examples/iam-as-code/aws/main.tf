provider "aws" {
  region = var.region
}

# -----------------------------
# IAM Role for EC2 Instances
# -----------------------------

resource "aws_iam_role" "ec2_app_role" {
  name = "${var.environment}-app-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  
  # Force MFA for assuming this role from the console
  # This doesn't apply to EC2 instances, only for human users who might attempt to assume this role
  dynamic "condition" {
    for_each = var.require_mfa ? [1] : []
    content {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["true"]
    }
  }
  
  # Force a maximum session duration
  max_session_duration = 3600  # 1 hour
  
  # Permissions boundary to limit maximum possible permissions
  permissions_boundary = aws_iam_policy.permissions_boundary.arn
  
  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# EC2 instance profile
resource "aws_iam_instance_profile" "app_profile" {
  name = "${var.environment}-app-profile"
  role = aws_iam_role.ec2_app_role.name
}

# -----------------------------
# Permission sets and policies
# -----------------------------

# Permissions boundary for all roles
resource "aws_iam_policy" "permissions_boundary" {
  name        = "${var.environment}-permissions-boundary"
  description = "Permissions boundary for all IAM roles"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:*",
          "dynamodb:*",
          "sqs:*",
          "sns:*",
          "cloudwatch:*",
          "logs:*",
          "ec2:Describe*"
        ]
        Resource = "*"
      },
      {
        Effect = "Deny"
        Action = [
          "iam:*",
          "organizations:*",
          "ec2:*DeleteSecurityGroup*",
          "ec2:*CreateSecurityGroup*"
        ]
        Resource = "*"
      }
    ]
  })
}

# S3 read-only access policy
resource "aws_iam_policy" "s3_read_only" {
  name        = "${var.environment}-s3-read-only"
  description = "Allows read-only access to specific S3 buckets"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = [
          "arn:aws:s3:::${var.app_bucket}",
          "arn:aws:s3:::${var.app_bucket}/*"
        ]
      }
    ]
  })
}

# SQS message processing policy
resource "aws_iam_policy" "sqs_processing" {
  name        = "${var.environment}-sqs-processing"
  description = "Allows processing of SQS messages"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = var.sqs_queue_arns
      }
    ]
  })
}

# CloudWatch logging policy
resource "aws_iam_policy" "cloudwatch_logging" {
  name        = "${var.environment}-cloudwatch-logging"
  description = "Allows writing logs to CloudWatch"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = [
          "arn:aws:logs:${var.region}:${var.account_id}:log-group:/aws/ec2/${var.environment}-app-*:*"
        ]
      }
    ]
  })
}

# DynamoDB access policy
resource "aws_iam_policy" "dynamodb_access" {
  name        = "${var.environment}-dynamodb-access"
  description = "Allows access to DynamoDB tables"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:BatchGetItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem"
        ]
        Resource = var.dynamodb_table_arns
      }
    ]
  })
}

# Attach policies to role
resource "aws_iam_role_policy_attachment" "attach_s3_read_only" {
  role       = aws_iam_role.ec2_app_role.name
  policy_arn = aws_iam_policy.s3_read_only.arn
}

resource "aws_iam_role_policy_attachment" "attach_sqs_processing" {
  role       = aws_iam_role.ec2_app_role.name
  policy_arn = aws_iam_policy.sqs_processing.arn
}

resource "aws_iam_role_policy_attachment" "attach_cloudwatch_logging" {
  role       = aws_iam_role.ec2_app_role.name
  policy_arn = aws_iam_policy.cloudwatch_logging.arn
}

resource "aws_iam_role_policy_attachment" "attach_dynamodb_access" {
  role       = aws_iam_role.ec2_app_role.name
  policy_arn = aws_iam_policy.dynamodb_access.arn
}

# -----------------------------
# IAM Role for CI/CD Pipeline
# -----------------------------

resource "aws_iam_role" "cicd_role" {
  name = "${var.environment}-cicd-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = var.ci_system_account_arn
        }
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.ci_external_id
          }
        }
      }
    ]
  })
  
  # Permissions boundary to limit maximum possible permissions
  permissions_boundary = aws_iam_policy.permissions_boundary.arn
  
  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# CI/CD deployment policy
resource "aws_iam_policy" "cicd_deployment" {
  name        = "${var.environment}-cicd-deployment"
  description = "Allows CI/CD system to deploy applications"
  
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
          "arn:aws:s3:::${var.app_bucket}",
          "arn:aws:s3:::${var.app_bucket}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeTargetHealth",
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:UpdateAutoScalingGroup"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach policy to CI/CD role
resource "aws_iam_role_policy_attachment" "attach_cicd_deployment" {
  role       = aws_iam_role.cicd_role.name
  policy_arn = aws_iam_policy.cicd_deployment.arn
}

# -----------------------------
# IAM User Group for Developers
# -----------------------------

resource "aws_iam_group" "developers" {
  name = "${var.environment}-developers"
}

# Developers policy
resource "aws_iam_policy" "developers_policy" {
  name        = "${var.environment}-developers-policy"
  description = "Policy for developers with read access and limited write capabilities"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:Get*",
          "s3:List*",
          "dynamodb:Get*",
          "dynamodb:List*",
          "dynamodb:Query",
          "dynamodb:Scan",
          "cloudwatch:Get*",
          "cloudwatch:List*",
          "logs:Get*",
          "logs:List*",
          "logs:StartQuery",
          "logs:StopQuery",
          "logs:FilterLogEvents",
          "ec2:Describe*",
          "elasticloadbalancing:Describe*",
          "autoscaling:Describe*"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.app_bucket}/dev/*"
        ]
      }
    ]
  })
}

# Attach policy to developer group
resource "aws_iam_group_policy_attachment" "attach_developers_policy" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.developers_policy.arn
}

# -----------------------------
# Variables
# -----------------------------

variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-west-2"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., dev, staging, prod)"
}

variable "account_id" {
  type        = string
  description = "AWS account ID"
}

variable "app_bucket" {
  type        = string
  description = "S3 bucket name for the application"
}

variable "sqs_queue_arns" {
  type        = list(string)
  description = "List of SQS queue ARNs"
}

variable "dynamodb_table_arns" {
  type        = list(string)
  description = "List of DynamoDB table ARNs"
}

variable "ci_system_account_arn" {
  type        = string
  description = "ARN of the account running the CI/CD system"
}

variable "ci_external_id" {
  type        = string
  description = "External ID for the CI/CD system to assume this role"
  sensitive   = true
}

variable "require_mfa" {
  type        = bool
  description = "Whether to require MFA for assuming roles"
  default     = true
}

# -----------------------------
# Outputs
# -----------------------------

output "ec2_instance_profile_name" {
  value       = aws_iam_instance_profile.app_profile.name
  description = "Name of the EC2 instance profile"
}

output "ec2_role_arn" {
  value       = aws_iam_role.ec2_app_role.arn
  description = "ARN of the EC2 instance role"
}

output "cicd_role_arn" {
  value       = aws_iam_role.cicd_role.arn
  description = "ARN of the CI/CD role"
}

output "developers_group_name" {
  value       = aws_iam_group.developers.name
  description = "Name of the developers IAM group"
}
