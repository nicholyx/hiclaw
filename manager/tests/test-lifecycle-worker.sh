#!/bin/bash
# test-lifecycle-worker.sh - Unit tests for lifecycle-worker.sh
# Tests the worker container lifecycle management including the new delete action.

set -o pipefail

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Source the script's functions for testing
# We'll mock the container API functions
source "${PROJECT_ROOT}/scripts/lib/container-api.sh" 2>/dev/null || true

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# Colors
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
NC='\033[0m'

# Logging functions
log_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
}

log_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
}

log_info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

log_section() {
    echo ""
    echo "=== $1 ==="
}

# ============================================================
# Test: lifecycle-worker.sh has delete action
# ============================================================
test_lifecycle_has_delete_action() {
    log_section "Test: lifecycle-worker.sh has delete action"

    local script_path="${PROJECT_ROOT}/agent/skills/worker-management/scripts/lifecycle-worker.sh"

    # Check if the script exists
    if [ ! -f "$script_path" ]; then
        log_fail "lifecycle-worker.sh not found at $script_path"
        return 1
    fi

    # Check if the script has a 'delete' action case
    if grep -q "delete)" "$script_path"; then
        log_pass "lifecycle-worker.sh has 'delete' action case"
    else
        log_fail "lifecycle-worker.sh missing 'delete' action case"
        return 1
    fi

    # Check if the script has action_delete function
    if grep -q "action_delete()" "$script_path"; then
        log_pass "lifecycle-worker.sh has 'action_delete' function"
    else
        log_fail "lifecycle-worker.sh missing 'action_delete' function"
        return 1
    fi

    # Check if action_delete calls worker_backend_delete
    if grep -q "worker_backend_delete" "$script_path"; then
        log_pass "lifecycle-worker.sh action_delete calls worker_backend_delete"
    else
        log_fail "lifecycle-worker.sh action_delete should call worker_backend_delete"
        return 1
    fi
}

# ============================================================
# Test: action_delete checks worker existence in registry
# ============================================================
test_delete_checks_registry() {
    log_section "Test: action_delete checks worker existence in registry"

    local script_path="${PROJECT_ROOT}/agent/skills/worker-management/scripts/lifecycle-worker.sh"

    # Check if action_delete checks for worker in registry
    if grep -A30 "action_delete()" "$script_path" | grep -q "not found in registry"; then
        log_pass "action_delete checks if worker exists in registry"
    else
        log_fail "action_delete should check if worker exists in registry"
        return 1
    fi
}

# ============================================================
# Test: action_delete outputs JSON for remote workers
# ============================================================
test_delete_outputs_json_for_remote() {
    log_section "Test: action_delete outputs JSON for remote workers"

    local script_path="${PROJECT_ROOT}/agent/skills/worker-management/scripts/lifecycle-worker.sh"

    # Check if action_delete outputs JSON status for remote workers
    if grep -A30 "action_delete()" "$script_path" | grep -q "cannot_delete_remote"; then
        log_pass "action_delete outputs JSON status for remote workers"
    else
        log_fail "action_delete should output JSON status for remote workers"
        return 1
    fi
}

# ============================================================
# Test: action_delete outputs JSON for all error cases
# ============================================================
test_delete_outputs_json_for_errors() {
    log_section "Test: action_delete outputs JSON for all error cases"

    local script_path="${PROJECT_ROOT}/agent/skills/worker-management/scripts/lifecycle-worker.sh"

    # Check if action_delete outputs JSON status for failed cases
    # The pattern should match the actual output format: \"status\":\"failed\"
    if grep -A50 "action_delete()" "$script_path" | grep -q 'status.*failed'; then
        log_pass "action_delete outputs JSON status for failed cases"
    else
        log_fail "action_delete should output JSON status for failed cases"
        return 1
    fi
}

# ============================================================
# Test: lifecycle-worker.sh delete action requires --worker
# ============================================================
test_delete_requires_worker_arg() {
    log_section "Test: delete action requires --worker argument"

    local script_path="${PROJECT_ROOT}/agent/skills/worker-management/scripts/lifecycle-worker.sh"

    # Check if delete action requires worker argument
    if grep -A5 "delete)" "$script_path" | grep -q "WORKER"; then
        log_pass "delete action checks for --worker argument"
    else
        log_fail "delete action should check for --worker argument"
        return 1
    fi
}

# ============================================================
# Test: lifecycle-worker.sh usage includes delete
# ============================================================
test_usage_includes_delete() {
    log_section "Test: usage message includes delete action"

    local script_path="${PROJECT_ROOT}/agent/skills/worker-management/scripts/lifecycle-worker.sh"

    # Check if usage message includes delete
    if grep -E "Usage.*delete|sync-status.*check-idle.*stop.*start.*delete|stop.*start.*delete.*ensure-ready" "$script_path" >/dev/null; then
        log_pass "usage message includes 'delete' action"
    else
        log_fail "usage message should include 'delete' action"
        return 1
    fi
}

# ============================================================
# Test: container-api.sh has worker_backend_delete function
# ============================================================
test_container_api_has_delete() {
    log_section "Test: container-api.sh has worker_backend_delete function"

    local script_path="${PROJECT_ROOT}/scripts/lib/container-api.sh"

    # Check if the script exists
    if [ ! -f "$script_path" ]; then
        log_fail "container-api.sh not found at $script_path"
        return 1
    fi

    # Check if the script has worker_backend_delete function
    if grep -q "worker_backend_delete()" "$script_path"; then
        log_pass "container-api.sh has 'worker_backend_delete' function"
    else
        log_fail "container-api.sh missing 'worker_backend_delete' function"
        return 1
    fi

    # Check if the function handles docker backend
    if grep -A10 "worker_backend_delete()" "$script_path" | grep -q "container_remove_worker"; then
        log_pass "worker_backend_delete calls container_remove_worker for docker backend"
    else
        log_fail "worker_backend_delete should call container_remove_worker for docker backend"
        return 1
    fi
}

# ============================================================
# Test: container-api.sh has container_remove_worker function
# ============================================================
test_container_api_has_remove() {
    log_section "Test: container-api.sh has container_remove_worker function"

    local script_path="${PROJECT_ROOT}/scripts/lib/container-api.sh"

    # Check if the script has container_remove_worker function
    if grep -q "container_remove_worker()" "$script_path"; then
        log_pass "container-api.sh has 'container_remove_worker' function"
    else
        log_fail "container-api.sh missing 'container_remove_worker' function"
        return 1
    fi
}

# ============================================================
# Test Summary
# ============================================================
test_summary() {
    echo ""
    echo "========================================"
    echo "  Test Summary"
    echo "========================================"
    echo "  Total:  ${TESTS_TOTAL}"
    echo -e "  ${GREEN}Passed: ${TESTS_PASSED}${NC}"
    echo -e "  ${RED}Failed: ${TESTS_FAILED}${NC}"
    echo "========================================"

    if [ ${TESTS_FAILED} -gt 0 ]; then
        return 1
    fi
    return 0
}

# ============================================================
# Main
# ============================================================
main() {
    log_section "Running lifecycle-worker.sh unit tests"

    # Run all tests
    test_container_api_has_remove
    test_container_api_has_delete
    test_lifecycle_has_delete_action
    test_delete_requires_worker_arg
    test_usage_includes_delete
    test_delete_checks_registry
    test_delete_outputs_json_for_remote
    test_delete_outputs_json_for_errors

    # Print summary
    test_summary
}

main "$@"
