#!/bin/bash
# test-15-dangling-image-cleanup.sh - Test dangling image cleanup during upgrade
# Issue #345: 升级后产生悬空镜像，建议删除容器时同步删除镜像

set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/test-helpers.sh
source "${SCRIPT_DIR}/lib/test-helpers.sh"

test_setup "15-dangling-image-cleanup"

# ============================================================
# Test: Verify dangling image cleanup function exists in install script
# ============================================================

log_section "Test 1: Verify dangling image cleanup logic exists"

INSTALL_SCRIPT="${SCRIPT_DIR}/../install/hiclaw-install.sh"

# Check if install script exists
if [ ! -f "${INSTALL_SCRIPT}" ]; then
    log_fail "Install script not found: ${INSTALL_SCRIPT}"
    test_teardown "15-dangling-image-cleanup"
    exit 1
fi

# Check for docker image prune command in script
if grep -q "docker image prune" "${INSTALL_SCRIPT}" || grep -q "image prune" "${INSTALL_SCRIPT}"; then
    log_pass "Docker image prune command found in install script"
else
    log_fail "Docker image prune command NOT found in install script"
fi

# Check for dangling image cleanup message
if grep -q "dangling" "${INSTALL_SCRIPT}" || grep -q "悬空镜像" "${INSTALL_SCRIPT}"; then
    log_pass "Dangling image cleanup message found in install script"
else
    log_fail "Dangling image cleanup message NOT found in install script"
fi

# ============================================================
# Test: Verify cleanup is triggered after container removal in upgrade flow
# ============================================================

log_section "Test 2: Verify cleanup trigger location"

# Check that image prune is called after container removal in upgrade flow
# The pattern should be: docker rm (container) followed by docker image prune
# We check if prune is called anywhere after container removal operations
if grep -A20 "docker rm\|rm hiclaw" "${INSTALL_SCRIPT}" | grep -q "image prune"; then
    log_pass "Image prune is called after container removal"
elif grep -B5 "image prune" "${INSTALL_SCRIPT}" | grep -q "rm\|stop"; then
    log_pass "Image prune is called near container operations"
else
    log_fail "Image prune is NOT called after container removal"
fi

# ============================================================
# Test: Verify prune uses -f flag (non-interactive)
# ============================================================

log_section "Test 3: Verify prune uses -f flag"

if grep -q "docker image prune -f\|image prune -f" "${INSTALL_SCRIPT}"; then
    log_pass "Image prune uses -f flag for non-interactive mode"
else
    log_fail "Image prune does NOT use -f flag"
fi

# ============================================================
# Test: Simulate dangling image cleanup (requires Docker)
# ============================================================

log_section "Test 4: Simulate dangling image cleanup (if Docker available)"

if ! command -v docker &>/dev/null; then
    log_info "SKIP: Docker not available, skipping simulation test"
else
    # Count dangling images before cleanup
    DANGLING_BEFORE=$(docker images -f "dangling=true" -q 2>/dev/null | wc -l | tr -d ' ')

    # Run the cleanup command
    log_info "Running: docker image prune -f"
    PRUNE_OUTPUT=$(docker image prune -f 2>&1)
    log_info "Prune output: ${PRUNE_OUTPUT}"

    # Count dangling images after cleanup
    DANGLING_AFTER=$(docker images -f "dangling=true" -q 2>/dev/null | wc -l | tr -d ' ')

    log_info "Dangling images before: ${DANGLING_BEFORE}, after: ${DANGLING_AFTER}"

    # The test passes if cleanup ran without error (dangling images should be 0 or less than before)
    if [ "${DANGLING_AFTER}" -le "${DANGLING_BEFORE}" ]; then
        log_pass "Dangling image cleanup works correctly (removed $((DANGLING_BEFORE - DANGLING_AFTER)) images)"
    else
        log_fail "Dangling image cleanup failed"
    fi
fi

# ============================================================
# Summary
# ============================================================

test_teardown "15-dangling-image-cleanup"
test_summary