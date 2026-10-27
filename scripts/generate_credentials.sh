#!/bin/bash
# Generate Credentials.swift from .env.local and inject FIREBASE_API_KEY
# into the built app's GoogleService-Info.plist.
#
# Invoked from a Run Script build phase on each Bank example app target.
# Expects the Xcode-provided env vars SRCROOT, DERIVED_FILE_DIR,
# BUILT_PRODUCTS_DIR, and TARGET_NAME. Walks up from SRCROOT until it finds
# the repo root (marker: GiniMobile.xcworkspace), then reads .env.local.

set -eu

: "${SRCROOT:?SRCROOT is required}"
# Output file lives inside each target's project tree under Generated/.
# The directory is gitignored; the file is the compile-time source of
# truth for the Credentials enum.
OUTPUT_DIR="${CREDENTIALS_OUTPUT_DIR:-$SRCROOT/Generated}"
OUTPUT_FILE="$OUTPUT_DIR/Credentials.swift"

# .env.local lives next to the Xcode project (per-project pattern).
# One file per Xcode project means Bank and Health keep their creds
# fully separated — PP-1073 touches only this file; PP-3923 touches
# only Health's.
env_file="$SRCROOT/.env.local"
if [ ! -f "$env_file" ]; then
    echo "error: .env.local not found at $env_file. Copy $SRCROOT/.env.example and fill in your credentials." >&2
    exit 1
fi

# Required keys — must be present and non-empty for any build to succeed.
# CX and stage keys are intentionally optional: the TestFlight CI pipeline
# does not inject CX secrets today (Firebase-published builds do), and the
# local Stage toggle is a dev-only switch. Empty values for optional keys
# produce empty-string Credentials.* members, which the app handles by
# falling through to its existing empty-Client auth-failure path.
required_keys=(
    GINI_CLIENT_ID
    GINI_CLIENT_PASSWORD
    GINI_CLIENT_DOMAIN
    FIREBASE_API_KEY
)
optional_keys=(
    GINI_CX_CLIENT_ID
    GINI_CX_CLIENT_PASSWORD
    GINI_STAGE_CLIENT_ID
    GINI_STAGE_CLIENT_PASSWORD
)

read_env_value() {
    local key="$1"
    local line
    line="$(grep -E "^${key}=" "$env_file" | tail -n 1 || true)"
    [ -n "$line" ] || { echo ""; return; }
    echo "${line#${key}=}"
}

escape_swift_string() {
    local raw="$1"
    local escaped="${raw//\\/\\\\}"
    escaped="${escaped//\"/\\\"}"
    printf '%s' "$escaped"
}

missing=()
for key in "${required_keys[@]}"; do
    value="$(read_env_value "$key")"
    if [ -z "$value" ]; then
        missing+=("$key")
    fi
done

if [ "${#missing[@]}" -gt 0 ]; then
    IFS=,; echo "error: .env.local missing required keys: ${missing[*]}" >&2; unset IFS
    exit 1
fi

GINI_CLIENT_ID_VALUE=$(escape_swift_string "$(read_env_value GINI_CLIENT_ID)")
GINI_CLIENT_PASSWORD_VALUE=$(escape_swift_string "$(read_env_value GINI_CLIENT_PASSWORD)")
GINI_CLIENT_DOMAIN_VALUE=$(escape_swift_string "$(read_env_value GINI_CLIENT_DOMAIN)")
GINI_CX_CLIENT_ID_VALUE=$(escape_swift_string "$(read_env_value GINI_CX_CLIENT_ID)")
GINI_CX_CLIENT_PASSWORD_VALUE=$(escape_swift_string "$(read_env_value GINI_CX_CLIENT_PASSWORD)")
GINI_STAGE_CLIENT_ID_VALUE=$(escape_swift_string "$(read_env_value GINI_STAGE_CLIENT_ID)")
GINI_STAGE_CLIENT_PASSWORD_VALUE=$(escape_swift_string "$(read_env_value GINI_STAGE_CLIENT_PASSWORD)")
FIREBASE_API_KEY_VALUE="$(read_env_value FIREBASE_API_KEY)"

mkdir -p "$OUTPUT_DIR"

cat > "$OUTPUT_FILE" <<SWIFT
// GENERATED — do not edit. Regenerated on every build from .env.local by
// scripts/generate_credentials.sh. Any change here will be overwritten.
import Foundation

/** Build-time credentials sourced from .env.local. */
enum Credentials {
    static let clientID = "$GINI_CLIENT_ID_VALUE"
    static let clientPassword = "$GINI_CLIENT_PASSWORD_VALUE"
    static let clientDomain = "$GINI_CLIENT_DOMAIN_VALUE"
    static let cxClientID = "$GINI_CX_CLIENT_ID_VALUE"
    static let cxClientPassword = "$GINI_CX_CLIENT_PASSWORD_VALUE"
    static let stageClientID = "$GINI_STAGE_CLIENT_ID_VALUE"
    static let stageClientPassword = "$GINI_STAGE_CLIENT_PASSWORD_VALUE"
}
SWIFT

# Inject the Firebase API_KEY into the built .app bundle's plist. Running
# post-copy means the source-tree plist stays with its empty placeholder.
if [ -n "${BUILT_PRODUCTS_DIR:-}" ] && [ -n "${TARGET_NAME:-}" ]; then
    plist="$BUILT_PRODUCTS_DIR/$TARGET_NAME.app/GoogleService-Info.plist"
    if [ -f "$plist" ]; then
        plutil -replace API_KEY -string "$FIREBASE_API_KEY_VALUE" "$plist"
    fi
fi
