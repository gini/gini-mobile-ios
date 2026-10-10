# XPL-430: Get the mobile CI bot's commits signed

Status: implemented
Ticket: https://ginis.atlassian.net/browse/XPL-430
Reference artifact: https://claude.ai/code/artifact/48edf1f3-4bed-4a41-9744-bb5d8cbb4ee0 (design sketch by the ticket author)

## Problem

Fastlane lanes that run on CI (release-repo publishing, documentation
publishing, podspec publishing) make and push git commits as `Team Mobile`
/ `Team Mobile Schorsch`. Those commits are **not signed** because the CI
runner has no GPG/SSH signing key. On GitHub they appear with the yellow
"Unverified" badge, which is a trust/BFSG-adjacent audit issue for release
artefacts the SDKs' integrators consume (release repos, documentation,
podspecs).

Introducing a CI-side signing key is costly (secret rotation, HSM access,
GPG tooling on macOS CI). GitHub side-steps this: **commits created
through GitHub's REST / GraphQL API are automatically signed by the
`web-flow` GPG key** and marked Verified, with the GitHub App / bot
identity carrying the authorship. The fix is to replace the few `git push`
sites that produce CI bot commits with a helper that uploads the local
objects and then asks GitHub to create the commit via API — no new secrets,
no new keys.

## Requirements

R1 (MUST, entry): Given a Fastlane lane running on CI with `GH_TOKEN`
exported and the `gh` CLI available on PATH, when the lane calls
`push_as_signed_commit(repo, branch, ui)` after a local `git commit`,
then a new commit with the same tree and message is created on
`refs/heads/<branch>` of `<repo>` through the GitHub REST API, the commit
appears on github.com with the **Verified** badge, and the helper's return
value is the SHA of the created commit.

R2 (MUST, happy): Given a successful signed-commit push, when the user
inspects the resulting commit on github.com, then the author field
shows **the GitHub App / bot identity associated with `GH_TOKEN`** (per
the ticket: `gini-mobile-ci[bot]`), **not** "Team Mobile" / "Team Mobile
Schorsch".

R3 (MUST, happy): Given `update_release_repo` publishes a Swift package to
a release repo, when the lane runs, then (a) a signed commit lands on
`main` of the release repo via the helper, and (b) a release tag of the
form `<version>` is created pointing at that signed commit via
`POST /repos/:owner/:repo/git/refs` — not via `git push --tags`, so the
tag references the signed commit that actually landed, not a local
unsigned one.

R4 (MUST, happy): Given `publish_docs` runs with real changes staged for
`gh-pages`, when the lane runs, then (a) a signed commit lands on
`gh-pages` of `gini/gini-mobile-ios`, (b) the author is the bot per R2,
and (c) the lane no longer invokes
`configure_git_on_ci_machines("Team Mobile", "team-mobile@gini.net")` —
that identity override is obsolete once GitHub supplies the author.

R5 (MUST, happy): Given the `publish_pod` lane publishes a `.podspec` to
`gini/gini-podspecs`, when the lane runs on CI, then a signed commit lands
on `master` of `gini/gini-podspecs` via the helper. The existing
`UI.confirm("Are you sure…")` guard before the push stays — scope is
*signing*, not interactive-confirmation removal.

R6 (SHOULD, happy): Given `publish_docs` runs with **no** staged diff
after the Jazzy output is copied in (idempotent re-run on the same tag),
when the lane reaches the push step, then it detects the no-op condition
and returns without creating an empty commit, matching the artifact's
`git diff --cached --quiet` guard.

R7 (MUST, error — concurrent push): Given two CI jobs call the helper
against the same branch concurrently, when the second job's
`PATCH /refs/heads/<branch>` fails because `<branch>` moved, then the
helper rebases locally (`git pull --rebase origin <branch>`) and retries,
up to `attempts: 3` total; on the final attempt failing, the Ruby
exception from `gh api` is re-raised to Fastlane's `UI.abort_with_message!`
boundary so the lane fails loudly rather than silently.

