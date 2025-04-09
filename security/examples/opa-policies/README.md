# Open Policy Agent (OPA) Security Policies

This directory contains examples of using [Open Policy Agent (OPA)](https://www.openpolicyagent.org/) to implement security policies as code.

## What is OPA?

OPA is an open-source, general-purpose policy engine that enables unified, context-aware policy enforcement across the stack. OPA provides a high-level declarative language called Rego for specifying policy as code.

## Use Cases

- Kubernetes admission control
- Terraform plan validation
- API authorization
- Service mesh policies
- Container security policies
- Custom policy enforcement

## Examples

- [Kubernetes Pod Security Policies](./kubernetes-pod-security.rego) - Enforcing security best practices for Kubernetes pods
- [Terraform AWS Security Rules](./terraform-aws-security.rego) - Validating AWS resources created via Terraform
- [API Gateway Authorization](./api-gateway-authorization.rego) - Custom authorization rules for API gateways

## Usage

These examples can be used with OPA's command-line tool, integrated into CI/CD pipelines, or deployed as admission controllers in Kubernetes.

```bash
# Example validation of a Kubernetes manifest
opa eval --data kubernetes-pod-security.rego --input pod-manifest.json "data.kubernetes.admission.deny"
```
