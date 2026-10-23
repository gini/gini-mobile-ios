# Firebase App Distribution — Release Notes Format

Working proposal for `bank-sdk.publish.example.app.firebase.yml` (and the sibling
`health-sdk.publish.example.apps.firebase.yml`). Same template is used for feature
PRs **and** release PRs — no branching logic.

Firebase App Distribution renders notes as plain text, 16,384-char cap. This
proposal keeps the template external, generated in a dedicated CI step, and
passed via `--release-notes-file`.

---

## 1. What a tester sees in Firebase

### 1a. Feature PR

```text
GiniBankSDKExample · build 1427
Branch:  feat/PP-3857-wero-qr-support  →  PR #1192
Jira:    PP-3857 — Wero QR support in capture flow
Changes: GiniCaptureSDK + GiniBankSDK
Focus:   Scan a Wero QR → verify camera guide returns on cancel
Commit:  6f2c47f40  ·  @qazinaveed
```

### 1b. Release PR (same template, no special-casing)

```text
GiniBankSDKExample · build 2847
Branch:  release/GiniBankSDK-4.6.0  →  PR #1201
Jira:    PP-4198 — Finalise Skonto dark-mode polish
Changes: GiniBankSDK + GiniCaptureSDK + BankAPILibrary + GiniUtilites
Commit:  a1b2c3d4e  ·  @qazinaveed
```

On release PRs, `Focus:` is omitted (no `## What to test` in the PR body) and
`Jira:` shows whichever ticket is on the latest commit — accepted trade-off for
keeping one template.

### Why these six lines

| Line | Question it answers |
|---|---|
| `GiniBankSDKExample · build N` | What am I installing? |
| `Branch: ... → PR #N` | Where does it come from? |
| `Jira: TICKET — title` | What's the ticket context? (omitted if none) |
| `Changes: SDK + SDK` | Which SDK layer was touched? |
| `Focus: ...` | What to try — one line only, from PR body `## What to test`. Omitted if absent. |
| `Commit: SHA · @author` | Who to ping, what to attach to a bug report |

No version string. The example app's `MARKETING_VERSION` is a static `1.0`, and
the SDK's `*Version.swift` holds the *next planned* release — misleading on a
feature branch. Build number (`github.run_number`) is monotonic + unique, which
is all a tester actually needs.

---

## 2. Workflow change

Drop-in replacement for lines 108–121 of
`.github/workflows/bank-sdk.publish.example.app.firebase.yml`:

```yaml
      - name: Generate release notes
        env:
          APP_NAME:    GiniBankSDKExample
          BUILD:       ${{ github.run_number }}
          BRANCH:      ${{ github.head_ref || github.ref_name }}
          PR_NUMBER:   ${{ github.event.pull_request.number }}
          PR_URL:      ${{ github.event.pull_request.html_url }}
          PR_BODY:     ${{ github.event.pull_request.body }}
          BASE_SHA:    ${{ github.event.pull_request.base.sha }}
          HEAD_SHA:    ${{ github.event.pull_request.head.sha || github.sha }}
          AUTHOR:      ${{ github.event.pull_request.user.login || github.actor }}
        run: .github/generate_firebase_release_notes.sh > release_notes.txt

      - name: Distribute bank-sdk example ipa to Firebase App Distribution
        id: distribute
        run: |
          chmod +x .github/publish_to_firebase.sh
          .github/publish_to_firebase.sh
        shell: bash
        env:
          INPUT_APPID: ${{ secrets.GINI_BANK_SDK_EXAMPLE_APP_FIREBASE_ID }}
          INPUT_SERVICECREDENTIALSFILECONTENT: ${{ secrets.FIREBASE_CREDENTIAL_FILE_CONTENT }}
          INPUT_FILE: GiniBankSDKExample.ipa
          INPUT_GROUPS: testers
          INPUT_RELEASENOTESFILE: release_notes.txt
```

Two edits:

1. New `Generate release notes` step writes `release_notes.txt`.
2. Upload step swaps `INPUT_RELEASENOTES` for `INPUT_RELEASENOTESFILE`.
   `publish_to_firebase.sh:19-22` already prefers the file when set — no script
   changes needed on the uploader.

The existing Jira-ticket-extraction block (lines 123–171) stays unchanged.

---

## 3. The generator script

`.github/generate_firebase_release_notes.sh` — ~40 lines of bash, no runtime
deps beyond `git` + coreutils. Sketch:

