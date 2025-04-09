# AWS Basic Web Application

This example demonstrates how to use Terraform to deploy a basic web server on AWS with the following components:

- VPC with public subnet
- Internet Gateway
- Security Group
- EC2 instance running a simple web server

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed (v1.0+)
- AWS account and [AWS CLI](https://aws.amazon.com/cli/) configured
- SSH key pair created in AWS

## Usage

1. Initialize Terraform:
   ```bash
   terraform init
   ```

2. Customize the deployment by creating a `terraform.tfvars` file:
   ```
   aws_region       = "us-west-2"
   project_name     = "my-web-app"
   key_name         = "your-key-pair-name"
   ssh_allowed_cidr = "your-ip-address/32"
   ```

3. Plan the deployment:
   ```bash
   terraform plan
   ```

4. Apply the configuration:
   ```bash
   terraform apply
   ```

5. Access your web server using the outputted public IP address.

6. When finished, destroy the resources:
   ```bash
   terraform destroy
   ```

## Security Considerations

For production use:
- Restrict SSH access to specific IP addresses
- Use private subnets with a NAT Gateway for EC2 instances
- Enable HTTPS and configure proper certificates
- Implement more granular security groups

## Integration Points

This example can be integrated with:
- Configuration as Code (to configure the web server)
- Security as Code (to scan for security issues)
- Compliance as Code (to ensure compliance with standards)
