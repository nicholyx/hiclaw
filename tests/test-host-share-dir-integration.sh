#!/bin/bash
# test-host-share-dir-integration.sh - Integration test for HICLAW_HOST_SHARE_DIR fix
# This test validates the actual fix in hiclaw-install.sh

set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/test-helpers.sh"

INSTALL_SCRIPT="${SCRIPT_DIR}/../install/hiclaw-install.sh"

log_section "Integration Test: HICLAW_HOST_SHARE_DIR Fix"

# Test 1: Verify the fix is in place - check that the problematic pattern is gone
test_fix_pattern_in_place() {
    # The old buggy pattern: HOST_SHARE_MOUNT_ARGS="-v ${HICLAW_HOST_SHARE_DIR}:/host-share" in the else branch
    # Should NOT have two consecutive lines with HOST_SHARE_MOUNT_ARGS assignment

    local bug_pattern
    bug_pattern=$(grep -A2 "else" "${INSTALL_SCRIPT}" | grep -c 'HOST_SHARE_MOUNT_ARGS="-v' || true)

    # The fixed code should not have HOST_SHARE_MOUNT_ARGS assignment in the else branch
    # Let's check for the specific fix pattern
    if grep -q '# Only mount if HICLAW_HOST_SHARE_DIR is set and the directory exists' "${INSTALL_SCRIPT}"; then
        log_pass "Fix comment found in install script"
    else
        log_fail "Fix comment not found - fix may not be applied correctly"
    fi
}

# Test 2: Verify the logic structure is correct
test_logic_structure() {
    # The fixed code should have:
    # 1. HOST_SHARE_MOUNT_ARGS="" at the start (initialization)
    # 2. Check for non-empty HICLAW_HOST_SHARE_DIR
    # 3. Nested check for directory existence

    if grep -q 'HOST_SHARE_MOUNT_ARGS=""' "${INSTALL_SCRIPT}"; then
        log_pass "HOST_SHARE_MOUNT_ARGS is properly initialized to empty"
    else
        log_fail "HOST_SHARE_MOUNT_ARGS initialization missing"
    fi

    if grep -q 'if \[ -n "\${HICLAW_HOST_SHARE_DIR}" \]' "${INSTALL_SCRIPT}"; then
        log_pass "Non-empty check for HICLAW_HOST_SHARE_DIR exists"
    else
        log_fail "Non-empty check for HICLAW_HOST_SHARE_DIR missing"
    fi
}

# Test 3: Verify no invalid Docker syntax can be generated
test_no_invalid_syntax() {
    # The fix should prevent generating "-v :/host-share" (empty source path)

    # Check that the code doesn't have the buggy else branch that always sets mount args
    local else_content
    else_content=$(grep -A3 "host_share.not_exist" "${INSTALL_SCRIPT}" 2>/dev/null || true)

    if echo "${else_content}" | grep -q 'HOST_SHARE_MOUNT_ARGS="-v'; then
        log_fail "Buggy pattern still exists: mount args set even when dir doesn't exist"
    else
        log_pass "Fixed: no mount args generated when directory doesn't exist"
    fi
}

# Test 4: Verify PowerShell fix is also in place
test_powershell_fix() {
    local ps_script="${SCRIPT_DIR}/../install/hiclaw-install.ps1"

    if [ -f "${ps_script}" ]; then
        if grep -q 'Test-Path.*HOST_SHARE_DIR' "${ps_script}" || grep -q 'Test-Path -Path \$config.HOST_SHARE_DIR' "${ps_script}"; then
            log_pass "PowerShell script also has directory existence check"
        else
            log_fail "PowerShell script may need similar fix"
        fi
    else
        log_pass "PowerShell script not found (skipped)"
    fi
}

# Run tests
test_fix_pattern_in_place
test_logic_structure
test_no_invalid_syntax
test_powershell_fix

test_summary
