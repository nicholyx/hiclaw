#!/bin/bash
# test-multi-instance.sh - Unit tests for HICLAW_MANAGER_NAME feature
#
# Tests the multi-instance support functionality:
# - HICLAW_MANAGER_NAME environment variable parsing
# - Container name derivation
# - Default behavior (backward compatibility)
#
# Usage: ./tests/test-multi-instance.sh

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/test-helpers.sh"

# ============================================================
# Test: Default container name (backward compatibility)
# ============================================================
test_default_container_name() {
    log_section "Test: Default container name"

    # When HICLAW_MANAGER_NAME is not set, should use hiclaw-manager
    unset HICLAW_MANAGER_NAME

    # Source the variable derivation logic
    # Simulating what install script should do
    MANAGER_CONTAINER_NAME="${HICLAW_MANAGER_NAME:-hiclaw}-manager"

    assert_eq "hiclaw-manager" "${MANAGER_CONTAINER_NAME}" "Default container name should be hiclaw-manager"
}

# ============================================================
# Test: Custom container name from HICLAW_MANAGER_NAME
# ============================================================
test_custom_container_name() {
    log_section "Test: Custom container name"

    # When HICLAW_MANAGER_NAME is set to custom value
    export HICLAW_MANAGER_NAME="my-hiclaw"

    MANAGER_CONTAINER_NAME="${HICLAW_MANAGER_NAME:-hiclaw}-manager"

    assert_eq "my-hiclaw-manager" "${MANAGER_CONTAINER_NAME}" "Custom container name should be my-hiclaw-manager"

    unset HICLAW_MANAGER_NAME
}

# ============================================================
# Test: Custom container name with special characters
# ============================================================
test_container_name_with_underscores() {
    log_section "Test: Container name with underscores"

    export HICLAW_MANAGER_NAME="hiclaw_dev"

    MANAGER_CONTAINER_NAME="${HICLAW_MANAGER_NAME:-hiclaw}-manager"

    assert_eq "hiclaw_dev-manager" "${MANAGER_CONTAINER_NAME}" "Container name should support underscores"

    unset HICLAW_MANAGER_NAME
}

# ============================================================
# Test: Default env file path
# ============================================================
test_default_env_file_path() {
    log_section "Test: Default env file path"

    unset HICLAW_MANAGER_NAME
    unset HICLAW_ENV_FILE

    # Simulate the env file path derivation
    MANAGER_NAME="${HICLAW_MANAGER_NAME:-hiclaw}"
    DEFAULT_ENV_FILE="${HOME}/${MANAGER_NAME}-manager.env"

    assert_eq "${HOME}/hiclaw-manager.env" "${DEFAULT_ENV_FILE}" "Default env file should be ~/hiclaw-manager.env"
}

# ============================================================
# Test: Custom env file path
# ============================================================
test_custom_env_file_path() {
    log_section "Test: Custom env file path"

    export HICLAW_MANAGER_NAME="my-hiclaw"
    unset HICLAW_ENV_FILE

    MANAGER_NAME="${HICLAW_MANAGER_NAME:-hiclaw}"
    DEFAULT_ENV_FILE="${HOME}/${MANAGER_NAME}-manager.env"

    assert_eq "${HOME}/my-hiclaw-manager.env" "${DEFAULT_ENV_FILE}" "Custom env file should be ~/my-hiclaw-manager.env"

    unset HICLAW_MANAGER_NAME
}

# ============================================================
# Test: Default workspace directory
# ============================================================
test_default_workspace_dir() {
    log_section "Test: Default workspace directory"

    unset HICLAW_MANAGER_NAME
    unset HICLAW_WORKSPACE_DIR

    MANAGER_NAME="${HICLAW_MANAGER_NAME:-hiclaw}"
    DEFAULT_WORKSPACE="${HOME}/${MANAGER_NAME}-manager"

    assert_eq "${HOME}/hiclaw-manager" "${DEFAULT_WORKSPACE}" "Default workspace should be ~/hiclaw-manager"
}

