#!/usr/bin/env python3
"""
R155 Compliance Documentation Generator

This script automatically generates documentation required for UN R155 compliance
by extracting data from various sources and compiling them into structured documents.
"""

import argparse
import yaml
import json
import os
import datetime
import logging
from jinja2 import Environment, FileSystemLoader

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# R155 document templates
TEMPLATES = {
    'csms': 'templates/csms_document.md.j2',
    'risk_assessment': 'templates/risk_assessment.md.j2',
    'security_controls': 'templates/security_controls.md.j2',
    'incident_response': 'templates/incident_response.md.j2',
    'verification_validation': 'templates/verification_validation.md.j2',
}

# Document metadata
DOCUMENT_META = {
    'company': 'Automotive Company XYZ',
    'vehicle_type': 'Example EV Platform',
    'document_version': '1.0',
    'date_generated': datetime.datetime.now().strftime('%Y-%m-%d'),
    'confidentiality': 'Confidential',
    'r155_version': 'UNECE R155 Rev 1',
}

def load_data_sources(args):
    """Load data from various security artifact sources"""
    data = {
        'meta': DOCUMENT_META,
        'threats': [],
        'controls': [],
        'verification': [],
        'incidents': [],
    }
    
    # Load threat models
    try:
        logger.info("Loading threat models from %s", args.threat_models_dir)
        for filename in os.listdir(args.threat_models_dir):
            if filename.endswith('.yaml') or filename.endswith('.yml'):
                with open(os.path.join(args.threat_models_dir, filename), 'r') as f:
                    threat_model = yaml.safe_load(f)
                    data['threats'].extend(threat_model.get('threats', []))
    except Exception as e:
        logger.error("Error loading threat models: %s", str(e))
    
    # Load security controls
    try:
        logger.info("Loading security controls from %s", args.controls_dir)
        if os.path.exists(os.path.join(args.controls_dir, 'controls.json')):
            with open(os.path.join(args.controls_dir, 'controls.json'), 'r') as f:
                data['controls'] = json.load(f)
    except Exception as e:
        logger.error("Error loading security controls: %s", str(e))
    
    # Load verification results
    try:
        logger.info("Loading verification results from %s", args.verification_dir)
        for filename in os.listdir(args.verification_dir):
            if filename.endswith('.json'):
                with open(os.path.join(args.verification_dir, filename), 'r') as f:
                    verification = json.load(f)
                    data['verification'].append(verification)
    except Exception as e:
        logger.error("Error loading verification results: %s", str(e))
    
    # Load incident response plans
    try:
        logger.info("Loading incident response from %s", args.incident_dir)
        if os.path.exists(os.path.join(args.incident_dir, 'incident_response_plan.yaml')):
            with open(os.path.join(args.incident_dir, 'incident_response_plan.yaml'), 'r') as f:
                data['incidents'] = yaml.safe_load(f)
    except Exception as e:
        logger.error("Error loading incident response plan: %s", str(e))
    
    return data

def generate_documentation(data, output_dir, templates_dir):
    """Generate all required documentation using templates"""
    env = Environment(loader=FileSystemLoader(templates_dir))
    
    # Ensure output directory exists
    os.makedirs(output_dir, exist_ok=True)
    
    # Generate each document type
    for doc_type, template_path in TEMPLATES.items():
        try:
            template = env.get_template(os.path.basename(template_path))
            output_path = os.path.join(output_dir, f"r155_{doc_type}_document.md")
            
            with open(output_path, 'w') as f:
                f.write(template.render(data=data))
                
            logger.info("Generated %s document: %s", doc_type, output_path)
            
            # Also generate PDF if pandoc is available
            try:
                pdf_output = os.path.join(output_dir, f"r155_{doc_type}_document.pdf")
                os.system(f"pandoc {output_path} -o {pdf_output} --toc --variable documentclass=report")
                logger.info("Generated PDF: %s", pdf_output)
            except Exception as e:
                logger.warning("Could not generate PDF (is pandoc installed?): %s", str(e))
                
        except Exception as e:
            logger.error("Error generating %s document: %s", doc_type, str(e))
    
    # Generate compliance matrix
    try:
        compliance_matrix = {
            'meta': data['meta'],
            'compliance_points': [],
        }
        
        # Map R155 requirements to collected evidence
        r155_reqs = load_r155_requirements(os.path.join(templates_dir, 'r155_requirements.yaml'))
        
        for req in r155_reqs:
            evidence = find_evidence_for_requirement(req['id'], data)
            compliance_matrix['compliance_points'].append({
                'requirement': req,
                'evidence': evidence,
                'status': 'Compliant' if evidence else 'Non-compliant',
            })
        
        # Write compliance matrix
        matrix_template = env.get_template('compliance_matrix.md.j2')
        matrix_path = os.path.join(output_dir, "r155_compliance_matrix.md")
        
        with open(matrix_path, 'w') as f:
            f.write(matrix_template.render(data=compliance_matrix))
            
        logger.info("Generated compliance matrix: %s", matrix_path)
        
    except Exception as e:
        logger.error("Error generating compliance matrix: %s", str(e))
    
    # Generate executive summary
    try:
        summary_template = env.get_template('executive_summary.md.j2')
        summary_path = os.path.join(output_dir, "r155_executive_summary.md")
        
        with open(summary_path, 'w') as f:
            f.write(summary_template.render(data=data))
            
        logger.info("Generated executive summary: %s", summary_path)
        
    except Exception as e:
        logger.error("Error generating executive summary: %s", str(e))

def load_r155_requirements(requirements_path):
    """Load R155 requirements definition"""
    if os.path.exists(requirements_path):
        with open(requirements_path, 'r') as f:
            return yaml.safe_load(f)
    else:
        logger.warning("R155 requirements definition not found: %s", requirements_path)
        return []

def find_evidence_for_requirement(req_id, data):
    """Find evidence for a specific R155 requirement in collected data"""
    evidence = []
    
    # Check controls
    for control in data['controls']:
        if req_id in control.get('requirements', []):
            evidence.append({
                'type': 'control',
                'id': control.get('id'),
                'name': control.get('name'),
                'description': control.get('description'),
            })
    
    # Check verification results
    for verify in data['verification']:
        if req_id in verify.get('requirements', []):
            evidence.append({
                'type': 'verification',
                'id': verify.get('id'),
                'name': verify.get('name'),
                'result': verify.get('result'),
            })
    
    return evidence

def main():
    """Main entry point"""
    parser = argparse.ArgumentParser(description='Generate R155 Compliance Documentation')
    
    parser.add_argument('--threat-models-dir', default='../threat-models',
                        help='Directory containing threat models')
    parser.add_argument('--controls-dir', default='../security-controls',
                        help='Directory containing security controls')
    parser.add_argument('--verification-dir', default='../compliance-validation/results',
                        help='Directory containing verification results')
    parser.add_argument('--incident-dir', default='../incident-response',
                        help='Directory containing incident response plans')
    parser.add_argument('--templates-dir', default='./templates',
                        help='Directory containing documentation templates')
    parser.add_argument('--output-dir', default='./output',
                        help='Directory to output generated documentation')
    
    args = parser.parse_args()
    
    logger.info("Starting R155 documentation generation")
    data = load_data_sources(args)
    generate_documentation(data, args.output_dir, args.templates_dir)
    logger.info("Documentation generation complete")

if __name__ == '__main__':
    main()
