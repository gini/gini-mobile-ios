# gini-release-notes platform conventions — iOS (gini-mobile-ios)

<!--
  NOT MIRRORED — this file is iOS-specific by design. The Android repo has its
  own platform.md with the same section headings but Android content. If you add
  a section here that the shared workflow depends on, add the matching section
  to the Android platform.md too.
-->

## Where versions live

Each package holds its version in `{PackageName}Version.swift` as a `public let` (see `RELEASE.md` step 2).

```bash
# while the release branch is still open
git diff main...HEAD -- '*Version.swift' | grep -E '^(\+\+\+|[-+]public let)'

# after the release is tagged — compare against the previous tag of the leading package
git diff '<Package>;<prev-version>'..HEAD -- '*Version.swift' | grep -E '^(\+\+\+|[-+]public let)'
```

The `-public let` line is the previous version.

**`Package-release.swift` is the dependency-pinning file** (`RELEASE.md` step 4). It changes in every *dependent* package during a release, but it is not that package's own version — never treat a change there as a bump. It is the source for the Dependencies section.

## Release targets

Every bumped package gets a note in **its own SPM release repo**. Five of them *additionally* get a pointer note in this monorepo — so those packages produce **two** notes each.

| Package | SPM release repo | Note in monorepo? |
|---|---|---|
| `GiniBankSDK` | `gini/bank-sdk-ios` | yes |
| `GiniCaptureSDK` | `gini/capture-sdk-ios` | yes |
| `GiniBankAPILibrary` | `gini/bank-api-library-ios` | yes |
| `GiniHealthSDK` | `gini/health-sdk-ios` | yes |
| `GiniHealthAPILibrary` | `gini/health-api-library-ios` | yes |
| `GiniInternalPaymentSDK` | `gini/internal-payment-sdk-ios` | **no** |
| `GiniUtilites` | `gini/utilites-ios` | **no** — note the repo name's spelling |

`GiniInternalPaymentSDK` and `GiniUtilites` are internal dependencies that integrators do not add directly. They have no monorepo release and no Jira fix version, but they **do** get an SPM repo note.

`RELEASE.md` steps 7–8 still point at the `*-pinning-ios` repos. Those look discontinued — their newest releases are far behind the mainline ones. **Never draft pinning notes on your own initiative.** If a pinning repo is relevant to this release, ask the user.

## Dependency order

Draft deepest dependency first, per `RELEASE-ORDER.md`:

- bank line: `GiniBankAPILibrary` → `GiniUtilites` → `GiniCaptureSDK` → `GiniBankSDK`
- health line: `GiniHealthAPILibrary` → `GiniUtilites` → `GiniInternalPaymentSDK` → `GiniHealthSDK`

## Jira fix version mapping

The fix-version name carries an **`iOS ` prefix that the GitHub titles do not**. This is a transformation, not an identity — strip it:

```
Jira fixVersion            iOS Gini <Product> <version>
Monorepo release title     Gini <Product> <version>
Monorepo tag               <PackageName>;<version>
SPM repo release title     <version>
SPM repo tag               <version>
```

| Package | Fix version starts with | Jira project |
|---|---|---|
| `GiniBankSDK` | `iOS Gini Bank SDK` | `PP` (Banking Team) |
| `GiniCaptureSDK` | `iOS Gini Capture SDK` | `PP` (Banking Team) |
| `GiniBankAPILibrary` | `iOS Gini Bank API Library` | `PP` (Banking Team) |
| `GiniHealthSDK` | `iOS Gini Health SDK` | `HEAL` (Health) |
| `GiniHealthAPILibrary` | `iOS Gini Health API Library` | `HEAL` (Health) |

The **`iOS ` prefix is the platform marker**. Android releases live in the same two Jira projects with otherwise identical names.

Theme suffixes are common here (`iOS Gini Bank SDK 4.4.0 QR code improvements`). Strip the suffix as well as the prefix when forming the title.

The RC ticket summary reads `[iOS] Release candidate for Gini <Product> <version>`, and one RC commonly covers a whole product line.

## Source paths

```bash
git log --no-merges '<Package>;<prev-version>'..HEAD --format='%s' -- <package-folder>/
```

Package folders are the top-level product folders: `BankSDK/`, `CaptureSDK/`, `BankAPILibrary/`, `HealthSDK/`, `HealthAPILibrary/`, `GiniComponents/InternalPaymentSDK/`, `GiniComponents/Utilities/`.

## Bullet conventions

- **Bug folding:** fold related bugs **into the feature bullet they belong to**. There is no fixed "minor fixes" closing line on iOS — do not invent one. A bug gets its own bullet when an integrator would notice the behaviour change on its own.
- **Grouping:** when a release has several themes, group bullets under `###` subheadings named after the area (the scanning flow, a screen, a feature). A short release stays a flat list. Follow the shape of the package's previous release.
- **Symbols in backticks:** Swift symbols — types, properties, methods, localisation keys, config flags (e.g. `` `PaymentReviewContainerConfiguration.keyboardDoneButtonTintColor` ``, `` `gini.health.reviewscreen.title` ``). iOS notes name the exact symbol an integrator would touch.

## Note templates

