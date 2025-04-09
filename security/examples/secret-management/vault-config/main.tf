provider "vault" {
  # Configuration provided via environment variables:
  # VAULT_ADDR, VAULT_TOKEN, VAULT_CACERT, etc.
}

# Enable the KV secrets engine
resource "vault_mount" "kv" {
  path        = "secret"
  type        = "kv"
  options     = { version = "2" }
  description = "KV Version 2 secret engine mount"
}

# Enable the AWS secrets engine
resource "vault_aws_secret_backend" "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  path       = "aws"

  default_lease_ttl_seconds = 3600        # 1 hour
  max_lease_ttl_seconds     = 86400       # 24 hours
}

# Create a role for the AWS secrets engine
resource "vault_aws_secret_backend_role" "role" {
  backend         = vault_aws_secret_backend.aws.path
  name            = "app-role"
  credential_type = "iam_user"

  policy_document = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::app-bucket",
        "arn:aws:s3:::app-bucket/*"
      ]
    }
  ]
}
EOF
}

# Create an app policy
resource "vault_policy" "app_policy" {
  name = "app-policy"

  policy = <<EOT
# Allow the app to read its own secrets
path "secret/data/app/*" {
  capabilities = ["read"]
}

# Allow the app to get AWS credentials
path "aws/creds/app-role" {
  capabilities = ["read"]
}

# Deny access to all other paths
path "*" {
  capabilities = ["deny"]
}
EOT
}

# Create an admin policy
resource "vault_policy" "admin_policy" {
  name = "admin-policy"

  policy = <<EOT
# Full access to KV store
path "secret/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Manage AWS secret engine configuration
path "aws/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Manage authentication methods
path "auth/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Manage policies
path "sys/policies/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# List available secret engines
path "sys/mounts" {
  capabilities = ["read", "list"]
}
EOT
}

# Enable AppRole auth method
resource "vault_auth_backend" "approle" {
  type = "approle"
}

# Create an app role
resource "vault_approle_auth_backend_role" "app" {
  backend        = vault_auth_backend.approle.path
  role_name      = "app-role"
  token_policies = [vault_policy.app_policy.name]

  token_ttl            = 3600     # 1 hour
  token_max_ttl        = 86400    # 24 hours
  token_num_uses       = 0        # Unlimited uses
  secret_id_num_uses   = 0        # Unlimited uses
  secret_id_ttl        = 86400    # 24 hours
}

# Variables
variable "aws_access_key" {
  type        = string
  description = "AWS Access Key. This will be stored securely in Vault."
  sensitive   = true
}

variable "aws_secret_key" {
  type        = string
  description = "AWS Secret Key. This will be stored securely in Vault."
  sensitive   = true
}

# Outputs
output "app_role_id" {
  value       = vault_approle_auth_backend_role.app.role_id
  description = "The Role ID for the app role"
  sensitive   = true
}

# Secret ID must be generated separately after applying this configuration
# This is more secure as it keeps the Secret ID out of state files