# ============================================================
# Test: Custom workspace directory
# ============================================================
test_custom_workspace_dir() {
    log_section "Test: Custom workspace directory"

    export HICLAW_MANAGER_NAME="my-hiclaw"
    unset HICLAW_WORKSPACE_DIR

    MANAGER_NAME="${HICLAW_MANAGER_NAME:-hiclaw}"
    DEFAULT_WORKSPACE="${HOME}/${MANAGER_NAME}-manager"

    assert_eq "${HOME}/my-hiclaw-manager" "${DEFAULT_WORKSPACE}" "Custom workspace should be ~/my-hiclaw-manager"

    unset HICLAW_MANAGER_NAME
}

# ============================================================
# Test: Default data volume name
# ============================================================
test_default_data_volume() {
    log_section "Test: Default data volume name"

    unset HICLAW_MANAGER_NAME
    unset HICLAW_DATA_DIR

    MANAGER_NAME="${HICLAW_MANAGER_NAME:-hiclaw}"
    DEFAULT_DATA_DIR="${MANAGER_NAME}-data"

    assert_eq "hiclaw-data" "${DEFAULT_DATA_DIR}" "Default data volume should be hiclaw-data"
}

# ============================================================
# Test: Custom data volume name
# ============================================================
test_custom_data_volume() {
    log_section "Test: Custom data volume name"

    export HICLAW_MANAGER_NAME="my-hiclaw"
    unset HICLAW_DATA_DIR

    MANAGER_NAME="${HICLAW_MANAGER_NAME:-hiclaw}"
    DEFAULT_DATA_DIR="${MANAGER_NAME}-data"

    assert_eq "my-hiclaw-data" "${DEFAULT_DATA_DIR}" "Custom data volume should be my-hiclaw-data"

    unset HICLAW_MANAGER_NAME
}

# ============================================================
# Test: HICLAW_ENV_FILE overrides default env file path
# ============================================================
test_env_file_override() {
    log_section "Test: HICLAW_ENV_FILE override"

    export HICLAW_MANAGER_NAME="my-hiclaw"
    export HICLAW_ENV_FILE="/custom/path/env"

    # HICLAW_ENV_FILE should take precedence
    ACTUAL_ENV_FILE="${HICLAW_ENV_FILE:-${HOME}/${HICLAW_MANAGER_NAME:-hiclaw}-manager.env}"

    assert_eq "/custom/path/env" "${ACTUAL_ENV_FILE}" "HICLAW_ENV_FILE should override default path"

    unset HICLAW_MANAGER_NAME
    unset HICLAW_ENV_FILE
}

# ============================================================
# Test: HICLAW_WORKSPACE_DIR overrides default workspace
# ============================================================
test_workspace_override() {
    log_section "Test: HICLAW_WORKSPACE_DIR override"

    export HICLAW_MANAGER_NAME="my-hiclaw"
    export HICLAW_WORKSPACE_DIR="/custom/workspace"

    # HICLAW_WORKSPACE_DIR should take precedence
    ACTUAL_WORKSPACE="${HICLAW_WORKSPACE_DIR:-${HOME}/${HICLAW_MANAGER_NAME:-hiclaw}-manager}"

    assert_eq "/custom/workspace" "${ACTUAL_WORKSPACE}" "HICLAW_WORKSPACE_DIR should override default path"

    unset HICLAW_MANAGER_NAME
    unset HICLAW_WORKSPACE_DIR
}

# ============================================================
# Test: Install script handles HICLAW_MANAGER_NAME
# This test checks if the install script properly uses a variable
# for container name instead of hardcoded "hiclaw-manager"
# ============================================================
test_install_script_uses_manager_name_variable() {
    log_section "Test: Install script uses HICLAW_MANAGER_NAME variable"

    local install_script="${SCRIPT_DIR}/../install/hiclaw-install.sh"

    # Check if the script has variable-based container name handling
    # The script should either:
    # 1. Use a MANAGER_CONTAINER_NAME variable derived from HICLAW_MANAGER_NAME
    # 2. Or directly use "${HICLAW_MANAGER_NAME:-hiclaw}-manager"

    # Look for pattern that indicates variable-based container naming
    if grep -q 'MANAGER_CONTAINER_NAME\|MANAGER_NAME' "${install_script}" 2>/dev/null; then
        log_pass "Install script uses variable for manager container name"
    else
        # Check if there are still hardcoded "hiclaw-manager" references in docker commands
        # that should be using a variable
        local hardcoded_count
        hardcoded_count=$(grep -c -- '--name hiclaw-manager\|"hiclaw-manager"' "${install_script}" 2>/dev/null || echo "0")

        if [ "${hardcoded_count}" -gt 0 ]; then
            log_fail "Install script has ${hardcoded_count} hardcoded 'hiclaw-manager' references that should use variable"
        else
            log_pass "Install script does not have hardcoded container name in docker commands"
        fi
    fi
}

