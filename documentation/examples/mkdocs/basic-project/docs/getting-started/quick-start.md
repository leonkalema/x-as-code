# Quick Start

This quick start guide will help you run your first X-as-Code example.

## Choose a Domain

First, decide which "as-code" domain you want to explore. Each domain has its own directory in the repository with examples:

- `infrastructure/` - Infrastructure as Code
- `policy/` - Policy as Code
- `configuration/` - Configuration as Code
- `security/` - Security as Code
- etc.

## Run an Infrastructure as Code Example

Let's start with a basic Infrastructure as Code example using Terraform:

1. Navigate to the example directory:
   ```bash
   cd infrastructure/examples/terraform/aws-basic-web-app
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Create a `terraform.tfvars` file with your configuration:
   ```
   aws_region       = "us-west-2"
   project_name     = "x-as-code-demo"
   key_name         = "your-ssh-key-name"
   ssh_allowed_cidr = "your-ip/32"
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

## Run a Policy as Code Example

Next, let's try a Policy as Code example with Open Policy Agent:

1. Navigate to the example directory:
   ```bash
   cd policy/examples/opa/basic-authz
   ```

2. Evaluate a policy:
   ```bash
   opa eval -i input.json -d policy.rego "data.authz.allow"
   ```

## Explore Other Domains

Follow a similar pattern to explore examples in other domains:

1. Navigate to the domain directory
2. Choose an example
3. Follow the example-specific README.md instructions

## Create Your Own Examples

Once you're comfortable with the existing examples, try creating your own:

1. Choose a domain
2. Create a new directory for your example
3. Add necessary files and documentation
4. Test your example
5. Consider contributing it back to the repository!

## Next Steps

- Explore the [Domain Guides](../domains/infrastructure.md) for more detailed information
- Read the [Best Practices](../guides/best-practices.md) guide
- Learn about [Integration](../guides/integration.md) between different domains
