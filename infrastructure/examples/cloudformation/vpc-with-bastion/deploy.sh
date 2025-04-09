#!/bin/bash

# Parameter values
STACK_NAME="x-as-code-vpc-bastion"
AWS_REGION="us-west-2"
KEY_PAIR_NAME="your-key-pair"
YOUR_IP_ADDRESS="0.0.0.0/0"  # For production, replace with your IP

# Validate template
echo "Validating CloudFormation template..."
aws cloudformation validate-template \
  --template-body file://template.yaml \
  --region $AWS_REGION

# Create the stack
echo "Creating CloudFormation stack: $STACK_NAME"
aws cloudformation create-stack \
  --stack-name $STACK_NAME \
  --template-body file://template.yaml \
  --parameters \
    ParameterKey=KeyPairName,ParameterValue=$KEY_PAIR_NAME \
    ParameterKey=AllowedIpAddress,ParameterValue=$YOUR_IP_ADDRESS \
  --capabilities CAPABILITY_IAM \
  --region $AWS_REGION

# Wait for stack creation to complete
echo "Waiting for stack creation to complete..."
aws cloudformation wait stack-create-complete \
  --stack-name $STACK_NAME \
  --region $AWS_REGION

# Get bastion host public IP
BASTION_IP=$(aws cloudformation describe-stacks \
  --stack-name $STACK_NAME \
  --query "Stacks[0].Outputs[?OutputKey=='BastionPublicIp'].OutputValue" \
  --output text \
  --region $AWS_REGION)

echo "Stack creation complete!"
echo "Bastion Host Public IP: $BASTION_IP"
echo "SSH Connection: ssh -i ~/.ssh/$KEY_PAIR_NAME.pem ec2-user@$BASTION_IP"