R8 (MUST, error — cleanup): Given the helper creates a temporary branch
`ci-signing-tmp-<timestamp>` on the remote to upload blobs/tree, when the
API-create step succeeds, fails, or raises, then the temporary branch is
deleted via `DELETE /repos/:owner/:repo/git/refs/heads/<tmp>` in an
`ensure` clause — no orphan `ci-signing-tmp-*` refs accumulate on the
remote.

R9 (MUST, error — auth): Given a lane calling the helper runs **without**
`GH_TOKEN` set (or with an invalid token), when the first `gh api` call
executes, then it fails with `gh`'s own authentication error, which
propagates to Fastlane's error boundary. The spec does not require the
helper to pre-check `GH_TOKEN` presence beyond what the calling lane
already does (`publish_docs` already asserts it at `Fastfile:136–138`).

R10 (MUST, async): Given a lane that previously used `git_push_with_retry`
or `sh('git push ...')`, when it is migrated to `push_as_signed_commit`,
then the helper remains synchronous (returns only when the branch is at
the new SHA and the temp branch is deleted). Fastlane's `sh` continues to
be the shell boundary — no new concurrency primitives.

## Affected modules

This change is not Swift SDK code — it is release/CI tooling under
`fastlane/`. The SDK module map in `platform.md` does not apply. The
affected files are:

**gini-mobile-ios (this repo):**
- `fastlane/util/git.rb` — add `push_as_signed_commit`.
- `fastlane/util/swift_package_releases.rb` — rewrite `update_release_repo`
  per R3.
- `fastlane/Fastfile` — rewrite the `publish_docs` lane (lines ~140–218)
  per R4 / R6, and the `publish_pod` lane (line ~501) per R5.
- Call-site adjustment in `publish_swift_package` (Fastfile ~69) to pass
  the new `release_repo_url, ui` parameters into `update_release_repo`.

**gini-mobile-android (paired PR, out of this repo):**
- `fastlane/util/git.rb` — add the mirrored `push_as_signed_commit`.
  *(confidence: LOW — the Android repo may use a different `util/`
  layout; verify before writing. The ticket says "both" repos but
  this spec is written from the iOS tree.)*
- Android `release_documentation` lane — swap in the helper, mirroring
  R4. *(confidence: LOW — the Android lane name is from the ticket; the
  file path is not in this repo. /gini-build on the Android side must
  verify the current call-site.)*

## Public API impact

**None at the SDK level.** The helper lives inside `fastlane/util/`,
imported via `load "util/git.rb"` in `Fastfile`. There is no SPM product
export, no `.library()` surface, no integrator-facing Swift declaration
changed.

**Internal lane-signature changes (not integrator-visible):**
- `update_release_repo(release_repo_path, version)` → gains two parameters
  and becomes `update_release_repo(release_repo_path, release_repo_url, version, ui)`.
  Only called from one site in this repo (`publish_swift_package` in
  `Fastfile`), so this is a safe refactor.
- No change to `git_push_with_retry` — leave it in `fastlane/util/git.rb`
  for callers outside the three sites being migrated (tag pushes, future
  non-signed uses). It is called from `publish_docs` today; after this
  change, the only remaining `git_push_with_retry` call site in the iOS
  Fastfile should be gone, but the function stays available as dead-code-free
  utility.

## Technical conventions

Platform.md's checklist (SwiftUI/UIKit, MVVM+C, localization, GiniColorScheme,
multi-param-per-line) targets Swift SDK work and does not apply to Ruby /
Fastlane tooling. The conventions that *do* apply:

1. **Language / runtime.** Ruby, inside Fastlane's `sh` boundary.
   Match the file's existing style — `##` doc comments above each helper
   (see the existing `with_git_token_auth`, `configure_git_on_ci_machines`,
   `git_push_with_retry` for the pattern).
2. **Shell safety.** Any value interpolated into `sh("...")` that could
   contain spaces or shell metacharacters must be `.shellescape`'d.
   Specifically: the commit message read via `git log -1 --format=%B` goes
   into a `gh api -f message=…` argument and MUST be `.shellescape`'d,
   per the artifact's `message.shellescape`. The `require 'shellwords'`
   line sits at the top of the helper.
