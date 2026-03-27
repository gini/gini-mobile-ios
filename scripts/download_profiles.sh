#!/usr/bin/env bash
# download_profiles.sh — Fetch all App Store provisioning profiles from Match.
#
# Usage:
#   ./scripts/download_profiles.sh
#
# Required env var:
#   MATCH_PASSWORD — encryption password for the certificates repo (ask your team lead)
#
# Optional env var:
#   MATCH_GIT_URL  — override the certificates repo URL
#                   (default: https://github.com/gini/ios-certificates)

set -euo pipefail

GIT_URL="${MATCH_GIT_URL:-https://github.com/gini/ios-certificates}"

if [[ -z "${MATCH_PASSWORD:-}" ]]; then
  echo "❌ MATCH_PASSWORD is not set. Ask your team lead."
  exit 1
fi

# All bundle IDs managed by Match — add new ones here as apps are onboarded
ALL_IDS=(
  "net.gini.banksdk.example"
  "net.gini.banksdk.example.ShareExtension"
)

BUNDLE_IDS=$(IFS=,; echo "${ALL_IDS[*]}")

echo "📥 Downloading AppStore profiles for: $BUNDLE_IDS"

MATCH_PASSWORD="$MATCH_PASSWORD" \
bundle exec fastlane match appstore \
  --git_url "$GIT_URL" \
  --app_identifier "$BUNDLE_IDS" \
  --readonly true

echo "✅ Profiles installed successfully."