Each of the five products needs **two** notes. `GiniInternalPaymentSDK` and `GiniUtilites` need only the first.

### The SPM release repo note — the detailed one

Title: just the version (`4.4.0`). This is where the real changelog lives.

```markdown
<dependency lines, if this package has dependencies>

## Features, improvements and fixes

<bullets, optionally grouped under ### subheadings>

## Requirements
- Minimum iOS <version>
- Xcode <version> or newer required

Documentation can be found [here](<DOC_URL>).
```

Section order and heading wording differ between the two product lines — the bank packages put dependency lines at the top as `- Uses …` bullets, the health packages put them at the bottom under `## Dependencies`. Do not normalise them. Read the previous release and match it:

```bash
gh release view '<prev-version>' --repo gini/<spm-repo> --json body -q .body
```

### The monorepo note — the pointer

Title: `Gini <Product> <version>` — **no `iOS` prefix**, unlike the Jira fix version.

```markdown
Detailed change logs are in the SPM repositories:

- https://github.com/gini/<spm-repo>/releases/tag/<version>

Documentation can be found [here](<DOC_URL>).

## Note
- To ensure maximum stability, the latest features, and all available bug fixes, we strongly recommend always integrating the latest SDK version.
- This SDK version is tested and supported on Xcode <version>.
```

Some products repeat the full feature list and dependencies here instead of only pointing at the SPM repo. Follow the package's own previous monorepo release:

```bash
gh release view '<Package>;<prev-version>' --repo gini/gini-mobile-ios --json body -q .body
```

The `## Note` block is near-verbatim boilerplate, but the **Xcode version inside it is real information** — carry over the previous release's value, and if this release changes the minimum Xcode or iOS version, confirm the new number with the user rather than guessing.

## Documentation URLs

Two kinds of URL. Substitute `<version>` only in the **versioned** ones; the **fixed** ones are used verbatim and never get a version spliced into them.

| Package | Kind | Documentation URL |
|---|---|---|
| `GiniBankSDK` | fixed | `https://gini.atlassian.net/wiki/spaces/IBSV/overview` |
| `GiniCaptureSDK` | fixed | `https://gini.atlassian.net/wiki/spaces/IBSV/overview` |
| `GiniBankAPILibrary` | versioned | `https://developer.gini.net/gini-mobile-ios/GiniBankAPILibrary/<version>/index.html` |
| `GiniHealthSDK` | versioned | `https://developer.gini.net/gini-mobile-ios/GiniHealthSDK/<version>/index.html` |
| `GiniHealthAPILibrary` | versioned | `https://developer.gini.net/gini-mobile-ios/GiniHealthAPILibrary/<version>/index.html` |

Only the **versioned** URLs are affected by the "may 404 while drafting" rule in §6 — a fixed wiki URL resolves immediately, so if one of those is broken it is a genuine problem worth reporting rather than an expected timing gap.

Some `GiniCaptureSDK` notes omit the documentation line entirely. Follow the package's previous release rather than adding one.

`IBSV` is the iOS space. The Android notes use `GBSV` — do not copy one for the other.

Known defect in a published note: the `GiniBankAPILibrary 4.4.0` release links its documentation at **4.2.0**. Do not copy that mistake forward.

## Dependency links

Link the dependency's **SPM repo** release. Those tags are plain versions with no `;`:

`https://github.com/gini/<spm-repo>/releases/tag/<version>`

| Package | Lists |
|---|---|
| `GiniBankSDK` | `GiniBankAPILibrary`, `GiniCaptureSDK` |
| `GiniCaptureSDK` | `GiniBankAPILibrary`, `GiniUtilites` |
| `GiniHealthSDK` | `GiniHealthAPILibrary`, `GiniInternalPaymentSDK`, `GiniUtilites` |
| `GiniInternalPaymentSDK` | `GiniHealthAPILibrary`, `GiniUtilites` |
| `GiniBankAPILibrary`, `GiniHealthAPILibrary` | none |

Read each dependency's version from the dependent package's `Package-release.swift` at the release commit — do not assume it matches the version being released. A dependency often stays at its old version while the SDK above it moves.

## Tags and draft creation

Two tag formats: `<Package>;<version>` in the monorepo, plain `<version>` in the SPM repo.

Read-only checks, run in §7 before offering — for every repo a note goes to:

```bash
# monorepo tag
git tag -l '<Package>;<version>'
git ls-remote --tags origin 'refs/tags/<Package>;<version>'

# SPM repo tag
gh api repos/gini/<spm-repo>/git/ref/tags/<version> --silent 2>/dev/null && echo exists || echo missing
```

Draft creation, run in §8 only after a yes:

```bash
# detailed note, in the SPM release repo
gh release create '<version>' --repo gini/<spm-repo> \
  --title '<version>' --notes-file <spm-draft.md> --draft

# pointer note, in this monorepo
gh release create '<Package>;<version>' --repo gini/gini-mobile-ios \
  --title 'Gini <Product> <version>' --notes-file <mono-draft.md> --draft
```

Tags are created and pushed by `bundle exec fastlane create_release_tags` (`RELEASE.md` step 6), which triggers the release pipeline. This skill never creates or pushes one.
