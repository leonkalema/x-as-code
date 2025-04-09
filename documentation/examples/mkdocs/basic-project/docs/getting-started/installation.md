# Installation

This guide covers how to install the necessary tools for working with the X-as-Code examples.

## Prerequisites

Before starting, ensure you have the following installed:

- Git
- A code editor (VS Code, IntelliJ, etc.)
- Docker (for running examples locally)

## Clone the Repository

```bash
git clone https://github.com/yourusername/x-as-code.git
cd x-as-code
```

## Domain-Specific Tools

Depending on which domains you're interested in, you'll need to install different tools.

### Infrastructure as Code

```bash
# Terraform
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform

# Pulumi
curl -fsSL https://get.pulumi.com | sh
```

### Policy as Code

```bash
# Open Policy Agent
curl -L -o opa https://openpolicyagent.org/downloads/latest/opa_linux_amd64
chmod 755 opa
sudo mv opa /usr/local/bin/opa
```

### Configuration as Code

```bash
# Ansible
sudo apt update
sudo apt install ansible
```

### Security as Code

```bash
# TFSec
brew install tfsec  # on macOS
# or
curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash  # on Linux
```

## Verifying Installation

You can verify that tools are installed correctly:

```bash
terraform version
pulumi version
opa version
ansible --version
tfsec --version
```

## Next Steps

Once you have the necessary tools installed, proceed to the [Quick Start](quick-start.md) guide to begin working with X-as-Code examples.
