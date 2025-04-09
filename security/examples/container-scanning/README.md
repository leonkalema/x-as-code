# Container Scanning as Code

This directory contains examples of integrating container image scanning into CI/CD pipelines and Kubernetes deployments.

## Overview

Container scanning is a crucial part of security as code, allowing teams to:

1. **Detect vulnerabilities** in container images before deployment
2. **Enforce security policies** for container images
3. **Prevent deployment** of insecure containers
4. **Maintain an audit trail** of security scans

## Examples

- [GitHub Actions Trivy Scan](./.github/workflows/trivy-scan.yml) - Workflow for scanning container images with Trivy in GitHub Actions
- [Kubernetes Admission Controller](./k8s-admission-controller) - Webhook that validates container images before deployment to Kubernetes
- [Jenkins Pipeline](./Jenkinsfile) - Jenkins pipeline script demonstrating container scanning integration

## Tools Demonstrated

- [Trivy](https://github.com/aquasecurity/trivy) - A simple and comprehensive vulnerability scanner for containers
- [Anchore Engine](https://github.com/anchore/anchore-engine) - Deep container image analysis and policy evaluation
- [Clair](https://github.com/quay/clair) - Static analysis of vulnerabilities in container images

## Integration Points

These examples show how to integrate container scanning at various points:
- During image build
- Before pushing to a registry
- As part of a Kubernetes admission control process
- In a CI/CD pipeline
