#!/bin/bash
# test-install-context-window-params.sh
# Unit tests for install script contextWindow and maxTokens handling
#
# Usage: bash manager/tests/test-install-context-window-params.sh
#
# Tests that the install script properly handles HICLAW_MODEL_CONTEXT_WINDOW
# and HICLAW_MODEL_MAX_TOKENS environment variables for custom models.
#
# Issue: https://github.com/higress-group/hiclaw/issues/346

set -uo pipefail

PASS=0
FAIL=0
TMPDIR_ROOT=$(mktemp -d)
trap 'rm -rf "${TMPDIR_ROOT}"' EXIT

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${SCRIPT_DIR}/../../install"

# ── Test helpers ──────────────────────────────────────────────────────────────
pass() { echo "  PASS: $1"; PASS=$(( PASS + 1 )); }
fail() { echo "  FAIL: $1"; echo "       expected: $2"; echo "       got:      $3"; FAIL=$(( FAIL + 1 )); }

assert_eq() {
    local desc="$1" expected="$2" actual="$3"
    if [ "${expected}" = "${actual}" ]; then
        pass "${desc}"
    else
        fail "${desc}" "${expected}" "${actual}"
    fi
}

assert_contains() {
    local desc="$1" needle="$2" haystack="$3"
    if echo "${haystack}" | grep -qF "${needle}"; then
        pass "${desc}"
    else
        fail "${desc}" "contains '${needle}'" "not found"
    fi
}

new_workdir() {
    mktemp -d "${TMPDIR_ROOT}/test-XXXXXX"
}

# ── Tests ─────────────────────────────────────────────────────────────────────

echo ""
echo "=== TC1: Install script supports HICLAW_MODEL_CONTEXT_WINDOW env var ==="
{
    # Check if install script references HICLAW_MODEL_CONTEXT_WINDOW
    install_script="${INSTALL_DIR}/hiclaw-install.sh"
    if [ -f "${install_script}" ]; then
        if grep -q "HICLAW_MODEL_CONTEXT_WINDOW" "${install_script}"; then
            pass "install.sh supports HICLAW_MODEL_CONTEXT_WINDOW"
        else
            fail "install.sh supports HICLAW_MODEL_CONTEXT_WINDOW" "variable referenced" "not found in script"
        fi
    else
        fail "install.sh exists" "file found" "file not found"
    fi
}

echo ""
echo "=== TC2: Install script supports HICLAW_MODEL_MAX_TOKENS env var ==="
{
    install_script="${INSTALL_DIR}/hiclaw-install.sh"
    if [ -f "${install_script}" ]; then
        if grep -q "HICLAW_MODEL_MAX_TOKENS" "${install_script}"; then
            pass "install.sh supports HICLAW_MODEL_MAX_TOKENS"
        else
            fail "install.sh supports HICLAW_MODEL_MAX_TOKENS" "variable referenced" "not found in script"
        fi
    else
        fail "install.sh exists" "file found" "file not found"
    fi
}

echo ""
echo "=== TC3: start-manager-agent.sh reads HICLAW_MODEL_CONTEXT_WINDOW ==="
{
    start_script="${SCRIPT_DIR}/../scripts/init/start-manager-agent.sh"
    if [ -f "${start_script}" ]; then
        if grep -q "HICLAW_MODEL_CONTEXT_WINDOW" "${start_script}"; then
            pass "start-manager-agent.sh reads HICLAW_MODEL_CONTEXT_WINDOW"
        else
            fail "start-manager-agent.sh reads HICLAW_MODEL_CONTEXT_WINDOW" "variable referenced" "not found in script"
        fi
    else
        fail "start-manager-agent.sh exists" "file found" "file not found"
    fi
}

echo ""
echo "=== TC4: start-manager-agent.sh reads HICLAW_MODEL_MAX_TOKENS ==="
{
    start_script="${SCRIPT_DIR}/../scripts/init/start-manager-agent.sh"
    if [ -f "${start_script}" ]; then
        if grep -q "HICLAW_MODEL_MAX_TOKENS" "${start_script}"; then
            pass "start-manager-agent.sh reads HICLAW_MODEL_MAX_TOKENS"
        else
            fail "start-manager-agent.sh reads HICLAW_MODEL_MAX_TOKENS" "variable referenced" "not found in script"
        fi
    else
        fail "start-manager-agent.sh exists" "file found" "file not found"
    fi
}

echo ""
echo "=== TC5: PowerShell install script supports context window params ==="
{
    ps_script="${INSTALL_DIR}/hiclaw-install.ps1"
    if [ -f "${ps_script}" ]; then
        if grep -q "HICLAW_MODEL_CONTEXT_WINDOW" "${ps_script}"; then
            pass "hiclaw-install.ps1 supports HICLAW_MODEL_CONTEXT_WINDOW"
        else
            fail "hiclaw-install.ps1 supports HICLAW_MODEL_CONTEXT_WINDOW" "variable referenced" "not found in script"
        fi
    else
        fail "hiclaw-install.ps1 exists" "file found" "file not found"
    fi
}

echo ""
echo "=== TC6: PowerShell install script supports max tokens params ==="
{
    ps_script="${INSTALL_DIR}/hiclaw-install.ps1"
    if [ -f "${ps_script}" ]; then
        if grep -q "HICLAW_MODEL_MAX_TOKENS" "${ps_script}"; then
            pass "hiclaw-install.ps1 supports HICLAW_MODEL_MAX_TOKENS"
        else
            fail "hiclaw-install.ps1 supports HICLAW_MODEL_MAX_TOKENS" "variable referenced" "not found in script"
        fi
    else
        fail "hiclaw-install.ps1 exists" "file found" "file not found"
    fi
}

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo "================================"
echo "Results: ${PASS} passed, ${FAIL} failed"
echo "================================"
echo ""
echo "Note: These tests verify that the install scripts support"
echo "HICLAW_MODEL_CONTEXT_WINDOW and HICLAW_MODEL_MAX_TOKENS env vars."
echo "If tests fail, the scripts need to be updated to support these variables."
[ "${FAIL}" -eq 0 ]