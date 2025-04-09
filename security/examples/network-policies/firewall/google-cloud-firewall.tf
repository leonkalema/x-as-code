provider "google" {
  project = var.project_id
  region  = var.region
}

# VPC Network
resource "google_compute_network" "vpc_network" {
  name                    = "${var.environment}-vpc"
  auto_create_subnetworks = false
  description             = "VPC Network for ${var.environment} environment"
}

# Subnets
resource "google_compute_subnetwork" "public_subnet" {
  name          = "${var.environment}-public-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.id
  
  # Enable flow logs for network security monitoring
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "private_subnet" {
  name          = "${var.environment}-private-subnet"
  ip_cidr_range = "10.0.2.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.id
  
  # Enable flow logs for network security monitoring
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  
  # Use private Google access to reach Google APIs without internet
  private_ip_google_access = true
}

# Default deny all ingress traffic
resource "google_compute_firewall" "deny_all_ingress" {
  name        = "${var.environment}-fw-deny-all-ingress"
  network     = google_compute_network.vpc_network.id
  description = "Deny all ingress traffic by default"
  
  priority    = 65534  # Just above the implicit allow egress rule (65535)
  
  direction   = "INGRESS"
  
  deny {
    protocol = "all"
  }
  
  source_ranges = ["0.0.0.0/0"]
}

# Default deny all egress traffic
resource "google_compute_firewall" "deny_all_egress" {
  name        = "${var.environment}-fw-deny-all-egress"
  network     = google_compute_network.vpc_network.id
  description = "Deny all egress traffic by default"
  
  priority    = 65534  # Just above the implicit allow egress rule (65535)
  
  direction   = "EGRESS"
  
  deny {
    protocol = "all"
  }
  
  destination_ranges = ["0.0.0.0/0"]
}

# Allow HTTP/HTTPS ingress to web servers
resource "google_compute_firewall" "allow_web" {
  name        = "${var.environment}-fw-allow-web"
  network     = google_compute_network.vpc_network.id
  description = "Allow HTTP and HTTPS traffic to web servers"
  
  priority    = 1000
  
  direction   = "INGRESS"
  
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
  
  source_ranges = ["0.0.0.0/0"]
  
  target_tags = ["web-server"]
  
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# Allow SSH only from specific admin IP ranges
resource "google_compute_firewall" "allow_ssh" {
  name        = "${var.environment}-fw-allow-ssh"
  network     = google_compute_network.vpc_network.id
  description = "Allow SSH only from authorized admin IPs"
  
  priority    = 1000
  
  direction   = "INGRESS"
  
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  
  source_ranges = var.admin_ip_ranges
  
  target_tags = ["ssh-allowed"]
  
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# Allow internal traffic between web and application servers
resource "google_compute_firewall" "allow_web_to_app" {
  name        = "${var.environment}-fw-allow-web-to-app"
  network     = google_compute_network.vpc_network.id
  description = "Allow traffic from web servers to app servers"
  
  priority    = 1000
  
  direction   = "INGRESS"
  
  allow {
    protocol = "tcp"
    ports    = ["8080", "8443"]
  }
  
  source_tags = ["web-server"]
  target_tags = ["app-server"]
  
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# Allow internal traffic between application servers and database
resource "google_compute_firewall" "allow_app_to_db" {
  name        = "${var.environment}-fw-allow-app-to-db"
  network     = google_compute_network.vpc_network.id
  description = "Allow traffic from app servers to database"
  
  priority    = 1000
  
  direction   = "INGRESS"
  
  allow {
    protocol = "tcp"
    ports    = ["5432"]  # PostgreSQL
  }
  
  source_tags = ["app-server"]
  target_tags = ["db-server"]
  
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# Allow outbound internet access for web servers for updates
resource "google_compute_firewall" "allow_web_outbound" {
  name        = "${var.environment}-fw-allow-web-outbound"
  network     = google_compute_network.vpc_network.id
  description = "Allow outbound traffic for web servers"
  
  priority    = 1000
  
  direction   = "EGRESS"
  
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
  
  target_tags = ["web-server"]
  destination_ranges = ["0.0.0.0/0"]
}

# Allow outbound internet access for app servers for updates only
resource "google_compute_firewall" "allow_app_outbound" {
  name        = "${var.environment}-fw-allow-app-outbound"
  network     = google_compute_network.vpc_network.id
  description = "Allow limited outbound traffic for app servers"
  
  priority    = 1000
  
  direction   = "EGRESS"
  
  allow {
    protocol = "tcp"
    ports    = ["443"]  # HTTPS only
  }
  
  target_tags = ["app-server"]
  destination_ranges = ["0.0.0.0/0"]
}

# Allow access to Google APIs through Private Google Access
resource "google_compute_firewall" "allow_google_apis" {
  name        = "${var.environment}-fw-allow-google-apis"
  network     = google_compute_network.vpc_network.id
  description = "Allow access to Google APIs through Private Google Access"
  
  priority    = 900
  
  direction   = "EGRESS"
  
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
  
  # Target all instances in the private subnet
  target_tags = ["app-server", "db-server"]
  
  # Google API IP ranges
  destination_ranges = ["199.36.153.8/30", "199.36.153.4/30", "199.36.153.1/32"]
}

# Variables
variable "project_id" {
  type        = string
  description = "Google Cloud Project ID"
}

variable "region" {
  type        = string
  description = "Google Cloud region"
  default     = "us-central1"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., dev, staging, prod)"
}

variable "admin_ip_ranges" {
  type        = list(string)
  description = "List of trusted IP ranges for administration"
  default     = []  # This should be set to your specific admin IP ranges
}

# Outputs
output "vpc_network_id" {
  value       = google_compute_network.vpc_network.id
  description = "ID of the created VPC network"
}

output "public_subnet_id" {
  value       = google_compute_subnetwork.public_subnet.id
  description = "ID of the public subnet"
}

output "private_subnet_id" {
  value       = google_compute_subnetwork.private_subnet.id
  description = "ID of the private subnet"
}
