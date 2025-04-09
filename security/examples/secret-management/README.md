# Secret Management as Code

This directory contains examples of securely managing secrets as code, demonstrating how to integrate secret management into infrastructure and application deployments.

## Overview

Secret management as code involves:

1. **Version-controlled secret configurations** (without the actual secret values)
2. **Automated secret rotation and distribution**
3. **Access policies defined as code**
4. **Integration with CI/CD pipelines**

## Examples

- [HashiCorp Vault Configuration](./vault-config) - Infrastructure as code for Vault setup and policy configuration
- [Kubernetes External Secrets](./kubernetes-external-secrets) - Using the External Secrets Operator to source secrets from external providers
- [AWS Secrets Manager with Terraform](./aws-secrets-manager) - Managing AWS Secrets Manager resources with Terraform
- [GitOps Secret Management](./gitops-secrets) - Sealed Secrets and other GitOps-friendly approaches

## Best Practices Demonstrated

These examples follow security best practices:

1. **Never store sensitive values in version control**
2. **Use dedicated secret management services**
3. **Apply least-privilege access controls**
4. **Rotate secrets automatically**
5. **Audit and monitor secret access**
