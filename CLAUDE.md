# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Monorepo containing Gini's iOS SDKs for document capture, bank integration, health insurance, and merchant payment processing. All SDKs are Swift Packages managed through a single Xcode workspace (`GiniMobile.xcworkspace`).

## Build & Test Commands

Run this after every change is done.

**Open workspace:**
```bash
open GiniMobile.xcworkspace
```

**Run unit tests for a specific SDK (example: BankSDK):**
```bash
xcodebuild clean test \
  -project BankSDK/GiniBankSDKExample/GiniBankSDKExample.xcodeproj \
  -scheme "GiniBankSDKExampleTests" \
  -destination "platform=iOS Simulator,name=iPhone 16,OS=18.5" \
  CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO
```

Replace the project/scheme for other SDKs (GiniCaptureSDK, GiniHealthSDK, etc.). Some integration tests require `TEST_CLIENT_ID` and `TEST_CLIENT_SECRET` environment variables.

**Run tests via Fastlane:**
```bash
bundle exec fastlane run_unit_tests
```

**Build documentation (Jazzy):**
```bash
bundle exec fastlane build_docs
```

**Install Ruby dependencies (Fastlane, Jazzy):**
```bash
bundle install
```

## SDK Dependency Graph

```
GiniBankAPILibrary ──┐
GiniUtilites ────────┼──→ GiniCaptureSDK ──→ GiniBankSDK
                     │
GiniHealthAPILibrary─┤
GiniUtilites ────────┼──→ GiniInternalPaymentSDK ──┬──→ GiniHealthSDK
                     │                              └──→ GiniMerchantSDK
```

When modifying a lower-level package, changes propagate to all dependents. Release order must follow this dependency chain (see `RELEASE-ORDER.md`).

## Module Layout

Each SDK follows this structure:
```
{SDK}/
├── Package.swift              # SPM package definition (local development)
├── Package-release.swift      # SPM manifest used in release repos
├── Sources/{SDK}/
│   ├── Core/
│   ├── Extensions/
│   ├── Resources/             # Localization (.strings), assets
│   ├── {SDK}Version.swift     # Version constant (update for releases)
│   └── PrivacyInfo.xcprivacy
└── Tests/
```

**Key modules:**
- `BankAPILibrary/` and `HealthAPILibrary/` — Low-level REST API clients
- `CaptureSDK/` — Document capture, review, and image analysis
- `BankSDK/` and `HealthSDK/` — Full-featured SDKs with UI components
- `MerchantSDK/` — Merchant payment processing
- `GiniComponents/GiniUtilites/` — Shared utilities (logging, networking)
- `GiniComponents/GiniInternalPaymentSDK/` — Shared payment logic

## Commit Message Format

Follow Conventional Commits with this structure:
```
<type>(<project>): <subject>

<body>

<ticket-id>
```

- **Types:** `feat`, `fix`, `refactor`, `ci`
- **Project:** Module name (e.g., `GiniBankSDK`). Omit parentheses for multi-module changes.
- **Subject:** Imperative mood, no period
- **Ticket ID:** Required on last line (e.g., `PP-4102`)

Example:
```
feat(GiniBankSDK): Add photo selection button

- Add configuration option for photo selection
- Ensure backward compatibility

PP-4102
```

## Release Process

1. Update version in `{SDK}Version.swift`
2. Update `Package-release.swift` in dependent packages
3. Create tags with format `{PackageName};{version}` (e.g., `GiniBankSDK;4.1.1`)
4. Tags trigger GitHub Actions that publish to dedicated release repos (e.g., `gini/bank-sdk-ios`)

## CI Environment

- **Xcode:** 16.4
- **Simulator:** iPhone 16, iOS 18.5
- **Runner:** macOS latest
- **Minimum deployment target:** iOS 13+ (HealthAPILibrary: iOS 12+)


# MyApp Standards

## Architecture

 - MUST follow MVVM + Coordinator. Every feature gets its own *Coordinator. The SDK entry point is always a single static factory returning a UIViewController.

## Dependency Injection

 - MUST use constructor injection. Delegate back-references are the only acceptable post-init injection. The GiniBankAPI.Builder (value-type fluent builder) is the required pattern for SDK entry points.

## View & ViewController Patterns

 - ViewModels MUST NOT import UIKit. Binding is closure-based (addStateChangeHandler). ViewModel→Coordinator is via a weak delegate protocol. VCs only lay out UI and forward events — no business logic.

## Design System

 - Colors MUST be accessed via UIColor.GiniBank.* / UIColor.GiniCapture.* namespace. Dark mode required via GiniColor(light:dark:). Fonts via textStyleFonts[textStyle] with Dynamic Type. Spacing in local enum Constants (no magic numbers).

## Testing

 - New tests MUST use Swift Testing (@Suite, @Test, #expect). Mocks are manual protocol conformances (no third-party framework). Test data comes from JSON fixtures in Tests/Resources/. All ViewModels and Services must have unit tests. Current coverage is weakest on ViewControllers and Coordinators.

## Localization

 - Keys follow <sdk>.<feature>.<screen>.<element> convention. All strings go through the 3-level lookup chain (host app → custom bundle → SDK bundle). Use typed LocalizableStringResource enums, never raw NSLocalizedString.


## Code Style

# Multi-Parameter Initializers & Functions

When a method or initializer has multiple parameters, it MUST use one-parameter-per-line formatting.

The first parameter MUST remain on the same line as the opening parenthesis.

All following parameters MUST be placed on new lines and vertically aligned.

The closing parenthesis and opening brace remain on the same line.

Example:

Writing
```
init(compositeDocuments: [CompositeDocument]?,
     creationDate: Date,
     id: String,
     name: String,
     origin: Origin,
     pageCount: Int,
     pages: [Page]?,
     links: Links,
     partialDocuments: [PartialDocumentInfo]?,
     progress: Progress,
     sourceClassification: SourceClassification) {
    self.compositeDocuments = compositeDocuments
    self.creationDate = creationDate
    self.id = id
    self.name = name
    self.origin = origin
    self.pageCount = pageCount
    self.pages = pages
    self.links = links
    self.partialDocuments = partialDocuments
    self.progress = progress
    self.sourceClassification = sourceClassification
}
```
# Rules

❌ Do NOT move the first parameter to a new line

❌ Do NOT group multiple parameters on the same line

❌ Do NOT use mixed formatting styles

✅ ALWAYS align subsequent parameters vertically

✅ Apply this consistently across:

  - Initializers
  - Public methods
  - Private helpers
  - Builders and factory methods


# Pull Request Description Generation
Refer to AGENTS.md for PR description generation and repository conventions.

Always follow AGENTS.md instructions when generating pull request descriptions.