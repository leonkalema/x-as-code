provider "aws" {
  region = var.region
}

# IAM Role for applications to access secrets
resource "aws_iam_role" "app_secrets_access" {
  name = "${var.environment}-${var.application}-secrets-role"
  
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

  tags = {
    Environment = var.environment
    Application = var.application
    ManagedBy   = "terraform"
  }
}

# IAM Policy for accessing specific secrets
resource "aws_iam_policy" "app_secrets_policy" {
  name        = "${var.environment}-${var.application}-secrets-policy"
  description = "Policy that grants access to specific secrets for ${var.application}"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [
          "arn:aws:secretsmanager:${var.region}:${var.account_id}:secret:${var.environment}/${var.application}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = [
          aws_kms_key.secrets_key.arn
        ]
        Condition = {
          StringEquals = {
            "kms:ViaService" = "secretsmanager.${var.region}.amazonaws.com"
          }
        }
      }
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "attach_secrets_policy" {
  role       = aws_iam_role.app_secrets_access.name
  policy_arn = aws_iam_policy.app_secrets_policy.arn
}

# KMS Key for encrypting secrets
resource "aws_kms_key" "secrets_key" {
  description             = "KMS key for encrypting application secrets"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.app_secrets_access.arn
        }
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })
  
  tags = {
    Environment = var.environment
    Application = var.application
    ManagedBy   = "terraform"
  }
}

# KMS Alias for the key
resource "aws_kms_alias" "secrets_key_alias" {
  name          = "alias/${var.environment}-${var.application}-secrets"
  target_key_id = aws_kms_key.secrets_key.key_id
}

# Database Credentials Secret
resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "${var.environment}/${var.application}/database"
  description = "Database credentials for ${var.application} in ${var.environment}"
  kms_key_id  = aws_kms_key.secrets_key.arn
  
  tags = {
    Environment = var.environment
    Application = var.application
    ManagedBy   = "terraform"
  }
}

# API Keys Secret
resource "aws_secretsmanager_secret" "api_keys" {
  name        = "${var.environment}/${var.application}/api-keys"
  description = "API keys for ${var.application} in ${var.environment}"
  kms_key_id  = aws_kms_key.secrets_key.arn
  
  tags = {
    Environment = var.environment
    Application = var.application
    ManagedBy   = "terraform"
  }
}

# Secret rotation configuration for database credentials
resource "aws_secretsmanager_secret_rotation" "db_credentials_rotation" {
  secret_id           = aws_secretsmanager_secret.db_credentials.id
  rotation_lambda_arn = var.rotation_lambda_arn
  
  rotation_rules {
    automatically_after_days = 30
  }
}

# Note: The actual secret values are not stored in Terraform state
# They should be set using AWS CLI, SDK, or through a secure CI/CD process

# Variables
variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-west-2"
}

variable "account_id" {
  type        = string
  description = "AWS account ID"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., dev, staging, prod)"
}

variable "application" {
  type        = string
  description = "Application name"
}

variable "rotation_lambda_arn" {
  type        = string
  description = "ARN of the Lambda function used for secret rotation"
}

# Outputs
output "db_credentials_secret_arn" {
  value       = aws_secretsmanager_secret.db_credentials.arn
  description = "ARN of the database credentials secret"
}

output "api_keys_secret_arn" {
  value       = aws_secretsmanager_secret.api_keys.arn
  description = "ARN of the API keys secret"
}

output "secrets_role_arn" {
  value       = aws_iam_role.app_secrets_access.arn
  description = "ARN of the IAM role that can access secrets"
}
