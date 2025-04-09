# AWS CloudFormation Examples

This directory contains examples of infrastructure as code using AWS CloudFormation, Amazon's native Infrastructure as Code (IaC) service.

## What is CloudFormation?

[AWS CloudFormation](https://aws.amazon.com/cloudformation/) is a service that helps you model and set up your Amazon Web Services resources so that you can spend less time managing those resources and more time focusing on your applications. You create a template that describes all the AWS resources that you want (like Amazon EC2 instances or Amazon RDS DB instances), and CloudFormation takes care of provisioning and configuring those resources for you.

## Examples

- [VPC with Bastion Host](./vpc-with-bastion/): A complete VPC setup with public and private subnets, NAT Gateway, and a bastion host for secure access.

## Key Benefits of CloudFormation

- **Native AWS Integration**: As an AWS service, it has deep integration with all AWS resources.
- **Declarative Syntax**: Define what resources you want rather than how to create them.
- **Stacks and Change Sets**: Group resources together and preview changes before applying them.
- **Drift Detection**: Identify when resources have changed outside of CloudFormation.
- **StackSets**: Deploy templates across multiple accounts and regions.
- **Resource Dependencies**: Automatically handle the correct creation and deletion order.

## Template Format

CloudFormation templates can be written in either JSON or YAML. The examples in this repository use YAML for improved readability.

A basic CloudFormation template structure:

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'Description of the template'

Parameters:
  # Input parameters for the template

Resources:
  # AWS resources to create

Outputs:
  # Values to return upon stack creation
```

## Getting Started

To run these examples, you'll need:

1. AWS CLI installed and configured with appropriate credentials
2. Knowledge of which AWS region you want to deploy resources to
3. Any prerequisites specified in the example's README.md (like EC2 key pairs)

## Resources

- [AWS CloudFormation Documentation](https://docs.aws.amazon.com/cloudformation/)
- [AWS CloudFormation Designer](https://console.aws.amazon.com/cloudformation/designer)
- [AWS CloudFormation Registry](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/registry.html)
