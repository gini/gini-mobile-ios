#!/bin/bash
# Shell-level tests for scripts/generate_credentials.sh.
# Run manually: ./scripts/test_generate_credentials.sh
#
# Covers R1 (happy path), R3 (missing .env.local), R4 (missing / multiple
# missing keys), R5 (Firebase API_KEY injection + other fields untouched).

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
GENERATOR="$SCRIPT_DIR/generate_credentials.sh"

tmp_root=""
pass=0
fail=0

cleanup() {
    [ -n "$tmp_root" ] && rm -rf "$tmp_root"
}
trap cleanup EXIT

setup_case() {
    local case_name="$1"
    tmp_root="$(mktemp -d)"
    export BUILT_PRODUCTS_DIR="$tmp_root/build"
    export TARGET_NAME="MockTarget"
    mkdir -p "$BUILT_PRODUCTS_DIR/$TARGET_NAME.app"
    mkdir -p "$tmp_root/BankSDK/GiniBankSDKExample"
    export SRCROOT="$tmp_root/BankSDK/GiniBankSDKExample"
    echo "── $case_name ──"
}

teardown_case() {
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

assert_file_contains() {
    local file="$1"
    local needle="$2"
    local label="$3"
    if [ -f "$file" ] && grep -Fq "$needle" "$file"; then
        pass=$((pass + 1))
        echo "  ✓ $label"
    else
        fail=$((fail + 1))
        echo "  ✗ $label — $file missing or does not contain: $needle"
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

write_fixture_env() {
    local path="$1"
    cat > "$path" <<ENV
GINI_CLIENT_ID=the-client-id
GINI_CLIENT_PASSWORD=the-client-password
GINI_CLIENT_DOMAIN=example.com
GINI_CX_CLIENT_ID=the-cx-id
GINI_CX_CLIENT_PASSWORD=the-cx-password
GINI_STAGE_CLIENT_ID=the-stage-id
GINI_STAGE_CLIENT_PASSWORD=the-stage-password
FIREBASE_API_KEY=the-firebase-key
ENV
}

write_fixture_plist() {
    local plist="$1"
    cat > "$plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>API_KEY</key>
    <string></string>
    <key>BUNDLE_ID</key>
    <string>net.gini.banksdk.example</string>
    <key>GOOGLE_APP_ID</key>
    <string>1:111222333:ios:aaaaaaaaa</string>
</dict>
</plist>
PLIST
}

# ───── Case 1: happy path ─────
setup_case "Case 1: happy path"
write_fixture_env "$SRCROOT/.env.local"
write_fixture_plist "$BUILT_PRODUCTS_DIR/$TARGET_NAME.app/GoogleService-Info.plist"
stderr_file="$tmp_root/stderr.txt"
"$GENERATOR" 2>"$stderr_file"
rc=$?
assert_exit_code $rc 0 "generator exits 0"
assert_file_contains "$SRCROOT/Generated/Credentials.swift" '"the-client-id"' "clientID written"
assert_file_contains "$SRCROOT/Generated/Credentials.swift" '"the-client-password"' "clientPassword written"
assert_file_contains "$SRCROOT/Generated/Credentials.swift" '"example.com"' "clientDomain written"
assert_file_contains "$SRCROOT/Generated/Credentials.swift" '"the-cx-id"' "cxClientID written"
assert_file_contains "$SRCROOT/Generated/Credentials.swift" '"the-stage-password"' "stageClientPassword written"
teardown_case

# ───── Case 2: missing .env.local ─────
setup_case "Case 2: missing .env.local"
stderr_file="$tmp_root/stderr.txt"
"$GENERATOR" 2>"$stderr_file"
rc=$?
assert_exit_code $rc 1 "generator exits 1"
assert_stderr_contains "$stderr_file" ".env.local not found" "stderr names missing env file"
teardown_case

# ───── Case 3: missing required key (FIREBASE_API_KEY) ─────
setup_case "Case 3: missing required key (FIREBASE_API_KEY)"
cat > "$SRCROOT/.env.local" <<ENV
GINI_CLIENT_ID=x
GINI_CLIENT_PASSWORD=x
GINI_CLIENT_DOMAIN=x
GINI_CX_CLIENT_ID=
GINI_CX_CLIENT_PASSWORD=
GINI_STAGE_CLIENT_ID=
GINI_STAGE_CLIENT_PASSWORD=
FIREBASE_API_KEY=
ENV
stderr_file="$tmp_root/stderr.txt"
"$GENERATOR" 2>"$stderr_file"
rc=$?
assert_exit_code $rc 1 "generator exits 1"
assert_stderr_contains "$stderr_file" "FIREBASE_API_KEY" "stderr names missing FIREBASE_API_KEY"
teardown_case

# ───── Case 4: multiple missing required keys ─────
setup_case "Case 4: multiple missing required keys"
cat > "$SRCROOT/.env.local" <<ENV
GINI_CLIENT_ID=
GINI_CLIENT_PASSWORD=
GINI_CLIENT_DOMAIN=x
GINI_CX_CLIENT_ID=
GINI_CX_CLIENT_PASSWORD=x
GINI_STAGE_CLIENT_ID=
GINI_STAGE_CLIENT_PASSWORD=
FIREBASE_API_KEY=y
ENV
stderr_file="$tmp_root/stderr.txt"
"$GENERATOR" 2>"$stderr_file"
rc=$?
assert_exit_code $rc 1 "generator exits 1"
assert_stderr_contains "$stderr_file" "GINI_CLIENT_ID" "stderr names GINI_CLIENT_ID"
assert_stderr_contains "$stderr_file" "GINI_CLIENT_PASSWORD" "stderr names GINI_CLIENT_PASSWORD"
teardown_case

# ───── Case 4b: optional keys empty still succeeds ─────
setup_case "Case 4b: optional keys empty still succeeds"
cat > "$SRCROOT/.env.local" <<ENV
GINI_CLIENT_ID=x
GINI_CLIENT_PASSWORD=x
GINI_CLIENT_DOMAIN=x
GINI_CX_CLIENT_ID=
GINI_CX_CLIENT_PASSWORD=
GINI_STAGE_CLIENT_ID=
GINI_STAGE_CLIENT_PASSWORD=
FIREBASE_API_KEY=y
ENV
stderr_file="$tmp_root/stderr.txt"
"$GENERATOR" 2>"$stderr_file"
rc=$?
assert_exit_code $rc 0 "generator exits 0 with empty optional keys"
assert_file_contains "$SRCROOT/Generated/Credentials.swift" 'cxClientID = ""' "cxClientID is empty string"
teardown_case

# ───── Case 5: Firebase API_KEY injected ─────
setup_case "Case 5: Firebase API_KEY injected"
write_fixture_env "$SRCROOT/.env.local"
write_fixture_plist "$BUILT_PRODUCTS_DIR/$TARGET_NAME.app/GoogleService-Info.plist"
stderr_file="$tmp_root/stderr.txt"
"$GENERATOR" 2>"$stderr_file"
rc=$?
assert_exit_code $rc 0 "generator exits 0"
injected=$(plutil -extract API_KEY raw "$BUILT_PRODUCTS_DIR/$TARGET_NAME.app/GoogleService-Info.plist" 2>/dev/null)
if [ "$injected" = "the-firebase-key" ]; then
    pass=$((pass + 1))
    echo "  ✓ API_KEY replaced with env value"
else
    fail=$((fail + 1))
    echo "  ✗ API_KEY not replaced — got: $injected"
fi
teardown_case

# ───── Case 6: Firebase plist other fields untouched ─────
setup_case "Case 6: other plist fields untouched"
write_fixture_env "$SRCROOT/.env.local"
write_fixture_plist "$BUILT_PRODUCTS_DIR/$TARGET_NAME.app/GoogleService-Info.plist"
"$GENERATOR" 2>/dev/null
bundle_id=$(plutil -extract BUNDLE_ID raw "$BUILT_PRODUCTS_DIR/$TARGET_NAME.app/GoogleService-Info.plist")
google_app_id=$(plutil -extract GOOGLE_APP_ID raw "$BUILT_PRODUCTS_DIR/$TARGET_NAME.app/GoogleService-Info.plist")
if [ "$bundle_id" = "net.gini.banksdk.example" ]; then
    pass=$((pass + 1))
    echo "  ✓ BUNDLE_ID preserved"
else
    fail=$((fail + 1))
    echo "  ✗ BUNDLE_ID changed — got: $bundle_id"
fi
if [ "$google_app_id" = "1:111222333:ios:aaaaaaaaa" ]; then
    pass=$((pass + 1))
    echo "  ✓ GOOGLE_APP_ID preserved"
else
    fail=$((fail + 1))
    echo "  ✗ GOOGLE_APP_ID changed — got: $google_app_id"
fi
teardown_case

echo
echo "Result: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
