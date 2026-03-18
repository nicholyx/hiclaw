#!/bin/bash
# Unit test for max_tokens parameter handling for GPT-5 models
#
# This is a LOCAL unit test that tests the _get_max_tokens_param function
# behavior and JSON body generation. It does NOT require a running system.
#
# Run: ./tests/unit/test-max-tokens-param.sh

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PASSED=0
FAILED=0

pass() {
    echo -e "${GREEN}✓ PASS${NC}: $1"
    PASSED=$((PASSED + 1))
}

fail() {
    echo -e "${RED}✗ FAIL${NC}: $1"
    FAILED=$((FAILED + 1))
}

# ============================================================
# Test 1: Test _get_max_tokens_param function
# ============================================================
echo -e "\n${YELLOW}=== Test 1: _get_max_tokens_param function ===${NC}\n"

# Define the function (copy from hiclaw-install.sh)
_get_max_tokens_param() {
    local model="$1"
    # Match gpt-5, gpt-5.4, gpt-5-mini, gpt-5-nano, etc.
    if [[ "${model}" =~ ^gpt-5(\.|-|[0-9]|$) ]]; then
        echo "max_completion_tokens"
    else
        echo "max_tokens"
    fi
}

# Test cases for _get_max_tokens_param (format: "model:expected")
TEST_CASES=(
    "gpt-5:max_completion_tokens"
    "gpt-5.4:max_completion_tokens"
    "gpt-5-mini:max_completion_tokens"
    "gpt-5-nano:max_completion_tokens"
    "gpt-5-turbo:max_completion_tokens"
    "gpt-5.1:max_completion_tokens"
    "gpt-5-2024-01-01:max_completion_tokens"
    "gpt-4:max_tokens"
    "gpt-4o:max_tokens"
    "gpt-4-turbo:max_tokens"
    "gpt-3.5-turbo:max_tokens"
    "claude-3-opus:max_tokens"
    "claude-3-sonnet:max_tokens"
    "gemini-pro:max_tokens"
    "deepseek-chat:max_tokens"
)

for test_case in "${TEST_CASES[@]}"; do
    model="${test_case%%:*}"
    expected="${test_case##*:}"
    actual=$(_get_max_tokens_param "$model")
    if [[ "$actual" == "$expected" ]]; then
        pass "_get_max_tokens_param('$model') = '$actual'"
    else
        fail "_get_max_tokens_param('$model') expected '$expected', got '$actual'"
    fi
done

# ============================================================
# Test 2: Test JSON body generation
# ============================================================
echo -e "\n${YELLOW}=== Test 2: JSON body generation ===${NC}\n"

test_json_body() {
    local model="$1"
    local expected_param="$2"

    local max_tokens_param=$(_get_max_tokens_param "${model}")
    local json_body="{\"model\":\"${model}\",\"messages\":[{\"role\":\"user\",\"content\":\"hi\"}],\"${max_tokens_param}\":1}"

    # Verify JSON is valid
    if echo "$json_body" | jq . > /dev/null 2>&1; then
        pass "Valid JSON for $model"
    else
        fail "Invalid JSON for $model: $json_body"
        return
    fi

    # Verify correct parameter is used
    local actual_param=$(echo "$json_body" | jq -r 'keys | .[]' | grep -E 'max_tokens|max_completion_tokens')
    if [[ "$actual_param" == "$expected_param" ]]; then
        pass "Correct param '$expected_param' in JSON for $model"
    else
        fail "Wrong param in JSON for $model: expected '$expected_param', got '$actual_param'"
    fi
}

# Test JSON generation for key models
test_json_body "gpt-5" "max_completion_tokens"
test_json_body "gpt-5.4" "max_completion_tokens"
test_json_body "gpt-5-mini" "max_completion_tokens"
test_json_body "gpt-4o" "max_tokens"
test_json_body "claude-3-opus" "max_tokens"


# ============================================================
# Summary
# ============================================================
echo -e "\n${YELLOW}=== Summary ===${NC}\n"
echo -e "Passed: ${GREEN}$PASSED${NC}"
echo -e "Failed: ${RED}$FAILED${NC}"

if [[ $FAILED -eq 0 ]]; then
    echo -e "\n${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "\n${RED}Some tests failed!${NC}"
    exit 1
fi
