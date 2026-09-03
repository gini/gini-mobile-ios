#!/bin/bash
set -euo pipefail

# ─── Usage ────────────────────────────────────────────────────────────────────
# Upload only (IPA already built):
#   ./scripts/upload_to_testflight.sh
#   ./scripts/upload_to_testflight.sh path/to/App.ipa
#
# Build + upload in one step:
#   ./scripts/upload_to_testflight.sh --build

# ─── Configuration ────────────────────────────────────────────────────────────
API_KEY_ID="${APP_STORE_CONNECT_API_KEY_ID:-}"
API_ISSUER_ID="${APP_STORE_CONNECT_API_ISSUER_ID:-}"
API_KEY_PATH="${APP_STORE_CONNECT_API_KEY_PATH:-build_artifacts/AppStoreConnectAPIKey.p8}"

# ─── Validation ───────────────────────────────────────────────────────────────
if [[ -z "$API_KEY_ID" ]]; then
  echo "❌ APP_STORE_CONNECT_API_KEY_ID is not set."
  exit 1
fi

if [[ -z "$API_ISSUER_ID" ]]; then
  echo "❌ APP_STORE_CONNECT_API_ISSUER_ID is not set."
  exit 1
fi

if [[ ! -f "$API_KEY_PATH" ]]; then
  echo "❌ App Store Connect API key not found at: $API_KEY_PATH"
  echo "   Set APP_STORE_CONNECT_API_KEY_PATH or place the .p8 file there."
  exit 1
fi

# ─── Run ──────────────────────────────────────────────────────────────────────
export APP_STORE_CONNECT_API_KEY_ID="$API_KEY_ID"
export APP_STORE_CONNECT_API_ISSUER_ID="$API_ISSUER_ID"
export APP_STORE_CONNECT_API_KEY_PATH="$API_KEY_PATH"

if [[ "${1:-}" == "--build" ]]; then
  echo "🔨 Building IPA and uploading to TestFlight..."
  bundle exec fastlane build_and_upload_to_testflight \
    project:"BankSDK/GiniBankSDKExample/GiniBankSDKExample.xcodeproj" \
    scheme:"GiniBankSDKExample" \
    ipa_name:"GiniBankSDKExample" \
    provisioning_profiles:'{"net.gini.banksdk.example":"match AppStore net.gini.banksdk.example","net.gini.banksdk.example.ShareExtension":"match AppStore net.gini.banksdk.example.ShareExtension"}'
else
  IPA_PATH="${1:-GiniBankSDKExample.ipa}"
  if [[ ! -f "$IPA_PATH" ]]; then
    echo "❌ IPA not found at: $IPA_PATH"
    echo "   Run with --build to build the IPA first, or pass the IPA path as an argument."
    exit 1
  fi
  echo "🚀 Uploading $IPA_PATH to TestFlight..."
  bundle exec fastlane publish_to_testflight ipa_path:"$IPA_PATH"
fi

echo "✅ Done!"
