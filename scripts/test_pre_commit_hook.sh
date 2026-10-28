#!/bin/bash
# Shell-level tests for .githooks/pre-commit.
# Run manually: ./scripts/test_pre_commit_hook.sh
# Covers R6 — the hook rejects commits that stage protected paths.

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
HOOK="$REPO_ROOT/.githooks/pre-commit"

tmp_root=""
pass=0
fail=0

cleanup() {
    [ -n "$tmp_root" ] && rm -rf "$tmp_root"
}
trap cleanup EXIT

setup_case() {
    local label="$1"
    tmp_root="$(mktemp -d)"
    cd "$tmp_root"
    git init -q
    git config commit.gpgsign false
    git config user.email "test@example.com"
    git config user.name "Test"
    # Mirror the repo shape so the hook's path patterns match.
    mkdir -p BankSDK/GiniBankSDKExample/GiniBankSDKExample
    mkdir -p BankSDK/GiniBankSDKExample/GiniBankSDKExampleBank
    mkdir -p .githooks
    env_local_path="BankSDK/GiniBankSDKExample/.env.local"
    cp "$HOOK" .githooks/pre-commit
    chmod +x .githooks/pre-commit
    git config core.hooksPath .githooks
    # One benign tracked file so initial commits aren't empty.
    echo seed > README.md
    git add README.md
    git commit -q -m seed
    echo "── $label ──"
}

teardown_case() {
    cd "$SCRIPT_DIR"
    rm -rf "$tmp_root"
    tmp_root=""
}

assert_exit_code() {
    local actual="$1"
    local expected="$2"
    local label="$3"
    if [ "$actual" -eq "$expected" ]; then
        pass=$((pass + 1))
        echo "  ✓ $label (exit=$actual)"
    else
        fail=$((fail + 1))
        echo "  ✗ $label — expected exit=$expected, got exit=$actual"
    fi
}

assert_stderr_contains() {
    local stderr_file="$1"
    local needle="$2"
    local label="$3"
    if grep -Fq "$needle" "$stderr_file"; then
        pass=$((pass + 1))
        echo "  ✓ $label"
    else
        fail=$((fail + 1))
        echo "  ✗ $label — stderr missing: $needle"
        echo "    stderr was:"
        sed 's/^/      /' "$stderr_file"
    fi
}

# ───── Case 1: staging .env.local is rejected ─────
setup_case "Case 1: staging .env.local rejected"
echo "GINI_CLIENT_ID=secret" > "$env_local_path"
git add -f "$env_local_path"
stderr_file="$tmp_root/stderr.txt"
git commit -m "attempt" 2>"$stderr_file"
rc=$?
assert_exit_code $rc 1 "commit rejected"
assert_stderr_contains "$stderr_file" ".env.local" "stderr lists .env.local"
teardown_case

# ───── Case 2: staging a protected Credentials.plist is rejected ─────
setup_case "Case 2: staging Credentials.plist rejected"
plist=BankSDK/GiniBankSDKExample/GiniBankSDKExample/Credentials.plist
echo "<plist/>" > "$plist"
git add -f "$plist"
stderr_file="$tmp_root/stderr.txt"
git commit -m "attempt" 2>"$stderr_file"
rc=$?
assert_exit_code $rc 1 "commit rejected"
assert_stderr_contains "$stderr_file" "Credentials.plist" "stderr lists Credentials.plist"
teardown_case

# ───── Case 3: staging an unrelated file is allowed ─────
setup_case "Case 3: unrelated file allowed"
echo "example" > unrelated.txt
git add unrelated.txt
stderr_file="$tmp_root/stderr.txt"
git commit -m "ok" 2>"$stderr_file"
rc=$?
assert_exit_code $rc 0 "commit allowed"
teardown_case

# ───── Case 4: mixed stage (protected + unrelated) is rejected but names only the protected ─────
setup_case "Case 4: mixed staging — only protected is named"
echo "benign" > docs.md
echo "secret" > "$env_local_path"
git add docs.md
git add -f "$env_local_path"
stderr_file="$tmp_root/stderr.txt"
git commit -m "attempt" 2>"$stderr_file"
rc=$?
assert_exit_code $rc 1 "commit rejected"
assert_stderr_contains "$stderr_file" ".env.local" "stderr lists .env.local"
if grep -Fq "docs.md" "$stderr_file"; then
    fail=$((fail + 1))
    echo "  ✗ stderr incorrectly mentions docs.md"
else
    pass=$((pass + 1))
    echo "  ✓ stderr does not mention the unrelated file"
fi
teardown_case

echo
echo "Result: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
