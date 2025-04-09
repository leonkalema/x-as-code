#!/usr/bin/env python3
"""
Automotive Threat Model Generator

This script generates YAML-based threat models for automotive systems
based on component definitions and attack surface analysis.
"""

import argparse
import json
import yaml
import os
import sys
import datetime
import logging

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class ThreatModelGenerator:
    """Generate threat models for automotive systems"""
    
    def __init__(self, components_file):
        """Initialize with component definitions"""
        self.load_components(components_file)
        self.load_threat_library("threat_library.yaml")
        
    def load_components(self, components_file):
        """Load component definitions from YAML file"""
        try:
            with open(components_file, 'r') as f:
                self.components = yaml.safe_load(f)
                logger.info(f"Loaded {len(self.components.get('components', []))} components from {components_file}")
        except Exception as e:
            logger.error(f"Error loading components: {str(e)}")
            sys.exit(1)
    
    def load_threat_library(self, library_file):
        """Load threat library from YAML file"""
        try:
            if os.path.exists(library_file):
                with open(library_file, 'r') as f:
                    self.threat_library = yaml.safe_load(f)
                    logger.info(f"Loaded {len(self.threat_library.get('threats', []))} threats from library")
            else:
                logger.warning(f"Threat library file {library_file} not found, using default threats")
                self.threat_library = {"threats": []}
        except Exception as e:
            logger.error(f"Error loading threat library: {str(e)}")
            self.threat_library = {"threats": []}
    
    def generate_system_model(self, system_name, description):
        """Generate base system model structure"""
        return {
            "system": {
                "name": system_name,
                "version": "1.0",
                "description": description,
                "date_assessed": datetime.datetime.now().strftime("%Y-%m-%d")
            },
            "components": [],
            "interfaces": [],
            "attack_vectors": [],
            "threats": [],
            "security_controls": []
        }
    
    def add_components_to_model(self, model):
        """Add components to the system model"""
        for component in self.components.get("components", []):
            model["components"].append({
                "id": component.get("id"),
                "name": component.get("name"),
                "type": component.get("type"),
                "description": component.get("description"),
                "criticality": component.get("criticality", "Low")
            })
            
        logger.info(f"Added {len(model['components'])} components to model")
    
    def generate_interfaces(self, model):
        """Generate interfaces between components"""
        for connection in self.components.get("connections", []):
            interface_id = f"IF-{connection.get('source')}-{connection.get('target')}"
            model["interfaces"].append({
                "id": interface_id,
                "name": connection.get("name", f"Interface {interface_id}"),
                "source_component": connection.get("source"),
                "target_component": connection.get("target"),
                "type": connection.get("type", "data"),
                "protocol": connection.get("protocol", "Unknown"),
                "description": connection.get("description", "Component interface")
            })
            
        logger.info(f"Generated {len(model['interfaces'])} interfaces")
    
    def identify_attack_vectors(self, model):
        """Identify potential attack vectors based on components and interfaces"""
        # Find external-facing components
        external_components = [c for c in model["components"] if c.get("type") == "external_interface"]
        
        # Add attack vectors for each external component
        av_id = 1
        for component in external_components:
            model["attack_vectors"].append({
                "id": f"AV-{av_id}",
                "name": f"Attack via {component['name']}",
                "description": f"External attack through {component['name']} interface",
                "entry_point": component["id"],
                "affected_components": [component["id"]],
                "threat_types": ["spoofing", "tampering"]
            })
            av_id += 1
            
        # Add attack vectors for wireless interfaces
        wireless_interfaces = [i for i in model["interfaces"] if "wireless" in i.get("protocol", "").lower()]
        for interface in wireless_interfaces:
            model["attack_vectors"].append({
                "id": f"AV-{av_id}",
                "name": f"Wireless attack via {interface['name']}",
                "description": f"Attack through wireless interface {interface['name']}",
                "entry_point": interface["source_component"],
                "affected_components": [interface["source_component"], interface["target_component"]],
                "threat_types": ["spoofing", "denial_of_service"]
            })
            av_id += 1
            
        # Add attack vectors for physical access
        physical_components = [c for c in model["components"] if "physical" in c.get("type", "").lower()]
        for component in physical_components:
            model["attack_vectors"].append({
                "id": f"AV-{av_id}",
                "name": f"Physical access to {component['name']}",
                "description": f"Attack through physical access to {component['name']}",
                "entry_point": component["id"],
                "affected_components": [component["id"]],
                "threat_types": ["tampering", "information_disclosure"]
            })
            av_id += 1
        
        logger.info(f"Identified {len(model['attack_vectors'])} attack vectors")
    
    def map_threats_to_components(self, model):
        """Map threats to components based on threat library and attack vectors"""
        # Use threat library if available
        threat_id = 1
        
        # Apply library threats
        for lib_threat in self.threat_library.get("threats", []):
            if "component_types" in lib_threat:
                # Find matching components
                matching_components = [c for c in model["components"] 
                                    if c.get("type") in lib_threat["component_types"]]
                
                if matching_components:
                    affected_components = [c["id"] for c in matching_components]
                    
                    # Create threat from library template
                    model["threats"].append({
                        "id": f"T-{threat_id}",
                        "name": lib_threat["name"],
                        "description": lib_threat["description"],
                        "threat_type": lib_threat.get("threat_type", "Unknown"),
                        "affected_components": affected_components,
                        "attack_vectors": lib_threat.get("attack_vectors", []),
                        "impact": lib_threat.get("impact", {
                            "safety": "Unknown",
                            "privacy": "Unknown",
                            "operational": "Unknown",
                            "financial": "Unknown"
                        }),
                        "likelihood": lib_threat.get("likelihood", "Medium"),
                        "risk_level": lib_threat.get("risk_level", "Medium")
                    })
                    threat_id += 1
        
        # Generate threats based on attack vectors
        for attack_vector in model["attack_vectors"]:
            # For each threat type in the attack vector
            for threat_type in attack_vector.get("threat_types", []):
                # Find matching threat templates in library
                matching_templates = [t for t in self.threat_library.get("threats", []) 
                                   if t.get("threat_type") == threat_type]
                
                if matching_templates:
                    # Use template to create threat
                    template = matching_templates[0]
                    model["threats"].append({
                        "id": f"T-{threat_id}",
                        "name": f"{template['name']} via {attack_vector['name']}",
                        "description": template["description"],
                        "threat_type": threat_type,
                        "affected_components": attack_vector["affected_components"],
                        "attack_vectors": [attack_vector["id"]],
                        "impact": template.get("impact", {
                            "safety": "Unknown",
                            "privacy": "Unknown",
                            "operational": "Unknown",
                            "financial": "Unknown"
                        }),
                        "likelihood": template.get("likelihood", "Medium"),
                        "risk_level": template.get("risk_level", "Medium")
                    })
                else:
                    # Create generic threat
                    model["threats"].append({
                        "id": f"T-{threat_id}",
                        "name": f"{threat_type.title()} via {attack_vector['name']}",
                        "description": f"Generic {threat_type} threat through {attack_vector['description']}",
                        "threat_type": threat_type,
                        "affected_components": attack_vector["affected_components"],
                        "attack_vectors": [attack_vector["id"]],
                        "impact": {
                            "safety": "Medium" if threat_type in ["tampering", "spoofing"] else "Low",
                            "privacy": "High" if threat_type in ["information_disclosure"] else "Low",
                            "operational": "High" if threat_type in ["denial_of_service"] else "Medium",
                            "financial": "Medium"
                        },
                        "likelihood": "Medium",
                        "risk_level": "Medium"
                    })
                threat_id += 1
        
        logger.info(f"Mapped {len(model['threats'])} threats to components")
    
    def suggest_security_controls(self, model):
        """Suggest security controls based on identified threats"""
        # Map of threat types to generic security controls
        control_mappings = {
            "spoofing": [
                {
                    "name": "Strong Authentication",
                    "description": "Implement strong authentication mechanisms",
                    "type": "preventive"
                },
                {
                    "name": "Message Authentication",
                    "description": "Implement message authentication codes (MACs)",
                    "type": "preventive"
                }
            ],
            "tampering": [
                {
                    "name": "Integrity Protection",
                    "description": "Implement integrity protection mechanisms",
                    "type": "preventive"
                },
                {
                    "name": "Secure Boot",
                    "description": "Implement secure boot process",
                    "type": "preventive"
                }
            ],
            "information_disclosure": [
                {
                    "name": "Encryption",
                    "description": "Encrypt sensitive data in transit and at rest",
                    "type": "preventive"
                },
                {
                    "name": "Access Control",
                    "description": "Implement strict access controls",
                    "type": "preventive"
                }
            ],
            "denial_of_service": [
                {
                    "name": "Rate Limiting",
                    "description": "Implement rate limiting mechanisms",
                    "type": "preventive"
                },
                {
                    "name": "Redundancy",
                    "description": "Implement redundant systems or components",
                    "type": "mitigative"
                }
            ],
            "elevation_of_privilege": [
                {
                    "name": "Privilege Separation",
                    "description": "Implement privilege separation mechanisms",
                    "type": "preventive"
                },
                {
                    "name": "Least Privilege",
                    "description": "Apply principle of least privilege",
                    "type": "preventive"
                }
            ]
        }
        
        # Collect unique threat types
        threat_types = set()
        for threat in model["threats"]:
            threat_types.add(threat.get("threat_type", "Unknown"))
        
        # Add controls for each threat type
        control_id = 1
        added_controls = set()
        
        for threat_type in threat_types:
            if threat_type in control_mappings:
                for control_template in control_mappings[threat_type]:
                    control_name = control_template["name"]
                    
                    # Skip if already added
                    if control_name in added_controls:
                        continue
                        
                    added_controls.add(control_name)
                    
                    # Find threats mitigated by this control
                    mitigated_threats = [t["id"] for t in model["threats"]
                                      if t.get("threat_type") == threat_type]
                    
                    # Add control
                    model["security_controls"].append({
                        "id": f"SC-{control_id}",
                        "name": control_name,
                        "description": control_template["description"],
                        "type": control_template["type"],
                        "mitigated_threats": mitigated_threats,
                        "implementation_status": "Recommended"
                    })
                    control_id += 1
        
        logger.info(f"Suggested {len(model['security_controls'])} security controls")
    
    def generate_model(self, system_name, description, output_file):
        """Generate complete threat model"""
        model = self.generate_system_model(system_name, description)
        
        # Build the model
        self.add_components_to_model(model)
        self.generate_interfaces(model)
        self.identify_attack_vectors(model)
        self.map_threats_to_components(model)
        self.suggest_security_controls(model)
        
        # Write to file
        try:
            with open(output_file, 'w') as f:
                yaml.dump(model, f, default_flow_style=False, sort_keys=False)
            logger.info(f"Threat model written to {output_file}")
        except Exception as e:
            logger.error(f"Error writing threat model: {str(e)}")
            return None
            
        return model
        
def main():
    """Main entry point"""
    parser = argparse.ArgumentParser(description='Automotive Threat Model Generator')
    
    parser.add_argument('--components', required=True, help='Path to components definition file')
    parser.add_argument('--system-name', default='Automotive System', help='Name of the system')
    parser.add_argument('--description', default='Automotive system threat model', help='System description')
    parser.add_argument('--output', default='automotive_threat_model.yaml', help='Output file path')
    
    args = parser.parse_args()
    
    # Generate threat model
    generator = ThreatModelGenerator(args.components)
    generator.generate_model(args.system_name, args.description, args.output)

if __name__ == '__main__':
    main()
