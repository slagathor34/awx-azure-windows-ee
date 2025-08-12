# GitHub Secrets Configuration

This document explains how to set up the required GitHub secrets for the Red Hat and Windows automation workflows.

## Workflow Targeting

The workflow supports flexible targeting options:

- **Windows Only** (default): Configure only `WINDOWS_USERNAME` and `WINDOWS_PASSWORD` secrets
- **Red Hat Only**: Configure only SSH keys or Red Hat credentials  
- **Both Platforms**: Configure secrets for both Windows and Red Hat systems

You can select the target OS when manually triggering the workflow from the Actions tab.

## Required Secrets

The GitHub Actions workflow requires the following secrets to be configured in your repository settings.

### Navigation
Go to: **Repository Settings** → **Secrets and variables** → **Actions** → **New repository secret**

## Red Hat/Linux Authentication Secrets

### SSH Key Authentication (Recommended)
```
SSH_PRIVATE_KEY
```
**Value**: Your SSH private key content (for passwordless authentication)
```
SSH_PUBLIC_KEY
```
**Value**: Your SSH public key content (optional, for reference)

### Username/Password Authentication (Alternative)
```
RHEL_USERNAME
```
**Value**: Username for Red Hat Enterprise Linux servers

```
RHEL_PASSWORD
```
**Value**: Password for Red Hat Enterprise Linux servers

```
CENTOS_USERNAME  
```
**Value**: Username for CentOS servers (if different from RHEL)

## Windows Authentication Secrets

### Local Windows Authentication
```
WINDOWS_USERNAME
```
**Value**: Local Windows administrator username
**Example**: `Administrator` or `admin`

```
WINDOWS_PASSWORD
```
**Value**: Password for the Windows user account

### Domain Authentication (if using domain-joined Windows servers)
```
DOMAIN_USERNAME
```
**Value**: Domain user account (format: `domain\username` or `username@domain.com`)
**Example**: `CORP\adminuser` or `adminuser@corp.com`

```
DOMAIN_PASSWORD
```
**Value**: Password for the domain user account

## Docker Hub Secrets (Optional)

If you want to push custom execution environment images:

```
DOCKERHUB_USERNAME
```
**Value**: Your Docker Hub username

```
DOCKERHUB_TOKEN
```
**Value**: Your Docker Hub access token (not password)

## Current Server Configuration

Based on your `inventories/dev/hosts.yml`, you have configured:

### Windows Servers:
- **winlab.brainstormes.org** (192.168.6.5) - CredSSP authentication
- **winlab3.brainstormes.org** (192.168.6.80) - NTLM authentication

Both servers are configured to use:
- Username: `${{ lookup('env', 'WINDOWS_USERNAME') }}`
- Password: `${{ lookup('env', 'WINDOWS_PASSWORD') }}`
- WinRM port: 5986 (HTTPS)

### Red Hat Servers:
Currently no servers are configured in the `redhat_servers` group. Add your Red Hat/CentOS servers there.

## Security Best Practices

1. **Use SSH keys instead of passwords** when possible for Linux servers
2. **Rotate secrets regularly** 
3. **Use least-privilege accounts** - create dedicated automation accounts
4. **Enable WinRM HTTPS** (port 5986) instead of HTTP (port 5985)
5. **Use service accounts** for domain authentication instead of personal accounts

## Testing Secrets

You can test if your secrets are working by:

1. **Trigger the workflow** manually from Actions tab
2. **Check the connectivity tests** in the workflow output
3. **Review logs** for authentication failures

## Example Secret Values

### SSH Private Key Format
```
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAlwAAAAdzc2gtcn
NhAAAAAwEAAQAAAYEA... (your actual key content)
-----END OPENSSH PRIVATE KEY-----
```

### Domain Username Formats
```
# Format 1: domain\username
CORP\serviceaccount

# Format 2: UPN format  
serviceaccount@corp.local

# Format 3: NetBIOS format
DOMAIN\username
```

## Troubleshooting

### SSH Authentication Issues
- Verify private key format (OpenSSH format preferred)
- Check if public key is installed on target servers
- Ensure proper file permissions on target servers (~/.ssh/authorized_keys should be 600)

### Windows Authentication Issues  
- Verify WinRM is enabled and configured
- Check if user has "Log on as a service" right
- Confirm CredSSP/NTLM is properly configured
- Test manually with `winrs` or PowerShell remoting

### Network Connectivity
- Ensure GitHub runner can reach your internal network
- Check firewall rules for SSH (22) and WinRM (5985/5986) ports
- Verify DNS resolution for your hostnames

## Next Steps

1. **Add the required secrets** to your GitHub repository
2. **Test the workflow** by triggering it manually
3. **Add your Red Hat servers** to the inventory
4. **Customize playbooks** as needed for your environment

Your self-hosted runner setup means the workflows will execute from your local network, giving you access to internal servers that wouldn't be reachable from GitHub's hosted runners.