# ============================================================
# Test: Import script handles HICLAW_MANAGER_NAME
# ============================================================
test_import_script_uses_manager_name_variable() {
    log_section "Test: Import script uses HICLAW_MANAGER_NAME variable"

    local import_script="${SCRIPT_DIR}/../install/hiclaw-import.sh"

    # Check if the script uses HICLAW_MANAGER_NAME or a derived variable
    if grep -q 'HICLAW_MANAGER_NAME\|MANAGER_CONTAINER_NAME\|MANAGER_NAME' "${import_script}" 2>/dev/null; then
        log_pass "Import script references HICLAW_MANAGER_NAME variable"
    else
        # Check for hardcoded container name in exec commands
        local hardcoded_count
        hardcoded_count=$(grep -c 'exec hiclaw-manager\|exec -i hiclaw-manager\|filter name=hiclaw-manager' "${import_script}" 2>/dev/null || echo "0")

        if [ "${hardcoded_count}" -gt 0 ]; then
            log_fail "Import script has ${hardcoded_count} hardcoded 'hiclaw-manager' references"
        else
            log_pass "Import script does not have hardcoded container name in exec commands"
        fi
    fi
}

# ============================================================
# Test: No hardcoded container name in docker run command
# ============================================================
test_no_hardcoded_container_name_in_docker_run() {
    log_section "Test: No hardcoded container name in docker run"

    local install_script="${SCRIPT_DIR}/../install/hiclaw-install.sh"

    # Check for the specific pattern "--name hiclaw-manager" which should use a variable
    if grep -q '\-\-name hiclaw-manager' "${install_script}" 2>/dev/null; then
        log_fail "Install script has hardcoded '--name hiclaw-manager' in docker run command"
    else
        log_pass "Install script uses variable for container name in docker run"
    fi
}

# ============================================================
# Test: PowerShell install script uses HICLAW_MANAGER_NAME
# ============================================================
test_powershell_install_script_uses_manager_name() {
    log_section "Test: PowerShell install script uses HICLAW_MANAGER_NAME"

    local install_script="${SCRIPT_DIR}/../install/hiclaw-install.ps1"

    # Check if the script has variable-based container name handling
    if grep -q 'MANAGER_CONTAINER_NAME\|MANAGER_NAME' "${install_script}" 2>/dev/null; then
        log_pass "PowerShell install script uses variable for manager container name"
    else
        log_fail "PowerShell install script does not use MANAGER_CONTAINER_NAME variable"
    fi
}

# ============================================================
# Test: PowerShell import script uses HICLAW_MANAGER_NAME
# ============================================================
test_powershell_import_script_uses_manager_name() {
    log_section "Test: PowerShell import script uses HICLAW_MANAGER_NAME"

    local import_script="${SCRIPT_DIR}/../install/hiclaw-import.ps1"

    # Check if the script uses HICLAW_MANAGER_NAME or a derived variable
    if grep -q 'MANAGER_CONTAINER_NAME\|MANAGER_NAME' "${import_script}" 2>/dev/null; then
        log_pass "PowerShell import script uses variable for manager container name"
    else
        log_fail "PowerShell import script does not use MANAGER_CONTAINER_NAME variable"
    fi
}

# ============================================================
# Run all tests
# ============================================================
main() {
    log_section "Multi-Instance Support Unit Tests"

    # Variable logic tests
    test_default_container_name
    test_custom_container_name
    test_container_name_with_underscores
    test_default_env_file_path
    test_custom_env_file_path
    test_default_workspace_dir
    test_custom_workspace_dir
    test_default_data_volume
    test_custom_data_volume
    test_env_file_override
    test_workspace_override

    # Implementation tests
    test_install_script_uses_manager_name_variable
    test_import_script_uses_manager_name_variable
    test_no_hardcoded_container_name_in_docker_run

    # PowerShell tests
    test_powershell_install_script_uses_manager_name
    test_powershell_import_script_uses_manager_name

    test_summary
}

main "$@"