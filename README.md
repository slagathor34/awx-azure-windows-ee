# AWX Azure + Windows Execution Environment

This repository contains the configuration files to build an AWX Execution Environment with full support for Azure Resource Manager (azure_rm) modules and Windows automation via WinRM and CredSSP.

## Files Included

- `Dockerfile` - Traditional Docker build file
- `execution-environment.yml` - Modern ansible-builder configuration
- `requirements.txt` - Python dependencies including Azure SDK and Windows WinRM packages
- `requirements.yml` - Ansible Galaxy collections including Windows collections
- `bindep.txt` - System dependencies including XML and Kerberos libraries
- `build.sh` - Build script for the execution environment

## Features

This execution environment includes:

**Azure Support:**
- **Azure Collections**: Complete `azure.azcollection` with all azure_rm modules
- **Azure CLI**: Latest Azure CLI tools
- **Python Dependencies**: All required Azure SDK packages and dependencies
- **Authentication**: Service Principal, CLI, and Managed Identity support

**Windows Support:**
- **Windows Collections**: `ansible.windows` and `community.windows`
- **WinRM**: Complete WinRM support with pywinrm
- **CredSSP Authentication**: Advanced authentication with CredSSP
- **NTLM Support**: NTLM authentication for Windows domain environments
- **Kerberos/SPNEGO**: Advanced authentication mechanisms
- **XML Processing**: LXML for complex XML operations

**Additional Features:**
- **System Dependencies**: Required system packages for compilation and Kerberos support
- **Community Collections**: Extended functionality with community modules

## Building the Execution Environment

### Method 1: Using ansible-builder (Recommended)

```bash
# Install ansible-builder if not already installed
pip3 install ansible-builder

# Build the execution environment
./build.sh
```

### Method 2: Using Docker directly

```bash
docker build -t awx-azure-ee:latest .
```

## Usage in AWX

1. Build the execution environment using one of the methods above
2. Push the image to your container registry:
   ```bash
docker tag awx-azure-ee:latest your-registry/awx-azure-ee:latest
docker push your-registry/awx-azure-ee:latest
   ```
3. In AWX, go to Administration → Execution Environments
4. Add a new execution environment with your image URL
5. Use this execution environment in your job templates

## Testing the Environment

You can test the execution environment locally:

```bash
# Run interactively
docker run -it --rm awx-azure-ee:latest /bin/bash

# Test Azure collections
ansible-doc azure.azcollection.azure_rm_resourcegroup

# Test Windows collections  
ansible-doc ansible.windows.win_ping

# Test Azure CLI
az --version

# Test WinRM packages
python3 -c "import winrm; print('WinRM available')"
```

## Windows Authentication

This execution environment supports multiple Windows authentication methods:

1. **Basic Authentication**: Username/password (not recommended for production)
2. **NTLM**: Domain authentication
3. **CredSSP**: Credential delegation for multi-hop scenarios
4. **Kerberos**: Advanced domain authentication

### Example Windows Inventory Configuration:

```yaml
windows_hosts:
  hosts:
    win-server-01:
      ansible_host: 192.168.1.100
      ansible_user: domain\username
      ansible_password: password
      ansible_connection: winrm
      ansible_winrm_transport: credssp
      ansible_winrm_server_cert_validation: ignore
```

## Azure Authentication

This execution environment supports multiple Azure authentication methods:

1. **Service Principal**: Set environment variables:
   - `AZURE_CLIENT_ID`
   - `AZURE_SECRET`
   - `AZURE_TENANT`
   - `AZURE_SUBSCRIPTION_ID`

2. **Azure CLI**: Use `az login` within the container

3. **Managed Identity**: When running on Azure resources

## Included Collections

- `azure.azcollection` - Complete Azure Resource Manager modules
- `ansible.posix` - POSIX utilities
- `community.general` - General community modules
- `community.crypto` - Cryptographic modules
- `kubernetes.core` - Kubernetes support for AKS
- `ansible.windows` - Core Windows modules
- `community.windows` - Extended Windows functionality

## Python Packages

**Azure SDK packages:**
- Azure Management libraries for all services
- Azure Storage libraries
- Azure Identity and authentication

**Windows automation packages:**
- `pywinrm` - WinRM protocol support
- `requests-credssp` - CredSSP authentication
- `ntlm-auth` - NTLM authentication
- `pyspnego` - SPNEGO/Kerberos authentication
- `lxml` - XML processing for SOAP/WinRM

**Additional utilities:**
- Cryptography and security libraries
- Network and JSON processing libraries

## System Dependencies

- Git for version control
- Python development headers
- GCC compiler
- OpenSSL development libraries
- Kerberos libraries and tools (krb5-devel, krb5-workstation)
- XML processing libraries (libxml2-devel, libxslt-devel)
- SASL libraries for authentication (cyrus-sasl-devel, cyrus-sasl-gssapi)
- Rust and Cargo for certain package compilations

## Use Cases

This execution environment is perfect for:

- **Hybrid Cloud Management**: Manage both Azure resources and Windows infrastructure
- **Azure VM Configuration**: Deploy Azure VMs and configure Windows settings
- **Domain Operations**: Automate Windows domain-joined machines via CredSSP
- **Multi-platform Automation**: Single environment for Linux (Azure) and Windows automation
- **Enterprise Windows Management**: Advanced authentication for enterprise Windows environments

## Troubleshooting

**Azure Issues:**
1. **Build failures**: Check that you have sufficient disk space and Docker is running
2. **Authentication issues**: Verify your Azure credentials and permissions
3. **Module not found**: Ensure the execution environment is properly configured in AWX

**Windows Issues:**
1. **WinRM connection failures**: Verify WinRM is enabled on target Windows hosts
2. **Authentication failures**: Check username/password and domain configuration
3. **CredSSP issues**: Ensure CredSSP is enabled on both client and server
4. **Certificate errors**: Use `ansible_winrm_server_cert_validation: ignore` for testing

**Network Issues:**
1. Check firewall settings for WinRM (ports 5985/5986) and Azure API access
2. Verify proxy settings if applicable

## Contributing

To add additional packages or collections:
1. Update `requirements.txt` for Python packages
2. Update `requirements.yml` for Ansible collections
3. Update `bindep.txt` for system packages
4. Update `Dockerfile` for additional system configuration
5. Rebuild the execution environment
