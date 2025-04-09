# encoding: utf-8
# AWS Compliance Profile

title 'AWS Security and Compliance Profile'

# Define the AWS credentials
aws_region = input('aws_region', value: 'us-west-2', description: 'AWS region')
aws_vpc_id = input('aws_vpc_id', description: 'AWS VPC ID to check')

# Check for encrypted S3 buckets
control 'aws-s3-1' do
  impact 1.0
  title 'Ensure S3 buckets enforce encryption'
  desc 'This control ensures that all S3 buckets are configured with default encryption.'
  tag compliance: ['PCI DSS 3.4', 'NIST 800-53 SC-28']
  
  aws_s3_buckets.bucket_names.each do |bucket_name|
    describe aws_s3_bucket(bucket_name) do
      it { should have_default_encryption_enabled }
    end
  end
end

# Check for public S3 buckets
control 'aws-s3-2' do
  impact 1.0
  title 'Ensure S3 buckets are not publicly accessible'
  desc 'This control ensures that S3 buckets do not allow public access.'
  tag compliance: ['PCI DSS 1.3', 'NIST 800-53 AC-3']
  
  aws_s3_buckets.bucket_names.each do |bucket_name|
    describe aws_s3_bucket(bucket_name) do
      it { should_not be_public }
    end
  end
end

# Check S3 bucket logging
control 'aws-s3-3' do
  impact 0.7
  title 'Ensure S3 buckets have logging enabled'
  desc 'This control ensures that S3 buckets have server access logging enabled.'
  tag compliance: ['PCI DSS 10.2', 'NIST 800-53 AU-2']
  
  aws_s3_buckets.bucket_names.each do |bucket_name|
    describe aws_s3_bucket(bucket_name) do
      it { should have_access_logging_enabled }
    end
  end
end

# Check for encrypted EBS volumes
control 'aws-ebs-1' do
  impact 1.0
  title 'Ensure EBS volumes are encrypted'
  desc 'This control ensures that all EBS volumes are encrypted.'
  tag compliance: ['PCI DSS 3.4', 'NIST 800-53 SC-28']
  
  aws_ebs_volumes.volume_ids.each do |volume_id|
    describe aws_ebs_volume(volume_id) do
      it { should be_encrypted }
    end
  end
end

# Check EC2 instance IAM roles
control 'aws-ec2-1' do
  impact 0.7
  title 'Ensure EC2 instances have IAM roles attached'
  desc 'This control ensures that EC2 instances have IAM roles attached instead of using access keys.'
  tag compliance: ['PCI DSS 8.2', 'NIST 800-53 AC-2(1)']
  
  aws_ec2_instances.instance_ids.each do |instance_id|
    describe aws_ec2_instance(instance_id) do
      it { should have_iam_profile }
    end
  end
end

# Check security group rules
control 'aws-sg-1' do
  impact 1.0
  title 'Ensure no security groups allow unrestricted access to high-risk ports'
  desc 'This control ensures that security groups do not allow unrestricted access to high-risk ports.'
  tag compliance: ['PCI DSS 1.2', 'NIST 800-53 CM-7']
  
  high_risk_ports = [22, 3389, 1433, 3306, 5432]
  
  aws_security_groups.group_ids.each do |security_group_id|
    high_risk_ports.each do |port|
      describe aws_security_group(security_group_id) do
        it { should_not allow_in(port: port, ipv4_range: '0.0.0.0/0') }
      end
    end
  end
end

# Check for RDS encryption
control 'aws-rds-1' do
  impact 1.0
  title 'Ensure RDS instances are encrypted'
  desc 'This control ensures that all RDS instances have encryption enabled.'
  tag compliance: ['PCI DSS 3.4', 'NIST 800-53 SC-28']
  
  aws_rds_instances.db_instance_identifiers.each do |db_instance_id|
    describe aws_rds_instance(db_instance_id) do
      it { should be_encrypted }
    end
  end
end

# Check for public RDS instances
control 'aws-rds-2' do
  impact 1.0
  title 'Ensure RDS instances are not publicly accessible'
  desc 'This control ensures that RDS instances do not allow public access.'
  tag compliance: ['PCI DSS 1.3', 'NIST 800-53 AC-3']
  
  aws_rds_instances.db_instance_identifiers.each do |db_instance_id|
    describe aws_rds_instance(db_instance_id) do
      it { should_not be_publicly_accessible }
    end
  end
end

# Check CloudTrail configuration
control 'aws-cloudtrail-1' do
  impact 1.0
  title 'Ensure CloudTrail is enabled in all regions'
  desc 'This control ensures that CloudTrail is enabled in all regions for complete audit logging.'
  tag compliance: ['PCI DSS 10.1', 'NIST 800-53 AU-2']
  
  describe aws_cloudtrail_trail_global do
    it { should exist }
    it { should be_multi_region_trail }
    it { should have_log_file_validation_enabled }
    it { should be_logging }
  end
end

# Check CloudTrail encryption
control 'aws-cloudtrail-2' do
  impact 0.7
  title 'Ensure CloudTrail logs are encrypted'
  desc 'This control ensures that CloudTrail logs are encrypted using KMS.'
  tag compliance: ['PCI DSS 3.4', 'NIST 800-53 SC-28']
  
  aws_cloudtrail_trails.trail_arns.each do |trail_arn|
    describe aws_cloudtrail_trail(trail_arn) do
      it { should have_encrypted_log_delivery }
    end
  end
end

# Check for VPC flow logs
control 'aws-vpc-1' do
  impact 0.7
  title 'Ensure VPC flow logs are enabled'
  desc 'This control ensures that VPC flow logs are enabled for network traffic monitoring.'
  tag compliance: ['PCI DSS 10.2', 'NIST 800-53 AU-2']
  
  describe aws_vpc(aws_vpc_id) do
    it { should have_flow_logs }
  end
end

# Check KMS key rotation
control 'aws-kms-1' do
  impact 0.7
  title 'Ensure KMS keys have rotation enabled'
  desc 'This control ensures that KMS keys have automatic rotation enabled.'
  tag compliance: ['PCI DSS 3.6', 'NIST 800-53 SC-12']
  
  aws_kms_keys.key_ids.each do |key_id|
    # Skip AWS managed keys as they are automatically rotated
    next if aws_kms_key(key_id).aws_managed
    
    describe aws_kms_key(key_id) do
      it { should have_rotation_enabled }
    end
  end
end

# Check for root account MFA
control 'aws-iam-1' do
  impact 1.0
  title 'Ensure root account has MFA enabled'
  desc 'This control ensures that the root account has MFA enabled for enhanced security.'
  tag compliance: ['PCI DSS 8.3', 'NIST 800-53 IA-2(1)']
  
  describe aws_iam_root_user do
    it { should have_mfa_enabled }
  end
end

# Check IAM password policy
control 'aws-iam-2' do
  impact 0.7
  title 'Ensure IAM password policy requires strong passwords'
  desc 'This control ensures that the IAM password policy enforces strong passwords.'
  tag compliance: ['PCI DSS 8.2.3', 'NIST 800-53 IA-5(1)']
  
  describe aws_iam_password_policy do
    it { should exist }
    it { should require_uppercase_characters }
    it { should require_lowercase_characters }
    it { should require_numbers }
    it { should require_symbols }
    it { should require_minimum_password_length(14) }
    it { should prevent_password_reuse(24) }
  end
end
