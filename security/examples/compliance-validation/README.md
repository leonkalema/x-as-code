# Compliance as Code

This directory contains examples of implementing compliance validation as code, enabling automated testing and enforcement of security standards and regulatory requirements.

## Overview

Compliance as Code involves:

1. **Defining compliance requirements as testable assertions**
2. **Automating compliance checks in CI/CD pipelines**
3. **Maintaining an audit trail of compliance validations**
4. **Preventing deployment of non-compliant resources**
5. **Continuously monitoring for compliance drift**

## Examples

- [InSpec Profiles](./inspec) - Chef InSpec for infrastructure compliance testing
- [OPA Constraints](./opa-constraints) - Open Policy Agent Gatekeeper constraints for Kubernetes
- [AWS Config Rules](./aws-config) - Custom and managed AWS Config Rules
- [NIST Controls](./nist-controls) - Validation of NIST 800-53 controls

## Regulatory Standards Covered

These examples demonstrate compliance validation for common standards:

1. **NIST 800-53** - Security controls for federal information systems
2. **PCI DSS** - Payment Card Industry Data Security Standard
3. **HIPAA** - Health Insurance Portability and Accountability Act
4. **SOC 2** - Service Organization Control 2
5. **GDPR** - General Data Protection Regulation
