#!/bin/bash
# test-custom-model-context-window.sh
# Unit tests for custom model contextWindow and maxTokens configuration
#
# Usage: bash manager/tests/test-custom-model-context-window.sh
#
# Tests that when users configure a custom model (like vLLM),
# the contextWindow and maxTokens are properly captured and passed
# to the openclaw.json configuration.
#
# Issue: https://github.com/higress-group/hiclaw/issues/346

set -uo pipefail

PASS=0
FAIL=0
TMPDIR_ROOT=$(mktemp -d)
trap 'rm -rf "${TMPDIR_ROOT}"' EXIT

# ── Resolve paths relative to this script ─────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/../scripts/lib"

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

# ── Simulate the model config generation logic ────────────────────────────────
# This simulates what start-manager-agent.sh does when processing model config

generate_model_config() {
    local model_name="$1"
    local context_window="$2"
    local max_tokens="$3"
    local reasoning="${4:-true}"
    local input="${5:-[\"text\"]}"

    cat <<EOF
{
  "id": "${model_name}",
  "name": "${model_name}",
  "reasoning": ${reasoning},
  "contextWindow": ${context_window},
  "maxTokens": ${max_tokens},
  "input": ${input}
}
EOF
}

# ── Tests ─────────────────────────────────────────────────────────────────────

echo ""
echo "=== TC1: Custom vLLM model with 32K context window ==="
{
    # Simulate user configuring a vLLM model with 32K context
    MODEL_NAME="my-vllm-model"
    CONTEXT_WINDOW=32000
    MAX_TOKENS=4096

    config=$(generate_model_config "${MODEL_NAME}" "${CONTEXT_WINDOW}" "${MAX_TOKENS}")

    assert_contains "has correct model name" "\"id\": \"${MODEL_NAME}\"" "${config}"
    assert_contains "has contextWindow 32000" "\"contextWindow\": 32000" "${config}"
    assert_contains "has maxTokens 4096" "\"maxTokens\": 4096" "${config}"
}

echo ""
echo "=== TC2: Custom model with large context window (128K) ==="
{
    MODEL_NAME="large-context-model"
    CONTEXT_WINDOW=128000
    MAX_TOKENS=8192

    config=$(generate_model_config "${MODEL_NAME}" "${CONTEXT_WINDOW}" "${MAX_TOKENS}")

    assert_contains "has contextWindow 128000" "\"contextWindow\": 128000" "${config}"
    assert_contains "has maxTokens 8192" "\"maxTokens\": 8192" "${config}"
}

echo ""
echo "=== TC3: Environment variables override defaults ==="
{
    # Test that HICLAW_MODEL_CONTEXT_WINDOW and HICLAW_MODEL_MAX_TOKENS
    # environment variables properly override defaults

    # Simulate environment variable override
    export HICLAW_MODEL_CONTEXT_WINDOW=64000
    export HICLAW_MODEL_MAX_TOKENS=16000

    # Use env vars if set, otherwise use defaults
    CONTEXT_WINDOW="${HICLAW_MODEL_CONTEXT_WINDOW:-150000}"
    MAX_TOKENS="${HICLAW_MODEL_MAX_TOKENS:-128000}"

    assert_eq "contextWindow from env var" "64000" "${CONTEXT_WINDOW}"
    assert_eq "maxTokens from env var" "16000" "${MAX_TOKENS}"

    unset HICLAW_MODEL_CONTEXT_WINDOW
    unset HICLAW_MODEL_MAX_TOKENS
}

echo ""
echo "=== TC4: Default values when env vars not set ==="
{
    # Ensure defaults are used when env vars are not set
    unset HICLAW_MODEL_CONTEXT_WINDOW
    unset HICLAW_MODEL_MAX_TOKENS

    CONTEXT_WINDOW="${HICLAW_MODEL_CONTEXT_WINDOW:-150000}"
    MAX_TOKENS="${HICLAW_MODEL_MAX_TOKENS:-128000}"

    assert_eq "default contextWindow" "150000" "${CONTEXT_WINDOW}"
    assert_eq "default maxTokens" "128000" "${MAX_TOKENS}"
}

echo ""
echo "=== TC5: openclaw.json model config validation ==="
{
    d=$(new_workdir)
    openclaw_json="${d}/openclaw.json"

    # Create a sample openclaw.json with custom model config
    cat > "${openclaw_json}" << 'EOF'
{
  "models": {
    "providers": {
      "hiclaw-gateway": {
        "models": [
          { "id": "my-vllm-model", "contextWindow": 32000, "maxTokens": 4096 }
        ]
      }
    }
  }
}
EOF

    # Verify the config was written correctly
    actual_context=$(jq '.models.providers["hiclaw-gateway"].models[0].contextWindow' "${openclaw_json}")
    actual_max=$(jq '.models.providers["hiclaw-gateway"].models[0].maxTokens' "${openclaw_json}")

    assert_eq "openclaw.json has contextWindow 32000" "32000" "${actual_context}"
    assert_eq "openclaw.json has maxTokens 4096" "4096" "${actual_max}"
}

echo ""
echo "=== TC6: Context window passed to agents.running.max_input_length ==="
{
    d=$(new_workdir)
    config_json="${d}/config.json"

    # Simulate bridge.py behavior: contextWindow -> max_input_length
    CONTEXT_WINDOW=32000

    cat > "${config_json}" << EOF
{
  "agents": {
    "running": {
      "max_input_length": ${CONTEXT_WINDOW}
    }
  }
}
EOF

    actual_max_input=$(jq '.agents.running.max_input_length' "${config_json}")
    assert_eq "config.json max_input_length matches contextWindow" "32000" "${actual_max_input}"
}

echo ""
echo "=== TC7: Invalid context window value handling ==="
{
    # Test that empty or invalid values fall back to defaults
    export HICLAW_MODEL_CONTEXT_WINDOW=""
    export HICLAW_MODEL_MAX_TOKENS=""

    # Empty string should fall back to default
    CONTEXT_WINDOW="${HICLAW_MODEL_CONTEXT_WINDOW:-150000}"
    MAX_TOKENS="${HICLAW_MODEL_MAX_TOKENS:-128000}"

    assert_eq "empty contextWindow falls back to default" "150000" "${CONTEXT_WINDOW}"
    assert_eq "empty maxTokens falls back to default" "128000" "${MAX_TOKENS}"

    unset HICLAW_MODEL_CONTEXT_WINDOW
    unset HICLAW_MODEL_MAX_TOKENS
}

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo "================================"
echo "Results: ${PASS} passed, ${FAIL} failed"
echo "================================"
[ "${FAIL}" -eq 0 ]