3. **GitHub CLI dependency.** The helper calls `gh api` and `gh api -X PATCH/DELETE`.
   The CI runners (`.github/workflows/*`) must have `gh` on PATH. iOS
   runners are macOS; `gh` is preinstalled on GitHub-hosted macOS runners.
   No new runner-image changes expected.
4. **Error surfacing.** Fatal errors inside the helper re-raise the
   `gh api` exception so they hit Fastlane's `UI.abort_with_message!` /
   lane-level error handling. Non-fatal (rebase retry) errors call
   `ui.message` with a human-readable summary before retrying, matching
   the artifact's design.
5. **No new secrets.** `GH_TOKEN` is already in use (see
   `with_git_token_auth` at `fastlane/util/git.rb:7–22` and
   `publish_docs` guard at `Fastfile:136–138`). The helper reuses it via
   `gh`'s own auth. No new environment variables, no vault reads.
6. **Idempotence.** The helper is retried up to 3 times with
   `git pull --rebase` between attempts. The temp branch name
   `ci-signing-tmp-<Time.now.to_i>` is unique-per-second — collisions on
   fast re-runs are unlikely but technically possible; the cleanup
   `DELETE ... || true` tolerates missing refs so the retry loop stays
   safe.
7. **Local commit intermediate.** The design keeps the local `git commit`
   step before the helper runs, because the helper needs
   `HEAD`'s tree, parent, and message. The local commit is discarded in
   favour of the API-created commit — i.e. after the helper returns,
   `HEAD` on the CI runner no longer matches what's on the remote. For
   release-repo and docs flows this is irrelevant (the clone is throwaway
   per lane); callers that reuse the local clone after the push would need
   to `git fetch && git reset --hard origin/<branch>`. None of the three
   migrated call-sites do, so this is a non-issue in the current scope.

## Design

### The helper

Add to `fastlane/util/git.rb`, verbatim from the artifact (included here so
`/gini-build` is working from a single source of truth):

```ruby
require 'shellwords'

##
# Publishes the local HEAD commit to `branch` as a commit that GitHub creates and signs.
# Retries with a rebase if the branch moved meanwhile (e.g. two docs jobs at once).
#
# Repo is in `owner/name` form (e.g. "gini/gini-mobile-ios"), not a URL.
#
def push_as_signed_commit(repo, branch, ui, attempts: 3)
  attempts.times do |attempt|
    message = sh("git log -1 --format=%B", log: false).strip
    tree = sh("git rev-parse 'HEAD^{tree}'", log: false).strip
    parent = sh("git rev-parse HEAD~1", log: false).strip
    tmp_branch = "ci-signing-tmp-#{Time.now.to_i}"

    # Upload the files so GitHub can build the commit from them.
    sh("git push origin HEAD:refs/heads/#{tmp_branch}")
    begin
      sha = sh("gh api repos/#{repo}/git/commits -f message=#{message.shellescape} " \
               "-f tree=#{tree} -f 'parents[]=#{parent}' --jq .sha").strip
      sh("gh api -X PATCH repos/#{repo}/git/refs/heads/#{branch} -f sha=#{sha} -F force=false")
      return sha
    rescue => e
      raise if attempt == attempts - 1
      ui.message "#{branch} moved, rebasing and retrying: #{e.message}"
      sh("git pull --rebase origin #{branch}")
    ensure
      sh("gh api -X DELETE repos/#{repo}/git/refs/heads/#{tmp_branch} || true")
    end
  end
end
```

Mechanism, line-by-line:

- `git log -1 --format=%B` + `git rev-parse HEAD^{tree}` + `git rev-parse HEAD~1`
  read the local commit's message, tree SHA, and parent SHA.
- `git push origin HEAD:refs/heads/<tmp>` uploads the blobs and tree to the
  remote object store so GitHub can build a commit referencing them. This
  is still an unsigned push, but the ref it creates is throwaway.
- `gh api repos/.../git/commits` POSTs a new commit object with the same
  tree + parent + message. GitHub signs this commit on creation.
- `gh api -X PATCH repos/.../git/refs/heads/<branch>` updates the target
  branch's ref to point at the new signed commit SHA. `-F force=false`
  requests a fast-forward-only update, which is what fails when the branch
  moved — that's the retry trigger.
