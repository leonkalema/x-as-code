provider "aws" {
  region = var.region
}

resource "aws_vpc" "app_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  
  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Public subnets for load balancers
resource "aws_subnet" "public" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = "10.0.${count.index}.0/24"
  availability_zone = var.availability_zones[count.index]
  
  tags = {
    Name        = "${var.environment}-public-${var.availability_zones[count.index]}"
    Environment = var.environment
    Tier        = "public"
    ManagedBy   = "terraform"
  }
}

# Private subnets for application instances
resource "aws_subnet" "application" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = "10.0.${count.index + 10}.0/24"
  availability_zone = var.availability_zones[count.index]
  
  tags = {
    Name        = "${var.environment}-application-${var.availability_zones[count.index]}"
    Environment = var.environment
    Tier        = "application"
    ManagedBy   = "terraform"
  }
}

# Private subnets for database instances
resource "aws_subnet" "database" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = "10.0.${count.index + 20}.0/24"
  availability_zone = var.availability_zones[count.index]
  
  tags = {
    Name        = "${var.environment}-database-${var.availability_zones[count.index]}"
    Environment = var.environment
    Tier        = "database"
    ManagedBy   = "terraform"
  }
}

# Security Groups

# Load Balancer Security Group
resource "aws_security_group" "load_balancer" {
  name        = "${var.environment}-lb-sg"
  description = "Security group for application load balancer"
  vpc_id      = aws_vpc.app_vpc.id
  
  # Allow HTTP and HTTPS from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP traffic from the internet"
  }
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS traffic from the internet"
  }
  
  # Allow outbound traffic only to application tier
  egress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.application.id]
    description     = "Allow traffic to application instances on port 8080"
  }
  
  tags = {
    Name        = "${var.environment}-lb-sg"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Application Tier Security Group
resource "aws_security_group" "application" {
  name        = "${var.environment}-app-sg"
  description = "Security group for application instances"
  vpc_id      = aws_vpc.app_vpc.id
  
  # Allow traffic from load balancer only
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balancer.id]
    description     = "Allow traffic from load balancer on port 8080"
  }
  
  # Allow SSH from bastion host only
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
    description     = "Allow SSH from bastion host"
  }
  
  # Allow outbound traffic to database tier
  egress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.database.id]
    description     = "Allow traffic to database instances on port 5432"
  }
  
  # Allow outbound HTTPS for package updates and API calls
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS traffic for package updates and API calls"
  }
  
  tags = {
    Name        = "${var.environment}-app-sg"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Database Tier Security Group
resource "aws_security_group" "database" {
  name        = "${var.environment}-db-sg"
  description = "Security group for database instances"
  vpc_id      = aws_vpc.app_vpc.id
  
  # Allow traffic from application tier only
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.application.id]
    description     = "Allow PostgreSQL traffic from application instances"
  }
  
  # No outbound traffic allowed by default
  
  tags = {
    Name        = "${var.environment}-db-sg"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Bastion Host Security Group
resource "aws_security_group" "bastion" {
  name        = "${var.environment}-bastion-sg"
  description = "Security group for bastion host"
  vpc_id      = aws_vpc.app_vpc.id
  
  # Allow SSH from trusted IPs only
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.trusted_ips
    description = "Allow SSH from trusted IPs"
  }
  
  # Allow outbound SSH to application tier
  egress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.application.id]
    description     = "Allow SSH to application instances"
  }
  
  # Allow outbound HTTPS for package updates
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS traffic for package updates"
  }
  
  tags = {
    Name        = "${var.environment}-bastion-sg"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Variables
variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-west-2"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., dev, staging, prod)"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones to use"
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "trusted_ips" {
  type        = list(string)
  description = "List of trusted IP addresses for bastion access"
  default     = []  # This should be set to your specific IP ranges
}

# Outputs
output "vpc_id" {
  value       = aws_vpc.app_vpc.id
  description = "ID of the created VPC"
}

output "application_security_group_id" {
  value       = aws_security_group.application.id
  description = "ID of the application tier security group"
}

output "database_security_group_id" {
  value       = aws_security_group.database.id
  description = "ID of the database tier security group"
}

output "load_balancer_security_group_id" {
  value       = aws_security_group.load_balancer.id
  description = "ID of the load balancer security group"
}
