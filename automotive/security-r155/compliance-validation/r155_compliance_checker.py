#!/usr/bin/env python3
"""
R155 Compliance Checker

This script automatically scans vehicle systems, configurations, and documentation
to validate compliance with UN Regulation No. 155 requirements.
"""

import argparse
import json
import yaml
import csv
import os
import sys
import logging
import datetime
import requests
from pathlib import Path

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# Define R155 requirements structure
R155_REQUIREMENTS = {
    "7.2.1": {
        "id": "7.2.1",
        "title": "Cybersecurity Management System",
        "description": "The manufacturer shall demonstrate that their CSMS covers the following aspects:",
        "sub_requirements": {
            "7.2.1.1": "Processes for managing vehicle cybersecurity",
            "7.2.1.2": "Processes for identifying risks to vehicle systems",
            "7.2.1.3": "Processes for assessing and categorizing risks",
            "7.2.1.4": "Processes for testing the security of vehicle systems",
            "7.2.1.5": "Processes for ensuring security is integrated into vehicle design",
            "7.2.1.6": "Processes for verifying that risk management is appropriately implemented",
            "7.2.1.7": "Processes for monitoring, detecting, and responding to attacks",
            "7.2.1.8": "Processes for providing data to enable analysis of attempted/successful attacks"
        }
    },
    "7.2.2": {
        "id": "7.2.2",
        "title": "Vehicle Type Requirements",
        "description": "The manufacturer shall demonstrate specific measures in the vehicle type:",
        "sub_requirements": {
            "7.2.2.1": "Vehicle types shall be protected against risks identified in the risk assessment",
            "7.2.2.2": "Security controls used are proportionate to assessed risks",
            "7.2.2.3": "The vehicle manufacturer shall protect critical elements of the vehicle type",
            "7.2.2.4": "The vehicle manufacturer shall implement measures to detect and prevent cyber attacks",
            "7.2.2.5": "The vehicle manufacturer shall implement measures to support vehicle data analysis"
        }
    },
    "7.3": {
        "id": "7.3",
        "title": "Point of Contact with Authorities",
        "description": "The vehicle manufacturer shall provide the following information:",
        "sub_requirements": {
            "7.3.1": "Contact data for responsible person(s) for cybersecurity"
        }
    },
    "7.4": {
        "id": "7.4",
        "title": "Security Updates",
        "description": "The vehicle manufacturer shall demonstrate:",
        "sub_requirements": {
            "7.4.1": "The capability to perform secure updates",
            "7.4.2": "A process to timely remediate vulnerabilities",
            "7.4.3": "Capability to identify target vehicles for updates",
            "7.4.4": "Confirmation of update execution on target vehicles"
        }
    }
}

