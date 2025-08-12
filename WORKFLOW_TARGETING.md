# Workflow Targeting Quick Reference

## Manual Workflow Execution

### From GitHub Web Interface
1. Go to **Actions** tab in your repository
2. Click **Red Hat & Windows Automation** workflow
3. Click **Run workflow** button
4. Select your options:
   - **Environment**: `dev`, `staging`, or `prod`
   - **Target OS**: `windows` (default), `redhat`, or `both`

### Targeting Options

#### 🪟 Windows Only (Default)
```
Target OS: windows
```
**Runs:**
- Windows connectivity tests
- Windows configuration playbook
- Windows-specific verifications

**Required Secrets:**
- `WINDOWS_USERNAME`
- `WINDOWS_PASSWORD`
- `DOMAIN_USERNAME` (if using domain auth)
- `DOMAIN_PASSWORD` (if using domain auth)

#### 🐧 Red Hat Only  
```
Target OS: redhat
```
**Runs:**
- Red Hat connectivity tests
- Red Hat configuration playbook
- SSH and Linux-specific verifications

**Required Secrets:**
- `SSH_PRIVATE_KEY` (recommended) OR
- `RHEL_USERNAME` + `RHEL_PASSWORD`
- `CENTOS_USERNAME` (if different from RHEL)

#### 🔄 Both Platforms
```
Target OS: both  
```
**Runs:**
- All Windows automation
- All Red Hat automation  
- Combined ansible-runner jobs
- Cross-platform verifications

**Required Secrets:**
- All Windows secrets (above)
- All Red Hat secrets (above)

## Automatic Execution

### Push Triggers
**When:** Code changes to `main` branch in:
- `playbooks/` directory
- `inventories/` directory  
- `.github/workflows/` directory

**Behavior:** Runs all configured jobs (equivalent to "both" selection)

## Job Execution Matrix

| Trigger Type | Target OS | RedHat Job | Windows Job | Ansible-Runner Job |
|--------------|-----------|------------|-------------|-------------------|
| Manual | `windows` | ❌ No | ✅ Yes | ❌ No |
| Manual | `redhat` | ✅ Yes | ❌ No | ❌ No |  
| Manual | `both` | ✅ Yes | ✅ Yes | ✅ Yes |
| Push | N/A | ✅ Yes | ✅ Yes | ✅ Yes |

## Examples

### Windows-Only Deployment
Perfect for organizations that only manage Windows servers:
1. Configure Windows secrets only
2. Use default "windows" targeting
3. Windows servers get automated without Red Hat overhead

### Red Hat-Only Deployment  
Ideal for Linux-only environments:
1. Configure SSH keys or Red Hat credentials
2. Select "redhat" targeting
3. Skip Windows authentication setup entirely

### Mixed Environment
For organizations with both Windows and Linux:
1. Configure secrets for both platforms
2. Use "both" targeting or run separately
3. Full cross-platform automation capability

## Benefits

✅ **Faster Execution**: Run only what you need  
✅ **Simpler Setup**: Configure secrets for your environment only  
✅ **Reduced Complexity**: Avoid failed jobs from missing credentials  
✅ **Flexible Testing**: Test one platform at a time  
✅ **Cost Effective**: Less runner time for focused deployments

## Migration Notes

**Previous Behavior**: Workflows always ran both Red Hat and Windows jobs  
**New Behavior**: Manual triggers default to Windows only, preserving push behavior

**No Breaking Changes**: Push triggers maintain previous "run all" behavior for CI/CD pipelines