- The `ensure` deletes the temp ref regardless of outcome.

### Call-site 1 — `fastlane/util/swift_package_releases.rb`

Replace the current `update_release_repo` (lines 23–34) with the artifact's
version:

```ruby
def update_release_repo(release_repo_path, release_repo_url, version, ui)
  repo = release_repo_url.sub(%r{^https://github.com/}, '').delete_suffix('.git') # e.g. gini/bank-sdk-ios
  Dir.chdir(release_repo_path) do
    sh('git add --all')
    sh("git commit -m 'Release version #{version}'")
    sha = push_as_signed_commit(repo, 'main', ui)
    sh("gh api repos/#{repo}/git/refs -f ref=refs/tags/#{version} -f sha=#{sha}")
  end
end
```

Then update the call site in `publish_swift_package` (Fastfile ~69) from:
```ruby
update_release_repo(release_repo_path, package_version)
```
to:
```ruby
update_release_repo(release_repo_path, repo_url, package_version, UI)
```

Notes:
- The `--author='Team Mobile Schorsch <team-mobile@gini.net>'` flag is
  **dropped** — the commit author becomes the bot identity, per R2.
- The local annotated tag (`git tag -a -m ...`) and `git push --tags`
  are **replaced** with a single API-created ref pointing at the signed
  commit. A tag ref is a lightweight tag by this call; if an *annotated*
  tag object is wanted, the API supports `/git/tags` first then `/git/refs`.
  The ticket's artifact uses a lightweight tag — matching that keeps scope
  minimal. If release automation elsewhere depends on annotated tags on
  the release repo, flag during review.

### Call-site 2 — `fastlane/Fastfile` `publish_docs` (lines ~215–218)

Replace:
```ruby
sh("git add --all")
sh("git diff --quiet --exit-code --cached || git commit -m 'Release #{package_folder} documentation for tag #{git_tag}' --author='Team Mobile <team-mobile@gini.net>'")
git_push_with_retry("gh-pages", UI)
```
with:
```ruby
sh("git add --all")
unless sh("git diff --cached --quiet && echo same || echo changed", log: false).strip == "same"
  sh("git commit -m 'Release #{package_folder} documentation for tag #{git_tag}'")
  push_as_signed_commit("gini/gini-mobile-ios", "gh-pages", UI)
end
```

Also remove line 141 of `publish_docs`:
```ruby
configure_git_on_ci_machines("Team Mobile", "team-mobile@gini.net")
```
Rationale: author identity now comes from the GitHub API's bot
association, not from `git config user.{name,email}`. Keep the enclosing
`if ci` block for whatever other CI-only setup it might carry later —
right now the block becomes empty, so delete the block too and inline-
comment why.

### Call-site 3 — `fastlane/Fastfile` `publish_pod` (line ~501)

Replace:
```ruby
sh "cd #{podspecs_repo_sdk_folder_path} && git add . && git commit -m '[Update] #{pod_name} (#{version_folder})'"
if UI.confirm("Are you sure you want to push these changes to the https://github.com/gini/gini-podspecs repo?")
  sh "cd #{podspecs_repo_sdk_folder_path} && git push origin master"
end
```
with:
```ruby
Dir.chdir(podspecs_repo_sdk_folder_path) do
  sh "git add ."
  sh "git commit -m '[Update] #{pod_name} (#{version_folder})'"
  if UI.confirm("Are you sure you want to push these changes to the https://github.com/gini/gini-podspecs repo?")
    push_as_signed_commit("gini/gini-podspecs", "master", UI)
  end
end
```

Notes:
- Keep `UI.confirm` — the ticket is about signing, not auto-publishing.
- Move the `cd` into `Dir.chdir` for consistency with the other call sites
  and so the helper's `git` commands run in the right directory.

### Android mirror (paired PR, not this repo)

