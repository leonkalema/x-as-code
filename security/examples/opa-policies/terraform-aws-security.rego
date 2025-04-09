package terraform.aws.security

# Import the tfplan
import input as tfplan

# Deny S3 buckets without encryption
deny[reason] {
    resource := tfplan.resource_changes[_]
    resource.type == "aws_s3_bucket"
    resource.change.after.server_side_encryption_configuration == null
    
    reason := sprintf(
        "S3 bucket %q must have server-side encryption enabled",
        [resource.change.after.bucket]
    )
}

# Deny EC2 instances with exposed SSH ports
deny[reason] {
    resource := tfplan.resource_changes[_]
    resource.type == "aws_security_group"
    resource.change.after.ingress[_].from_port <= 22
    resource.change.after.ingress[_].to_port >= 22
    resource.change.after.ingress[_].cidr_blocks[_] == "0.0.0.0/0"
    
    reason := sprintf(
        "Security group %q allows SSH access from the internet (0.0.0.0/0)",
        [resource.change.after.name]
    )
}

# Deny RDS instances that are publicly accessible
deny[reason] {
    resource := tfplan.resource_changes[_]
    resource.type == "aws_db_instance"
    resource.change.after.publicly_accessible == true
    
    reason := sprintf(
        "RDS instance %q must not be publicly accessible",
        [resource.change.after.identifier]
    )
}

# Deny IAM policies with wildcards in Actions
deny[reason] {
    resource := tfplan.resource_changes[_]
    resource.type == "aws_iam_policy"
    policy_doc := json.unmarshal(resource.change.after.policy)
    statement := policy_doc.Statement[_]
    statement.Effect == "Allow"
    contains_wildcard(statement.Action)
    
    reason := sprintf(
        "IAM policy %q contains wildcard in 'Action'",
        [resource.change.after.name]
    )
}

# Helper function to check for wildcards in actions
contains_wildcard(action) {
    is_string(action)
    contains(action, "*")
}

contains_wildcard(actions) {
    is_array(actions)
    contains(actions[_], "*")
}