```bash
#!/bin/bash
set -euo pipefail

# Resolve diff range: PR base→head, else last tag→HEAD on dispatch
if [[ -n "${BASE_SHA:-}" ]]; then
  RANGE="${BASE_SHA}..${HEAD_SHA}"
else
  LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
  RANGE="${LAST_TAG:+${LAST_TAG}..}HEAD"
fi

# Jira ticket from latest commit on the range
JIRA_KEY=$(git log --no-merges "$RANGE" --pretty=%B \
           | grep -oE '[A-Z]+-[0-9]+' | head -1 || true)
JIRA_TITLE=""
if [[ -n "$JIRA_KEY" ]]; then
  # Reuse latest commit subject as the title (no Jira API call)
  JIRA_TITLE=$(git log --no-merges "$RANGE" --pretty=%s \
               | grep -F "$JIRA_KEY" | head -1 \
               | sed -E "s/^[a-z]+(\(.*\))?: //" \
               | sed -E "s/[[:space:]]*$JIRA_KEY[[:space:]]*//")
fi

# Changed top-level SDK dirs
CHANGES=$(git diff --name-only "$RANGE" \
          | awk -F/ '{print $1}' | sort -u \
          | grep -E '^(BankSDK|CaptureSDK|BankAPILibrary|HealthSDK|HealthAPILibrary|GiniComponents)$' \
          | tr '\n' '+' | sed 's/+$//' | sed 's/+/ + /g')

# Focus from PR body "## What to test" section (first non-empty line)
FOCUS=""
if [[ -n "${PR_BODY:-}" ]]; then
  FOCUS=$(printf '%s\n' "$PR_BODY" \
          | awk 'BEGIN{p=0} /^##[[:space:]]+What to test/{p=1;next} /^##/{p=0} p && NF' \
          | head -1 | sed 's/^[-*][[:space:]]*//')
fi

# Emit
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
```

Everything optional (`Jira`, `Changes`, `Focus`) is omitted when its source is
empty — graceful degradation.

---

## 4. Implementation plan

Branch: `ci/firebase-release-notes` (already created, off main).

### Phase 1 — Bank SDK (the pilot)

1. **Add script** `.github/generate_firebase_release_notes.sh`
   - Make executable (`chmod +x`)
   - Add a short header comment pointing at this sample MD

2. **Edit** `.github/workflows/bank-sdk.publish.example.app.firebase.yml`
   - Insert the `Generate release notes` step after `Check file existence` and before `Install Node.js`
   - Swap `INPUT_RELEASENOTES` → `INPUT_RELEASENOTESFILE: release_notes.txt`

3. **Local dry-run** before pushing anything:
   ```bash
   APP_NAME=GiniBankSDKExample BUILD=1427 \
   BRANCH=feat/PP-3857-wero-qr-support \
   PR_NUMBER=1192 PR_URL=https://... \
   BASE_SHA=$(git merge-base main HEAD) \
   HEAD_SHA=$(git rev-parse HEAD) \
   AUTHOR=qazinaveed \
   .github/generate_firebase_release_notes.sh
   ```
   Verify the output matches §1a.

4. **CI dry-run:** open a *draft* PR with a trivial change under `BankSDK/**` to
   trigger the workflow once. Confirm the actual Firebase tester UI shows the
   note correctly.

### Phase 2 — Health SDK

5. **Edit** `.github/workflows/health-sdk.publish.example.apps.firebase.yml`
   with the same two-step change. `APP_NAME` env becomes
   `GiniHealthSDKExample`. Nothing else changes.

### Phase 3 — Decommission

6. Once both workflows are confirmed in production, delete the sample MD
   (this file) and keep only the script + the workflow references.

### Rollback

Single commit per workflow — revert by `git revert` on either. The script is
additive and harmless on its own if the workflow isn't calling it.

### Validation checklist

- [ ] Script runs locally with no errors on a real feature-branch range
- [ ] Script produces 4–6 lines (never zero, never >20)
- [ ] Output stays under 1 KB on a release-branch range of 100+ commits
- [ ] `Focus:` line appears when PR body has `## What to test`, otherwise omitted
- [ ] `Jira:` line omits cleanly when no ticket is present
- [ ] `workflow_dispatch` run (no PR event) still produces valid output
- [ ] CI Firebase upload step succeeds on the draft PR
- [ ] Tester UI in Firebase App Distribution shows the note cleanly

### Risks

| Risk | Mitigation |
|---|---|
| `github.event.pull_request` fields empty on `workflow_dispatch` | Script falls back to `ref_name` and `github.sha`, PR line degrades to `Branch: <ref>` |
| Multi-line PR body breaks awk extraction | `awk` reads line-by-line; `head -1` guarantees one line out |
| Fork PRs can't read secrets → workflow may already skip | Not a regression; existing behaviour |
| Firebase 16 KB cap | 6 lines × ~80 chars = ~500 chars; nowhere near |

### Non-goals (deferred)

- Conventional-Commit grouping (not needed with the simplified format)
- Jira API lookup for ticket titles (we reuse the commit subject)
- Localisation (Firebase doesn't localise)
- Separate release-PR template (deliberately using same format for both)

---

## 5. Decisions already made

- **Same template for release and non-release PRs** — accepted trade-off that
  release PRs show one random ticket on the `Jira:` line and no `Focus:`.
- **No version number** displayed — build number is sufficient and unambiguous.
- **No `API:` or `Flags:` lines** — rejected during review.
- **Branch created from main**, not from the pre-existing `ci-release-notes`
  branch (which contains unrelated agent/skill deletions).
