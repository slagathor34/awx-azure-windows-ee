# Red Hat & Windows Automation Execution Environment

This repository contains the configuration files to build an AWX Execution Environment with comprehensive support for Red Hat Enterprise Linux automation via SSH and Windows automation via WinRM and CredSSP.

## Files Included

- `Dockerfile` - Traditional Docker build file
- `execution-environment.yml` - Modern ansible-builder configuration
- `requirements.txt` - Python dependencies including SSH and Windows WinRM packages
- `requirements.yml` - Ansible Galaxy collections including Red Hat and Windows collections
- `bindep.txt` - System dependencies including SSH, XML and Kerberos libraries
- `build.sh` - Build script for the execution environment
- `.github/workflows/` - GitHub Actions automation workflows

## GitHub Actions Workflow

The included GitHub Actions workflow provides flexible automation options:

### Execution Options
- **Manual Trigger**: Choose specific target OS from the Actions tab
  - `windows` (default) - Run only Windows automation
  - `redhat` - Run only Red Hat automation  
  - `both` - Run both Windows and Red Hat automation plus combined jobs
- **Push Trigger**: Automatically runs all configured jobs when code changes

### Self-Hosted Runner
- Runs on your local infrastructure using Docker containers
- Access to internal networks and servers
- No GitHub Actions minutes consumed
- Complete control over execution environment

## Features

This execution environment includes:

**Red Hat Linux Support:**
- **SSH Collections**: Complete SSH connectivity with key-based and password authentication
- **Red Hat Collections**: Official `redhat.rhel` and `redhat.satellite` collections
- **System Tools**: SSH clients, sshpass, rsync for file operations
- **Package Management**: DNF/YUM automation and RPM handling
- **Security**: SELinux management and system hardening capabilities

**Windows Support:**
- **Windows Collections**: `ansible.windows` and `community.windows`
- **WinRM**: Complete WinRM support with pywinrm
- **CredSSP Authentication**: Advanced authentication with CredSSP
- **NTLM Support**: NTLM authentication for Windows domain environments
- **Kerberos/SPNEGO**: Advanced authentication mechanisms
- **XML Processing**: LXML for complex XML operations

**Additional Features:**
- **System Dependencies**: Required system packages for SSH connectivity and Kerberos support
- **Community Collections**: Extended functionality with community modules
- **ansible-runner**: Full AWX execution environment compatibility

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
docker build -t rhel-windows-ee:latest .
```

## Usage in AWX

1. Build the execution environment using one of the methods above
2. Push the image to your container registry:

```bash
docker tag rhel-windows-ee:latest your-registry/rhel-windows-ee:latest
docker push your-registry/rhel-windows-ee:latest
```

3. In AWX, go to Administration → Execution Environments
4. Add a new execution environment with your image URL
5. Use this execution environment in your job templates

## GitHub Actions Integration

This execution environment is optimized for GitHub Actions workflows. See `GITHUB_ACTIONS.md` for detailed integration guide.

Key features for CI/CD:
- Pre-built image available: `sstormes/awx-azure-ee:latest`
- Multi-OS support (Red Hat and Windows)
- Parallel job execution
- ansible-runner integration

## Testing the Environment

You can test the execution environment locally:

```bash
# Run interactively
docker run -it --rm rhel-windows-ee:latest /bin/bash

# Test Red Hat collections
ansible-doc redhat.rhel.rhel_facts

# Test Windows collections
ansible-doc ansible.windows.win_ping

# Test SSH connectivity tools
ssh -V
sshpass -V

# Test WinRM packages
python3 -c "import winrm; print('WinRM available')"
```

## Red Hat Authentication

This execution environment supports multiple Red Hat Linux authentication methods:

1. **SSH Keys**: Public/private key pairs (recommended)
2. **Password**: Username/password authentication
3. **Sudo**: Privilege escalation support

### Example Red Hat Inventory Configuration:

```yaml
redhat_servers:
  hosts:
    rhel-server-01:
      ansible_host: 192.168.1.10
      ansible_user: ansible
      ansible_ssh_private_key_file: ~/.ssh/id_rsa
      ansible_become: true
      ansible_become_method: sudo
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

## Included Collections

- `redhat.rhel` - Red Hat Enterprise Linux automation
- `redhat.satellite` - Red Hat Satellite management
- `ansible.posix` - POSIX utilities
- `community.general` - General community modules
- `community.crypto` - Cryptographic modules
- `ansible.windows` - Core Windows modules
- `community.windows` - Extended Windows functionality

## Python Packages

**Red Hat automation packages:**
- `paramiko` - SSH protocol support
- `netaddr` - Network address manipulation
- `dnspython` - DNS toolkit
- `passlib` - Password hashing library
- `python-rpm-spec` - RPM package handling

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

- **SSH Tools**: OpenSSH clients, sshpass, rsync
- **Development Tools**: Git, Python development headers, GCC compiler
- **Security Libraries**: OpenSSL development libraries
- **Kerberos Libraries**: (krb5-devel, krb5-workstation)
- **XML Processing**: (libxml2-devel, libxslt-devel)
- **SASL Libraries**: (cyrus-sasl-devel, cyrus-sasl-gssapi)
- **Package Management**: RPM, DNF for Red Hat systems

## Use Cases

This execution environment is perfect for:

- **AWX/Ansible Tower**: Production-ready execution environment with ansible-runner
- **GitHub Actions**: CI/CD automation workflows (see GITHUB_ACTIONS.md)
- **Hybrid Infrastructure**: Manage both Red Hat Linux and Windows systems
- **Enterprise Automation**: Large-scale Red Hat and Windows fleet management
- **Configuration Management**: Standardized system configuration across platforms
- **Security Compliance**: Automated security policy enforcement
- **Multi-platform DevOps**: Single environment for Linux and Windows automation

## Sample Playbooks

The repository includes sample playbooks:

- `playbooks/redhat-config.yml` - Red Hat system configuration and hardening
- `playbooks/azure-deployment.yml` - System health checking and reporting (renamed from Azure)
- `playbooks/windows-config.yml` - Windows server configuration and management

## Troubleshooting

**Red Hat Issues:**
1. **SSH connection failures**: Verify SSH is enabled and accessible
2. **Authentication failures**: Check SSH keys or username/password
3. **Sudo issues**: Ensure user has proper sudo privileges
4. **Package management**: Verify DNF/YUM repository access

**Windows Issues:**
1. **WinRM connection failures**: Verify WinRM is enabled on target Windows hosts
2. **Authentication failures**: Check username/password and domain configuration
3. **CredSSP issues**: Ensure CredSSP is enabled on both client and server
4. **Certificate errors**: Use `ansible_winrm_server_cert_validation: ignore` for testing

**Network Issues:**
1. **SSH connectivity**: Check firewall settings for SSH (port 22)
2. **WinRM connectivity**: Check firewall settings for WinRM (ports 5985/5986)
3. **Proxy settings**: Verify proxy configuration if applicable

## Contributing

To add additional packages or collections:

1. Update `requirements.txt` for Python packages
2. Update `requirements.yml` for Ansible collections
3. Update `bindep.txt` for system packages
4. Update `Dockerfile` for additional system configuration
5. Rebuild the execution environment

## GitHub Repository

This execution environment is available at:
**https://github.com/slagathor34/awx-azure-windows-ee**

Docker Hub image:
**sstormes/awx-azure-ee:latest**
