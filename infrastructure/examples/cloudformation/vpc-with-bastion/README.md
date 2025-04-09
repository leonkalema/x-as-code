# VPC with Bastion Host using CloudFormation

This example demonstrates how to use AWS CloudFormation to create a secure VPC architecture with the following components:

- VPC with public and private subnets across two availability zones
- Internet Gateway for public internet access
- NAT Gateway for private subnet outbound access
- Bastion host for secure SSH access to resources in private subnets
- Appropriate security groups and routing tables

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│ VPC                                                                 │
│                                                                     │
│  ┌─────────────────────────┐         ┌─────────────────────────┐    │
│  │ Public Subnet 1         │         │ Public Subnet 2         │    │
│  │                         │         │                         │    │
│  │                         │         │                         │    │
│  │    ┌─────────────┐      │         │                         │    │
│  │    │ Bastion Host│      │         │                         │    │
│  │    └─────────────┘      │         │                         │    │
│  │                         │         │                         │    │
│  │    ┌─────────────┐      │         │                         │    │
│  │    │NAT Gateway  │      │         │                         │    │
│  │    └─────────────┘      │         │                         │    │
│  └─────────────────────────┘         └─────────────────────────┘    │
│                                                                     │
│  ┌─────────────────────────┐         ┌─────────────────────────┐    │
│  │ Private Subnet 1        │         │ Private Subnet 2        │    │
│  │                         │         │                         │    │
│  │                         │         │                         │    │
│  │                         │         │                         │    │
│  │                         │         │                         │    │
│  │                         │         │                         │    │
│  │                         │         │                         │    │
│  └─────────────────────────┘         └─────────────────────────┘    │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
          ↑                                         
          │                                         
    Internet Gateway
          ↑
          │
       Internet
```

## Prerequisites

- AWS CLI installed and configured
- An EC2 key pair for SSH access to the bastion host

## Deployment

1. Edit the `deploy.sh` script:
   - Set your preferred AWS region
   - Set your EC2 key pair name
   - Set your IP address CIDR for SSH access (for security)

2. Make the script executable:
   ```bash
   chmod +x deploy.sh
   ```

3. Run the deployment script:
   ```bash
   ./deploy.sh
   ```

4. SSH to the bastion host:
   ```bash
   ssh -i ~/.ssh/your-key-pair.pem ec2-user@<bastion-ip>
   ```

## Clean Up

To delete all resources created by this stack:

```bash
aws cloudformation delete-stack --stack-name x-as-code-vpc-bastion
```

## Security Considerations

For production use, consider the following security improvements:

- Restrict SSH access to the bastion host to your specific IP address
- Enable detailed CloudTrail logging
- Implement AWS Session Manager for SSH access instead of a bastion host
- Add auto-rotation of SSH keys
- Set up CloudWatch alarms for bastion host access attempts

## Integration Points

This example can be integrated with:
- Configuration as Code (to configure the bastion host)
- Security as Code (to scan for security issues)
- Compliance as Code (to ensure compliance with standards)
- Other Infrastructure as Code templates that need a secure VPC
