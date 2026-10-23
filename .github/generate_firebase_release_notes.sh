#!/bin/bash
# Generates a plain-text release note for Firebase App Distribution.
# Format and rationale: .github/firebase-release-notes-sample.md
#
# Required env: APP_NAME, BUILD, BRANCH, HEAD_SHA, AUTHOR
# Optional env: PR_NUMBER, PR_BODY, BASE_SHA
# Writes to stdout; caller redirects to release_notes.txt.

set -euo pipefail

# Workflow checkout is shallow (fetch-depth: 3) — pull the base commit so the
# base..head range resolves on long-lived PRs. Harmless if it fails.
if [[ -n "${BASE_SHA:-}" ]]; then
  git fetch --no-tags --quiet --depth=50 origin "$BASE_SHA" 2>/dev/null || true
fi

# Resolve the commit range used to derive Jira / Changes.
if [[ -n "${BASE_SHA:-}" ]] && git cat-file -e "$BASE_SHA" 2>/dev/null; then
  RANGE="${BASE_SHA}..${HEAD_SHA}"
else
  LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || true)
  if [[ -n "$LAST_TAG" ]]; then
    RANGE="${LAST_TAG}..HEAD"
  else
    RANGE="HEAD~10..HEAD"
  fi
fi

# Jira key from the latest commit in the range. Repo convention puts the
# authoritative ticket on the last line of the commit message, so we read the
# full body and take the last match.
JIRA_KEY=$(git log -1 --no-merges "$RANGE" --pretty=%B 2>/dev/null \
           | grep -oE '[A-Z]+-[0-9]+' | tail -1 || true)

# Jira title = the subject of the first commit in the range that mentions the
# key, with the Conventional-Commit prefix stripped.
JIRA_TITLE=""
if [[ -n "$JIRA_KEY" ]]; then
  MATCHING_SHA=$(git log --no-merges "$RANGE" --grep="$JIRA_KEY" --pretty=%H 2>/dev/null | head -1 || true)
  if [[ -n "$MATCHING_SHA" ]]; then
    JIRA_TITLE=$(git log -1 --pretty=%s "$MATCHING_SHA" \
                 | sed -E 's/^[a-z]+(\(.+\))?:[[:space:]]*//')
  fi
fi

# Changed top-level dirs intersected with the SDK roots we care about.
CHANGES=$(git diff --name-only "$RANGE" 2>/dev/null \
          | awk -F/ '{print $1}' | sort -u \
          | grep -E '^(BankSDK|CaptureSDK|BankAPILibrary|HealthSDK|HealthAPILibrary|GiniComponents)$' \
          | tr '\n' '+' | sed -E 's/\+$//' | sed 's/+/ + /g' || true)

# Focus = first non-empty line under "## What to test" in the PR body.
FOCUS=""
if [[ -n "${PR_BODY:-}" ]]; then
  FOCUS=$(printf '%s\n' "$PR_BODY" | tr -d '\r' \
          | awk 'BEGIN{p=0} /^##[[:space:]]+What to test/{p=1;next} /^##/{p=0} p && NF' \
          | head -1 | sed -E 's/^[-*][[:space:]]*//')
fi

# Emit. Optional lines are omitted when their source is empty.
printf '%s · build %s\n' "$APP_NAME" "$BUILD"
if [[ -n "${PR_NUMBER:-}" ]]; then
  printf 'Branch:  %s  →  PR #%s\n' "$BRANCH" "$PR_NUMBER"
else
  printf 'Branch:  %s\n' "$BRANCH"
fi
[[ -n "$JIRA_KEY" ]] && printf 'Jira:    %s%s\n' "$JIRA_KEY" "${JIRA_TITLE:+ — $JIRA_TITLE}"
[[ -n "$CHANGES"  ]] && printf 'Changes: %s\n' "$CHANGES"
[[ -n "$FOCUS"    ]] && printf 'Focus:   %s\n' "$FOCUS"
printf 'Commit:  %s  ·  @%s\n' "${HEAD_SHA:0:9}" "$AUTHOR"
