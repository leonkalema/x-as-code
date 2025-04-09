---
sidebar_position: 2
---

# Getting Started

This guide will help you get started with the X-as-Code repository and run your first examples.

## Prerequisites

Before diving into the examples, make sure you have the following tools installed:

- **Git**: For cloning the repository
- **Docker**: For running containerized examples
- **Domain-specific tools**: Depending on which examples you want to run (Terraform, Ansible, etc.)

## Clone the Repository

First, clone the X-as-Code repository:

```bash
git clone https://github.com/yourusername/x-as-code.git
cd x-as-code
```

## Repository Structure

The repository is organized by domains:

```
x-as-code/
├── infrastructure/       # Infrastructure as Code examples
├── policy/               # Policy as Code examples
├── configuration/        # Configuration as Code examples
├── security/             # Security as Code examples
├── resilience/           # Resilience as Code examples
├── monitoring/           # Monitoring as Code examples
├── data/                 # Data as Code examples
├── compliance/           # Compliance as Code examples
├── documentation/        # Documentation as Code examples
└── access/               # Access/Identity as Code examples
```

Each domain directory contains:
- A README.md with domain-specific information
- An `examples/` directory with practical examples
- Additional resources and documentation

## Running Your First Example

Let's run a basic Infrastructure as Code example using Terraform:

### Infrastructure as Code Example

1. Navigate to the Terraform example directory:

```bash
cd infrastructure/examples/terraform/aws-basic-web-app
```

2. Initialize Terraform:

```bash
terraform init
```

3. Create a `terraform.tfvars` file with your specific configuration:

```
aws_region       = "us-west-2"
project_name     = "my-web-app"
key_name         = "your-key-pair-name"
ssh_allowed_cidr = "your-ip-address/32"
```

4. Plan the deployment:

```bash
terraform plan
```

5. Apply the configuration:

```bash
terraform apply
```

6. When finished, destroy the resources:

```bash
terraform destroy
```

## Next Steps

After running your first example, you can:

1. Explore other examples in the same domain
2. Try examples from different domains
3. Learn how to integrate multiple domains together
4. Contribute your own examples to the repository

## Additional Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [OPA Documentation](https://www.openpolicyagent.org/docs/latest/)
- [Ansible Documentation](https://docs.ansible.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/home/)
