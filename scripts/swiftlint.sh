#!/bin/bash
# SwiftLint runner for gini-mobile-ios
#
# Usage:
#   ./scripts/swiftlint.sh           — lint with warnings only
#   ./scripts/swiftlint.sh --strict  — fail on warnings (use in CI)
#   ./scripts/swiftlint.sh --fix     — auto-correct fixable violations
#
# The script resolves the project root regardless of where it is called from.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG="${ROOT_DIR}/.swiftlint.yml"
MODE="${1:-}"

# ── Locate SwiftLint ──────────────────────────────────────────────────────────
if which swiftlint > /dev/null 2>&1; then
  SWIFTLINT="swiftlint"
elif which mint > /dev/null 2>&1 && mint which swiftlint > /dev/null 2>&1; then
  SWIFTLINT="mint run swiftlint swiftlint"
else
  echo "❌  SwiftLint not found."
  echo "    Install via Homebrew:  brew install swiftlint"
  echo "    Install via Mint:      mint install realm/SwiftLint"
  exit 1
fi

# ── Run ───────────────────────────────────────────────────────────────────────
echo "🔍  SwiftLint — project root: ${ROOT_DIR}"
echo "    Config:  ${CONFIG}"
echo "    Mode:    ${MODE:-default (warnings)}"
echo ""

cd "$ROOT_DIR"

case "$MODE" in
  --fix)
    $SWIFTLINT --fix --config "$CONFIG"
    echo ""
    echo "✅  Auto-correct complete."
    ;;
  --strict)
    $SWIFTLINT lint --strict --config "$CONFIG"
    echo ""
    echo "✅  Lint passed (strict mode)."
    ;;
  "")
    $SWIFTLINT lint --config "$CONFIG"
    echo ""
    echo "✅  Lint complete."
    ;;
  *)
    echo "❌  Unknown option: $MODE"
    echo "    Usage: $0 [--strict | --fix]"
    exit 1
    ;;
esac
