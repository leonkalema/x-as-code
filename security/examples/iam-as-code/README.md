# Identity and Access Management as Code

This directory contains examples of managing identity and access control as code across different cloud providers and platforms.

## Overview

IAM as Code involves:

1. **Defining access policies** in code
2. **Automating user provisioning and deprovisioning**
3. **Implementing role-based access control (RBAC)**
4. **Enforcing least privilege**
5. **Managing service identity**

## Examples

- [AWS IAM](./aws) - Managing IAM roles, policies, and service accounts in AWS
- [Kubernetes RBAC](./kubernetes) - Kubernetes role-based access control configurations
- [Azure IAM](./azure) - Azure AD and Azure RBAC as code
- [Terraform OIDC Integration](./terraform-oidc) - Configuring OIDC for Terraform Cloud workloads

## Best Practices Demonstrated

These examples follow security best practices:

1. **Principle of least privilege** - Grant only the permissions needed to perform a task
2. **Just-in-time access** - Provide temporary elevated permissions only when needed
3. **Separation of duties** - Prevent any single person from having excessive privilege
4. **Automated rotation** - Regularly rotate credentials and access keys
5. **Version control** - Track all IAM changes in source control