class R155ComplianceChecker:
    """Main class for checking R155 compliance"""
    
    def __init__(self, config_path):
        """Initialize with configuration"""
        self.load_config(config_path)
        self.results = {
            "metadata": {
                "assessment_date": datetime.datetime.now().isoformat(),
                "assessor": self.config.get("assessor", "Automated Tool"),
                "vehicle_type": self.config.get("vehicle_type", "Unknown"),
                "r155_version": self.config.get("r155_version", "Original")
            },
            "requirements": {},
            "summary": {
                "total": 0,
                "compliant": 0,
                "non_compliant": 0,
                "partially_compliant": 0,
                "not_applicable": 0,
                "compliance_percentage": 0
            }
        }
        
    def load_config(self, config_path):
        """Load configuration from YAML file"""
        try:
            with open(config_path, 'r') as f:
                self.config = yaml.safe_load(f)
                logger.info(f"Configuration loaded from {config_path}")
        except Exception as e:
            logger.error(f"Error loading configuration: {str(e)}")
            sys.exit(1)
            
    def check_compliance(self):
        """Run all compliance checks"""
        logger.info("Starting R155 compliance assessment")
        
        # Check all main requirements
        for req_id, requirement in R155_REQUIREMENTS.items():
            self.check_requirement(req_id, requirement)
            
        # Calculate summary stats
        total = sum(1 for _, result in self.results["requirements"].items() 
                    if result["status"] != "not_applicable")
        
        compliant = sum(1 for _, result in self.results["requirements"].items() 
                         if result["status"] == "compliant")
        
        non_compliant = sum(1 for _, result in self.results["requirements"].items() 
                             if result["status"] == "non_compliant")
        
        partially = sum(1 for _, result in self.results["requirements"].items() 
                         if result["status"] == "partially_compliant")
        
        not_applicable = sum(1 for _, result in self.results["requirements"].items() 
                              if result["status"] == "not_applicable")
        
        compliance_percentage = (compliant / total * 100) if total > 0 else 0
        
        self.results["summary"] = {
            "total": total,
            "compliant": compliant,
            "non_compliant": non_compliant,
            "partially_compliant": partially,
            "not_applicable": not_applicable,
            "compliance_percentage": round(compliance_percentage, 2)
        }
        
        logger.info(f"Compliance assessment completed. Overall compliance: {compliance_percentage:.2f}%")
        
    def check_requirement(self, req_id, requirement):
        """Check a specific requirement and its sub-requirements"""
        logger.info(f"Checking requirement {req_id}: {requirement['title']}")
        
        # Initialize result for this requirement
        self.results["requirements"][req_id] = {
            "id": req_id,
            "title": requirement["title"],
            "description": requirement["description"],
            "status": "not_assessed",
            "sub_requirements": {},
            "evidence": [],
            "findings": []
        }
        
        # Check each sub-requirement
        compliant_count = 0
        total_count = len(requirement["sub_requirements"])
        
        for sub_id, sub_description in requirement["sub_requirements"].items():
            result = self.check_sub_requirement(sub_id, sub_description)
            self.results["requirements"][req_id]["sub_requirements"][sub_id] = result
            
            if result["status"] == "compliant":
                compliant_count += 1
                
        # Determine overall status for this requirement
        if compliant_count == 0:
            status = "non_compliant"
        elif compliant_count == total_count:
            status = "compliant"
        else:
            status = "partially_compliant"
            
        # Check if this requirement is marked as not applicable in config
        if req_id in self.config.get("not_applicable_requirements", []):
            status = "not_applicable"
            
        self.results["requirements"][req_id]["status"] = status
        logger.info(f"Requirement {req_id} status: {status}")
        
    def check_sub_requirement(self, sub_id, description):
        """Check a specific sub-requirement"""
        logger.info(f"Checking sub-requirement {sub_id}")
        
        # Initialize result structure
        result = {
            "id": sub_id,
            "description": description,
            "status": "non_compliant",  # Default to non-compliant
            "evidence": [],
            "findings": []
        }
        
        # Determine check method based on the requirement ID
        checker_method = f"check_{sub_id.replace('.', '_')}"
        if hasattr(self, checker_method):
            try:
                # Call specific checker method
                checker = getattr(self, checker_method)
                check_result = checker()
                
                # Update result with checker findings
                result.update(check_result)
                
            except Exception as e:
                logger.error(f"Error checking {sub_id}: {str(e)}")
                result["findings"].append(f"Error during check: {str(e)}")
        else:
            # Use generic checker if specific method doesn't exist
            result = self.generic_check(sub_id, description)
            
        return result
    
    def generic_check(self, sub_id, description):
        """Generic check method for requirements without specific checkers"""
        logger.info(f"Using generic check for {sub_id}")
        
        result = {
            "id": sub_id,
            "description": description,
            "status": "non_compliant",
            "evidence": [],
            "findings": ["No specific check implemented for this requirement"]
        }
        
        # Check if evidence files exist for this requirement
        evidence_pattern = f"{sub_id.replace('.', '_')}_*"
        evidence_dir = self.config.get("evidence_directory", "evidence")
        
        evidence_files = []
        if os.path.exists(evidence_dir):
            for file in os.listdir(evidence_dir):
                if file.startswith(sub_id.replace('.', '_')):
                    evidence_files.append(os.path.join(evidence_dir, file))
        
        if evidence_files:
            result["status"] = "compliant"
            result["evidence"] = evidence_files
            result["findings"] = [f"Found {len(evidence_files)} evidence files for this requirement"]
        
        # Check compliance matrix if it exists
        matrix_path = self.config.get("compliance_matrix", "")
        if matrix_path and os.path.exists(matrix_path):
            try:
                with open(matrix_path, 'r') as f:
                    if matrix_path.endswith('.csv'):
                        reader = csv.DictReader(f)
                        for row in reader:
                            if row.get('Requirement ID') == sub_id and row.get('Status') == 'Compliant':
                                result["status"] = "compliant"
                                result["evidence"].append(matrix_path)
                                result["findings"] = [f"Compliance confirmed in matrix: {row.get('Evidence', 'No details')}"]
                    elif matrix_path.endswith(('.yaml', '.yml')):
                        matrix = yaml.safe_load(f)
                        for item in matrix.get('requirements', []):
                            if item.get('id') == sub_id and item.get('status') == 'compliant':
                                result["status"] = "compliant"
                                result["evidence"].append(matrix_path)
                                result["findings"] = [f"Compliance confirmed in matrix: {item.get('evidence', 'No details')}"]
            except Exception as e:
                logger.error(f"Error reading compliance matrix: {str(e)}")
        
        return result
    
    # Specific check methods for sub-requirements
    # These would be implemented based on the specific R155 requirements
    # Example implementation for checking CSMS documentation
    def check_7_2_1_1(self):
        """Check processes for managing vehicle cybersecurity"""
        result = {
            "id": "7.2.1.1",
            "description": "Processes for managing vehicle cybersecurity",
            "status": "non_compliant",
            "evidence": [],
            "findings": []
        }
        
        # Check for CSMS documentation
        csms_doc_path = self.config.get("csms_documentation", "")
        if csms_doc_path and os.path.exists(csms_doc_path):
            result["evidence"].append(csms_doc_path)
            
            # Check content of CSMS document
            try:
                with open(csms_doc_path, 'r') as f:
                    content = f.read().lower()
                    if "cybersecurity management" in content and "process" in content:
                        result["status"] = "compliant"
                        result["findings"].append("CSMS documentation exists and contains relevant content")
                    else:
                        result["findings"].append("CSMS documentation exists but may not cover required processes")
            except Exception as e:
                result["findings"].append(f"Error reading CSMS document: {str(e)}")
        else:
            result["findings"].append("CSMS documentation not found")
            
        return result
    
    def check_7_2_1_2(self):
        """Check processes for identifying risks to vehicle systems"""
        result = {
            "id": "7.2.1.2",
            "description": "Processes for identifying risks to vehicle systems",
            "status": "non_compliant",
            "evidence": [],
            "findings": []
        }
        
        # Check for threat models
        threat_models_dir = self.config.get("threat_models_directory", "")
        if threat_models_dir and os.path.exists(threat_models_dir):
            threat_models = [os.path.join(threat_models_dir, f) for f in os.listdir(threat_models_dir) 
                           if f.endswith(('.yaml', '.yml', '.json'))]
            
            if threat_models:
                result["evidence"].extend(threat_models)
                result["status"] = "compliant"
                result["findings"].append(f"Found {len(threat_models)} threat model files")
                
                # Check content of first threat model
                try:
                    with open(threat_models[0], 'r') as f:
                        if threat_models[0].endswith(('.yaml', '.yml')):
                            model = yaml.safe_load(f)
                        else:
                            model = json.load(f)
                            
                        if 'threats' in model and len(model['threats']) > 0:
                            result["findings"].append(f"Threat model contains {len(model['threats'])} identified threats")
                        else:
                            result["findings"].append("Threat model structure may not contain identified threats")
                except Exception as e:
                    result["findings"].append(f"Error analyzing threat model: {str(e)}")
            else:
                result["findings"].append("No threat model files found in specified directory")
        else:
            result["findings"].append("Threat models directory not found")
            
        return result
    
    # Example implementation for security update capability
    def check_7_4_1(self):
        """Check capability to perform secure updates"""
        result = {
            "id": "7.4.1",
            "description": "The capability to perform secure updates",
            "status": "non_compliant",
            "evidence": [],
            "findings": []
        }
        
        # Check for OTA update system documentation
        ota_doc_path = self.config.get("ota_documentation", "")
        if ota_doc_path and os.path.exists(ota_doc_path):
            result["evidence"].append(ota_doc_path)
            
            # Check for update system security requirements
            try:
                with open(ota_doc_path, 'r') as f:
                    content = f.read().lower()
                    security_features = []
                    
                    if "encryption" in content or "encrypted" in content:
                        security_features.append("encryption")
                    
                    if "signature" in content or "signing" in content:
                        security_features.append("code signing")
                        
                    if "authentication" in content or "authenticated" in content:
                        security_features.append("authentication")
                        
                    if "integrity" in content or "verification" in content:
                        security_features.append("integrity verification")
                    
                    if len(security_features) >= 3:  # Requiring at least 3 security features
                        result["status"] = "compliant"
                        result["findings"].append(f"Update system implements security features: {', '.join(security_features)}")
                    elif len(security_features) > 0:
                        result["status"] = "partially_compliant"
                        result["findings"].append(f"Update system implements some security features: {', '.join(security_features)}")
                    else:
                        result["findings"].append("Update system documentation does not clearly specify security features")
            except Exception as e:
                result["findings"].append(f"Error reading OTA documentation: {str(e)}")
        else:
            result["findings"].append("OTA update system documentation not found")
            
        # Check for OTA update system code/configuration
        ota_code_path = self.config.get("ota_system_path", "")
        if ota_code_path and os.path.exists(ota_code_path):
            result["evidence"].append(ota_code_path)
            result["findings"].append("OTA update system code/configuration exists")
            
        return result
    
    def generate_report(self, output_format='json', output_path=None):
        """Generate a compliance report in the specified format"""
        logger.info(f"Generating {output_format} report")
        
        if output_format == 'json':
            report = json.dumps(self.results, indent=2)
            
        elif output_format == 'yaml':
            report = yaml.dump(self.results, default_flow_style=False)
            
        elif output_format == 'html':
            # Simple HTML template for report
            report = f"""<!DOCTYPE html>
<html>
<head>
    <title>R155 Compliance Report - {self.results['metadata']['vehicle_type']}</title>
    <style>
        body {{ font-family: Arial, sans-serif; margin: 20px; }}
        .compliant {{ background-color: #d4edda; }}
        .non-compliant {{ background-color: #f8d7da; }}
        .partially-compliant {{ background-color: #fff3cd; }}
        .not-applicable {{ background-color: #e2e3e5; }}
        table {{ border-collapse: collapse; width: 100%; }}
        th, td {{ border: 1px solid #ddd; padding: 8px; }}
        th {{ background-color: #f2f2f2; }}
    </style>
</head>
<body>
    <h1>R155 Compliance Report</h1>
    <h2>{self.results['metadata']['vehicle_type']}</h2>
    <p>Assessment Date: {self.results['metadata']['assessment_date']}</p>
    <p>Assessor: {self.results['metadata']['assessor']}</p>
    
    <h3>Compliance Summary</h3>
    <table>
        <tr>
            <th>Overall Compliance</th>
            <td>{self.results['summary']['compliance_percentage']}%</td>
        </tr>
        <tr>
            <th>Total Requirements</th>
            <td>{self.results['summary']['total']}</td>
        </tr>
        <tr>
            <th>Compliant</th>
            <td>{self.results['summary']['compliant']}</td>
        </tr>
        <tr>
            <th>Partially Compliant</th>
            <td>{self.results['summary']['partially_compliant']}</td>
        </tr>
        <tr>
            <th>Non-Compliant</th>
            <td>{self.results['summary']['non_compliant']}</td>
        </tr>
        <tr>
            <th>Not Applicable</th>
            <td>{self.results['summary']['not_applicable']}</td>
        </tr>
    </table>
    
    <h3>Detailed Results</h3>
"""
            
            # Add each requirement
            for req_id, req in self.results['requirements'].items():
                status_class = req['status'].replace('_', '-')
                report += f"""
    <div class="requirement {status_class}">
        <h4>{req['id']} - {req['title']}</h4>
        <p>{req['description']}</p>
        <p>Status: <strong>{req['status'].upper()}</strong></p>
        
        <h5>Sub-Requirements</h5>
        <table>
            <tr>
                <th>ID</th>
                <th>Description</th>
                <th>Status</th>
                <th>Findings</th>
            </tr>
"""
                
                # Add each sub-requirement
                for sub_id, sub in req['sub_requirements'].items():
                    sub_status_class = sub['status'].replace('_', '-')
                    findings = "<br>".join(sub['findings']) if sub['findings'] else "No findings"
                    report += f"""
            <tr class="{sub_status_class}">
                <td>{sub['id']}</td>
                <td>{sub['description']}</td>
                <td>{sub['status'].upper()}</td>
                <td>{findings}</td>
            </tr>
"""
                
                report += """
        </table>
    </div>
"""
            
            report += """
</body>
</html>
"""
        else:
            logger.error(f"Unsupported output format: {output_format}")
            return None
        
        # Write to file if path is provided
        if output_path:
            try:
                with open(output_path, 'w') as f:
                    f.write(report)
                logger.info(f"Report saved to {output_path}")
            except Exception as e:
                logger.error(f"Error writing report to {output_path}: {str(e)}")
        
        return report

def main():
    """Main entry point"""
    parser = argparse.ArgumentParser(description='R155 Compliance Checker')
    
    parser.add_argument('--config', required=True, help='Path to configuration file')
    parser.add_argument('--output', help='Path to output report file')
    parser.add_argument('--format', choices=['json', 'yaml', 'html'], default='json',
                      help='Output format (default: json)')
    
    args = parser.parse_args()
    
    # Run compliance check
    checker = R155ComplianceChecker(args.config)
    checker.check_compliance()
    
    # Generate report
    output_path = args.output if args.output else f"r155_compliance_report.{args.format}"
    checker.generate_report(args.format, output_path)
    
    logger.info("Compliance check completed")

if __name__ == '__main__':
    main()
