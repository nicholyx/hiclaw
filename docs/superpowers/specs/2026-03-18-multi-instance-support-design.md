# Multi-Instance Support Design

**Date**: 2026-03-18
**Issue**: #314
**Author**: Claude Agent

## Overview

Add support for running multiple isolated HiClaw instances on the same host by introducing a `HICLAW_MANAGER_NAME` environment variable to customize the manager container name.

## Problem Statement

The install script currently hardcodes the manager container name (`hiclaw-manager`), which causes conflicts when installing a second instance on the same host. While workspace directory and env file paths are configurable, the container name is not.

## Proposed Solution

### 1. New Environment Variable: `HICLAW_MANAGER_NAME`

- **Default value**: `hiclaw-manager`
- **Purpose**: Controls the manager container name and derived resource names
- **Naming convention**: Must be a valid Docker container name (alphanumeric, underscores, hyphens)

### 2. Derived Resource Names

When `HICLAW_MANAGER_NAME` is set to a custom value (e.g., `my-hiclaw`):

| Resource | Default | Custom Example |
|----------|---------|----------------|
| Container name | `hiclaw-manager` | `my-hiclaw-manager` |
| Env file | `~/hiclaw-manager.env` | `~/my-hiclaw-manager.env` |
| Workspace dir | `~/hiclaw-manager` | `~/my-hiclaw-manager` |
| Data volume | `hiclaw-data` | `my-hiclaw-data` |

**Convention**: The manager container name uses `{INSTANCE_NAME}-manager` format to clearly identify it as a HiClaw manager instance.

### 3. Implementation Approach

#### 3.1 Shell Script (`hiclaw-install.sh`)

1. Add `HICLAW_MANAGER_NAME` to the environment variable section
2. Define `MANAGER_CONTAINER_NAME` variable derived from `HICLAW_MANAGER_NAME`
3. Replace all hardcoded `hiclaw-manager` references with `${MANAGER_CONTAINER_NAME}`
4. Update default env file path and workspace directory to use instance name

#### 3.2 PowerShell Script (`hiclaw-install.ps1`)

Same changes as the shell script, adapted for PowerShell syntax.

#### 3.3 Import Scripts (`hiclaw-import.sh`, `hiclaw-import.ps1`)

Update to use `HICLAW_MANAGER_NAME` for container operations.

### 4. User Experience

#### Installation Wizard

Add a new prompt in the installation wizard (Manual mode):

```
Instance name (default: hiclaw): _
```

This allows users to easily create multiple instances without manually setting environment variables.

#### Command Line Usage

```bash
# Install second instance
HICLAW_MANAGER_NAME=hiclaw-dev ./hiclaw-install.sh

# Or use Quick Start with environment variable
HICLAW_MANAGER_NAME=hiclaw-dev HICLAW_NON_INTERACTIVE=1 ./hiclaw-install.sh
```

### 5. Backward Compatibility

- When `HICLAW_MANAGER_NAME` is not set, behavior remains identical to current implementation
- Existing installations continue to work without any changes
- Migration not required for single-instance setups

## Files to Modify

1. `install/hiclaw-install.sh` - Main shell installer
2. `install/hiclaw-install.ps1` - PowerShell installer
3. `install/hiclaw-import.sh` - Shell import script
4. `install/hiclaw-import.ps1` - PowerShell import script

## Success Criteria

1. Users can install multiple HiClaw instances with different names on the same host
2. Each instance operates independently with its own:
   - Container name
   - Env file
   - Workspace directory
   - Data volume
3. Backward compatibility is maintained for existing installations
4. Installation wizard includes instance name prompt

## Testing Plan

1. Install default instance (no `HICLAW_MANAGER_NAME`)
2. Install second instance with custom name
3. Verify both instances can run simultaneously
4. Verify import scripts work with custom instance names
5. Verify uninstall removes correct instance

## Estimated Complexity

**Medium** - The change involves updating multiple files with many string replacements, but the logic is straightforward.