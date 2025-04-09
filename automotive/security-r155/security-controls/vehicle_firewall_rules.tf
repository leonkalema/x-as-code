# Vehicle Security Controls - Firewall Rules as Infrastructure as Code
# This implements network segmentation for in-vehicle networks based on R155 requirements

provider "vehicle_security" {
  version = "~> 1.0"
  vehicle_platform = "example_platform"
  auth_token = var.auth_token
}

# Define network segments for in-vehicle network
resource "vehicle_security_segment" "infotainment_domain" {
  name        = "infotainment_domain"
  description = "Infotainment system network domain"
  priority    = 100
  tags        = ["non_critical", "external_connectivity"]
}

resource "vehicle_security_segment" "body_domain" {
  name        = "body_domain"
  description = "Body control network domain"
  priority    = 200
  tags        = ["medium_critical"]
}

resource "vehicle_security_segment" "powertrain_domain" {
  name        = "powertrain_domain"
  description = "Powertrain control network domain"
  priority    = 300
  tags        = ["safety_critical"]
}

resource "vehicle_security_segment" "adas_domain" {
  name        = "adas_domain"
  description = "Advanced Driver Assistance Systems domain"
  priority    = 400
  tags        = ["safety_critical", "autonomous"]
}

# Define firewall rules between domains
resource "vehicle_security_firewall_rule" "infotainment_to_body" {
  name             = "inf_to_body_limited"
  source_segment   = vehicle_security_segment.infotainment_domain.id
  target_segment   = vehicle_security_segment.body_domain.id
  description      = "Limited access from infotainment to body domain"
  action           = "ALLOW"
  protocol         = "CAN"
  
  allowed_message_ids = [
    "0x200", # Climate control commands
    "0x210", # Door lock status query
    "0x220"  # Lighting control commands
  ]
  
  logging_enabled   = true
  intrusion_detection_enabled = true
}

resource "vehicle_security_firewall_rule" "block_infotainment_to_powertrain" {
  name             = "block_inf_to_powertrain"
  source_segment   = vehicle_security_segment.infotainment_domain.id
  target_segment   = vehicle_security_segment.powertrain_domain.id
  description      = "Block all traffic from infotainment to powertrain"
  action           = "DENY"
  protocol         = "ALL"
  
  logging_enabled   = true
  alert_on_violation = true
  intrusion_detection_enabled = true
}

resource "vehicle_security_firewall_rule" "block_infotainment_to_adas" {
  name             = "block_inf_to_adas"
  source_segment   = vehicle_security_segment.infotainment_domain.id
  target_segment   = vehicle_security_segment.adas_domain.id
  description      = "Block all traffic from infotainment to ADAS"
  action           = "DENY"
  protocol         = "ALL"
  
  logging_enabled   = true
  alert_on_violation = true
  intrusion_detection_enabled = true
}

# Security control for monitoring and anomaly detection
resource "vehicle_security_monitor" "ids_monitor" {
  name        = "intrusion_detection_system"
  description = "Vehicle IDS to detect abnormal network patterns"
  enabled     = true
  
  monitored_segments = [
    vehicle_security_segment.infotainment_domain.id,
    vehicle_security_segment.body_domain.id,
    vehicle_security_segment.powertrain_domain.id,
    vehicle_security_segment.adas_domain.id
  ]
  
  alert_thresholds {
    message_frequency_anomaly = "medium"
    unauthorized_message_ids  = "high"
    payload_anomaly           = "medium"
    source_address_spoofing   = "high"
  }
  
  response_actions = [
    "LOG",
    "ALERT",
    "BLOCK_SOURCE"
  ]
}

# Define secure gateway configuration for external connectivity
resource "vehicle_security_gateway" "secure_gateway" {
  name        = "vehicle_secure_gateway"
  description = "Secure gateway for external communications"
  enabled     = true
  
  interfaces {
    name = "cellular"
    firewall_enabled = true
    encryption_required = true
    authentication_required = true
    dos_protection_enabled = true
  }
  
  interfaces {
    name = "bluetooth"
    firewall_enabled = true
    encryption_required = true
    authentication_required = true
    dos_protection_enabled = true
  }
  
  interfaces {
    name = "wifi"
    firewall_enabled = true
    encryption_required = true
    authentication_required = true
    dos_protection_enabled = true
  }
}

# Security control for secure boot
resource "vehicle_security_boot" "secure_boot" {
  name        = "secure_boot_process"
  description = "Secure boot configuration for ECUs"
  
  verification_keys = var.verification_public_keys
  
  ecu_configurations = [
    {
      ecu_id = "infotainment_ecu"
      verification_required = true
      fallback_allowed = false
      measurements_required = true
    },
    {
      ecu_id = "gateway_ecu"
      verification_required = true
      fallback_allowed = false
      measurements_required = true
    },
    {
      ecu_id = "body_control_ecu"
      verification_required = true
      fallback_allowed = true
      measurements_required = true
    }
  ]
}

# Output security status report
output "security_controls_status" {
  value = {
    network_segmentation = "Implemented"
    firewall_rules_count = 3
    monitored_segments   = 4
    secure_boot_ecus     = 3
  }
}
