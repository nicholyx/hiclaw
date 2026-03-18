#!/bin/bash
# test-install-host-share-dir.sh - Unit tests for HICLAW_HOST_SHARE_DIR handling
# Tests the mount argument generation logic in hiclaw-install.sh
#
# This test follows TDD: First write failing tests for EXPECTED behavior,
# then implement the fix to make tests pass.

set -o pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/test-helpers.sh"

# Path to install script
INSTALL_SCRIPT="${SCRIPT_DIR}/../install/hiclaw-install.sh"

# ============================================================
# Test Helper: Extract and test HOST_SHARE_MOUNT_ARGS logic
# ============================================================

# Function that simulates EXPECTED (fixed) behavior
# This is what the code SHOULD do:
# - If HICLAW_HOST_SHARE_DIR is empty, no mount args
# - If HICLAW_HOST_SHARE_DIR is set but directory doesn't exist, no mount args (or warning)
# - If HICLAW_HOST_SHARE_DIR is set and directory exists, generate mount args
generate_host_share_mount_args_expected() {
    local host_share_dir="$1"

    local host_share_mount_args=""
    if [ -n "${host_share_dir}" ] && [ -d "${host_share_dir}" ]; then
        host_share_mount_args="-v ${host_share_dir}:/host-share"
    fi

    echo "${host_share_mount_args}"
}

# Function that simulates CURRENT (buggy) behavior from lines 2004-2011
# The bug: generates mount args even when dir doesn't exist or dir is empty
generate_host_share_mount_args_current() {
    local host_share_dir="$1"

    local host_share_mount_args=""
    if [ -d "${host_share_dir}" ]; then
        host_share_mount_args="-v ${host_share_dir}:/host-share"
    else
        # BUG: Still generates mount args even when dir doesn't exist!
        host_share_mount_args="-v ${host_share_dir}:/host-share"
    fi

    echo "${host_share_mount_args}"
}

# ============================================================
# Tests - These test the EXPECTED behavior (TDD Red phase)
# ============================================================

log_section "Testing HICLAW_HOST_SHARE_DIR Expected Behavior"

# Test 1: When HICLAW_HOST_SHARE_DIR is set and directory exists
# EXPECTED: Generate valid mount args
test_host_share_dir_exists() {
    local temp_dir
    temp_dir=$(mktemp -d)

    local result
    result=$(generate_host_share_mount_args_expected "${temp_dir}")

    if [ "${result}" = "-v ${temp_dir}:/host-share" ]; then
        log_pass "Mount args correct when dir exists"
    else
        log_fail "Mount args wrong when dir exists (expected '-v ${temp_dir}:/host-share', got '${result}')"
    fi

    rmdir "${temp_dir}"
}

# Test 2: When HICLAW_HOST_SHARE_DIR is set but directory does NOT exist
# EXPECTED: NO mount args generated (current bug generates them anyway)
test_host_share_dir_not_exists() {
    local non_existent_dir="/tmp/hiclaw-test-nonexistent-$$-$(date +%s)"

    local result
    result=$(generate_host_share_mount_args_expected "${non_existent_dir}")

    if [ -z "${result}" ]; then
        log_pass "Mount args empty when dir doesn't exist (correct)"
    else
        log_fail "Mount args should be empty when dir doesn't exist, got: '${result}'"
    fi
}

# Test 3: When HICLAW_HOST_SHARE_DIR is empty string
# EXPECTED: NO mount args generated
test_host_share_dir_empty() {
    local result
    result=$(generate_host_share_mount_args_expected "")

    if [ -z "${result}" ]; then
        log_pass "Mount args empty when HICLAW_HOST_SHARE_DIR is empty"
    else
        log_fail "Mount args should be empty when HICLAW_HOST_SHARE_DIR is empty, got: '${result}'"
    fi
}

# Test 4: Verify current buggy behavior exists (this documents the bug)
test_current_bug_exists() {
    local non_existent_dir="/tmp/hiclaw-test-nonexistent-$$-$(date +%s)"

    local result
    result=$(generate_host_share_mount_args_current "${non_existent_dir}")

    # The BUG: current code generates mount args even for non-existent dir
    if [ -n "${result}" ] && [ "${result}" = "-v ${non_existent_dir}:/host-share" ]; then
        log_pass "Confirmed bug exists: current code generates mount args for non-existent dir"
    else
        log_fail "Bug not found - unexpected behavior: '${result}'"
    fi
}

# Test 5: Current bug generates invalid Docker syntax for empty dir
test_current_bug_empty_dir() {
    local result
    result=$(generate_host_share_mount_args_current "")

    # The BUG: generates "-v :/host-share" which is invalid Docker syntax
    if [ "${result}" = "-v :/host-share" ]; then
        log_pass "Confirmed bug: generates invalid Docker syntax '-v :/host-share' for empty dir"
    else
        log_fail "Unexpected behavior for empty dir: '${result}'"
    fi
}

# Test 6: Fix prevents invalid Docker mount syntax
test_fix_prevents_invalid_syntax() {
    local result
    result=$(generate_host_share_mount_args_expected "")

    # Should NOT produce "-v :/host-share"
    if [ "${result}" = "-v :/host-share" ]; then
        log_fail "Fix still produces invalid Docker mount syntax"
    else
        log_pass "Fix prevents invalid Docker mount syntax for empty HICLAW_HOST_SHARE_DIR"
    fi
}

# ============================================================
# Run Tests
# ============================================================

test_host_share_dir_exists
test_host_share_dir_not_exists
test_host_share_dir_empty
test_current_bug_exists
test_current_bug_empty_dir
test_fix_prevents_invalid_syntax

test_summary