The same helper needs to exist in `gini-mobile-android/fastlane/util/git.rb`
*(confidence: LOW on path — verify when the paired PR opens)*, with the
same signature. The Android `release_documentation` lane *(confidence:
LOW on exact filename and line)* swaps in:
```ruby
push_as_signed_commit("gini/gini-mobile-android", "gh-pages", UI)
```
at the current `git_push_with_retry("gh-pages", UI)` site, mirroring R4.
`/gini-build` on the Android side owns verifying the actual call-site
before applying.

## Test plan

Fastlane / Ruby tooling in this repo has no existing unit-test suite — the
`fastlane/` tree ships `*.rb` files and lane descriptions, no `spec/`
directory, no RSpec or minitest configuration *(confidence: HIGH — grepped,
no `.rspec`, no `spec/`, no `test/`)*. Standing up a Ruby unit-test
harness for a 25-line helper that is almost entirely `sh(...)` calls would
cost more than the value it adds. The verification plan is therefore
**throwaway-branch smoke tests** against real GitHub, as the ticket's "To
do" item 4 prescribes.

### Smoke tests (one each, run manually on a throwaway branch)

For each of the four call-sites, run the corresponding lane against a
throwaway branch / tag, inspect the resulting commit on github.com, and
confirm:
- The commit shows the green **Verified** badge.
- The author is `gini-mobile-ci[bot]` (or whatever bot identity `GH_TOKEN`
  resolves to on CI).
- The ref the lane targets is updated to the new SHA.
- No orphan `ci-signing-tmp-*` refs remain on the remote.

| # | Lane | Target repo | Target branch |
|---|------|-------------|---------------|
| 1 | `publish_swift_package` (minimal — tiny version bump) | a release repo (e.g. a dummy `gini/signing-test-release` or a disposable branch on an existing release repo) | `main` |
| 2 | `publish_docs` | `gini/gini-mobile-ios` | `gh-pages` (dedicated throwaway subfolder; `dry_run: false`) |
| 3 | `publish_pod` | a throwaway fork of `gini/gini-podspecs` or a disposable branch | `master` |
| 4 | Android `release_documentation` (owned by Android /gini-build) | `gini/gini-mobile-android` | `gh-pages` |

### Fallback test (ticket item 5)

If smoke test 1 or 2 shows the commit as **not** Verified, pivot to GraphQL
`createCommitOnBranch` as the ticket's documented fallback. The helper's
signature stays the same; only its body swaps the REST calls for a GraphQL
mutation. That rewrite is **out of scope** for the first PR — file as a
XPL-430 follow-up if needed.

### Retry test (R7)

Trigger the retry path manually: on a disposable branch, pre-position a
commit via github.com's web UI *between* the local `git commit` and the
helper's `PATCH ref` call (e.g. by running the lane under a breakpoint, or
by pushing an unrelated commit from a second clone). Confirm the helper
emits the "branch moved" message, runs `git pull --rebase`, and succeeds on
retry.

### Not tested

- Unit tests for the helper itself — no Ruby test harness exists in this
  repo; the sh-mock surface area is almost 100%, and the real surface is
  "does github.com see a Verified commit", which only an integration test
  can tell. Smoke tests on throwaway branches cover this.
- GitHub API quota / rate-limiting under high churn — out of scope; the
  helper issues 3 API calls per attempt (POST commit, PATCH ref, DELETE
  temp ref), so up to 9 per push with the default 3 retries.
- `gh` CLI version drift — assume the stable `gh` preinstalled on
  GitHub-hosted macOS runners.

## Out of scope

- **Switching to GraphQL `createCommitOnBranch`.** This is the ticket's
  explicit fallback plan. We ship REST first per the artifact. If REST
  commits turn out to be unsigned (unexpected per GitHub's documented
  behaviour), file a follow-up with the switch.
- **Tag-push signing.** The ticket is scoped to commits. The existing
  `git_push_release_tag` / `git_push_tag` helpers that push lightweight
  tags to the monorepo stay as-is. The `update_release_repo` tag API call
  (part of R3) is incidental — the signed-commit SHA has to be referenced
  by *some* tag, and doing it via API is simpler than the current
  push-local-tag flow.
- **Removing `git_push_with_retry`.** After this PR the helper has no
  caller in the iOS Fastfile, but we leave it in `fastlane/util/git.rb`
  for future non-signed uses and to avoid a dead-removal churn.
- **Removing `configure_git_on_ci_machines` entirely.** We only remove the
  one call-site inside `publish_docs`. Other callers may still need the
  user.{name,email} override for `git`-level operations that don't produce
  commits (e.g. rebase conflict markers, tag author).
- **Audit of other `git push` sites across all branches.** This spec
  catalogues the four sites that produce CI bot *commits*. Tag-pushes
  (`git_push_release_tag`, `git_push_tag`) are deliberately excluded.
- **Android implementation.** Specified at the call-site level (R4 mirror
  + helper duplication) so the Android PR knows what to do, but the actual
  Ruby edits land in the gini-mobile-android repo via a paired PR, not
  this one.
- **Changing the user-facing `UI.confirm` guard in `publish_pod`.** Scope
  is signing, not interactive-flow redesign.

## Open questions

- **Android file paths.** The `fastlane/util/git.rb` location in the
  Android repo may differ (Gradle-centric repos sometimes put Fastlane
  under `android/fastlane/`). /gini-build on the Android side verifies
  before mirroring. Noted in "Affected modules" with explicit confidence:
  LOW markers.
- **Behavior when `HEAD~1` doesn't exist** (e.g. first commit on a new
  release repo). `git rev-parse HEAD~1` would fail in that case; the
  REST `/git/commits` endpoint accepts an empty `parents[]` for initial
  commits. The ticket's helper doesn't handle this. Unlikely to hit in
  practice (release repos already have history), but worth noting as a
  known gap for the first-ever release repo creation case.

## Resolved during build

- **Tag flavor on release repos:** lightweight tag via `POST /git/refs`
  (matching the artifact). If downstream automation needs the annotation
  body, follow up with a two-call annotated-tag variant.
- **Auth identity (`GH_TOKEN` on CI is a GitHub App installation token).**
  `.github/workflows/sdk.publish.docs.yml`, `.github/workflows/sdk.release.yml`,
  and `.github/workflows/generate-sboms.yml` mint `GH_TOKEN` via
  `actions/create-github-app-token@v2.0.0` with `app-id:
  secrets.MOBILE_CI_APP_ID` + `private-key: secrets.MOBILE_CI_APP_PRIVATE_KEY`
  and `owner: gini`. The workflow also sets
  `git config user.name '${app-slug}[bot]'`, confirming the author
  identity model R2 depends on.
- **REST `POST /git/commits` DOES auto-sign for App installation tokens.**
  Verified on CI via a throwaway probe workflow against
  `gini/gini-mobile-ios` (run 38028219213). The two resulting commits —
  `03be913b` (POST /git/commits) and `b83ad038` (PUT /contents) — show
  Verified + `reason: valid` + a `web-flow` GPG signature + author
  `gini-mobile-ci[bot]`. Caveat: this behavior is undocumented but
  reproducible for App installations; it does NOT hold for classic/
  fine-grained PATs (verified separately against a personal probe repo —
  returned `unsigned`). Our helper is correct as shipped; no GraphQL
  `createCommitOnBranch` pivot needed.

## Implementation plan
- [x] 1. Add `push_as_signed_commit(repo, branch, ui, attempts: 3)` to `fastlane/util/git.rb` (R1, R7, R8, R9, R10)
- [x] 2. Rewrite `update_release_repo` in `fastlane/util/swift_package_releases.rb` to drop local-author / `git push --tags` and call the helper + create the tag ref via API (R2, R3)
- [x] 3. Update the `update_release_repo` call site in `publish_swift_package` (`fastlane/Fastfile`) to pass the new `repo_url, UI` arguments (R3)
- [x] 4. Rewrite `publish_docs` commit/push block in `fastlane/Fastfile` to detect no-op, drop the local `--author`, and call the helper; remove the `configure_git_on_ci_machines` + enclosing empty `if ci` block (R4, R6)
- [x] 5. Rewrite `publish_pod` commit/push block in `fastlane/Fastfile` to use `Dir.chdir` and call the helper while keeping the existing `UI.confirm` guard (R5)
