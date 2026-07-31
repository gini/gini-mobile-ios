# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Monorepo containing Gini's iOS SDKs for document capture, bank integration, and health insurance. All SDKs are Swift Packages managed through a single Xcode workspace (`GiniMobile.xcworkspace`).

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
  -destination "platform=iOS Simulator,name=iPhone 16,OS=26.2" \
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
GiniUtilites ────────┼──→ GiniInternalPaymentSDK ──→ GiniHealthSDK
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

- **Xcode:** 26.2
- **Simulator:** iPhone 16, iOS 26.2
- **Runner:** macOS latest
- **Minimum deployment target:** iOS 15+ (HealthSDK & HealthAPILibrary: iOS 17+)


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



# Skills

Skills are reusable prompt files that extend Claude's capabilities for specific team workflows.
They live in `.claude/skills/` and are invoked by name in any Claude conversation.

---

## Available Skills

### `/generate-xray-tests`

Generates manual test cases from a Jira ticket, local spec file, or pasted text, and writes them as a CSV ready to import into Xray Cloud.

- **Skill prompt:** `.claude/skills/generate-xray-tests/SKILL.md`
- **Usage & arguments:** `.claude/skills/generate-xray-tests.md`
- **GitHub Copilot Chat equivalent:** `.github/instructions/generate-xray-tests.instructions.md` · `.github/instructions/generate-xray-tests.md`

---

## graphify

This monorepo has a **graphify knowledge graph** at `graphify-out/` covering all six SDKs
(BankAPILibrary, HealthAPILibrary, CaptureSDK, BankSDK, HealthSDK, GiniComponents).
The graph is built primarily from Swift/Ruby/shell AST plus semantic extraction over the docs.

**Rules:**

- Before answering architecture or codebase questions, read `graphify-out/GRAPH_REPORT.md`
  for god nodes (`GiniCaptureSDK`, `GiniHealthAPILibrary`, `GiniConfiguration`,
  `GiniBankAPILibrary`, `GiniBankConfiguration` …) and community structure.
- `graphify-out/wiki/index.md` exists — navigate the wiki instead of reading raw files when
  you need a topic overview.
- For cross-module "how does X relate to Y" questions, prefer graph traversal over grep — it
  follows the graph's EXTRACTED + INFERRED edges instead of scanning files:
  - `graphify query "<question>"` — broad context (BFS)
  - `graphify path "<A>" "<B>"` — shortest path between two concepts (e.g. `"GiniBankSDK" "GiniUtilites"`)
  - `graphify explain "<concept>"` — plain-language explanation of a node
- **The graph auto-rebuilds on branch switch** via a `post-checkout` git hook (AST-only, no
  API cost) — installed at `.git/hooks/post-checkout`. This is the only hook installed:
  commits do **not** trigger a rebuild, and a plain `git pull` does **not** either (a pull
  fires no checkout).
- After a `git pull` (e.g. pulling main) that you don't follow with a branch switch, run
  `graphify update .` to refresh the graph against the pulled code.
- After changing **docs, images, or PDFs** in a session (the hook only covers code), run
  `/graphify --update` to fold them into the graph.
- To rebuild manually at any time: `graphify update .` (AST-only, no API cost).

---

## MCP Tools: code-review-graph (optional — only if configured)

> **NOTE:** The `code-review-graph` MCP server is **not currently connected** to this project.
> The tools below are only available once that MCP server has been added to the Claude Code /
> Claude Desktop config. Until then, use the `graphify` CLI commands above and fall back to
> Grep/Glob/Read. graphify can expose a subset of these live via `/graphify --mcp`
> (tools: `query_graph`, `get_node`, `get_neighbors`, `get_community`, `god_nodes`,
> `graph_stats`, `shortest_path`).

**IF the `code-review-graph` MCP server is configured, prefer its tools BEFORE Grep/Glob/Read
when exploring the codebase** — the graph is faster, cheaper (fewer tokens), and gives
structural context (callers, dependents, test coverage) that file scanning cannot.

### When to use graph tools first

- **Exploring code**: `semantic_search_nodes` or `query_graph` instead of Grep
- **Understanding impact**: `get_impact_radius` instead of manually tracing imports
- **Code review**: `detect_changes` + `get_review_context` instead of reading entire files
- **Finding relationships**: `query_graph` with callers_of / callees_of / imports_of / tests_for
- **Architecture questions**: `get_architecture_overview` + `list_communities`

Fall back to Grep/Glob/Read **only** when the graph doesn't cover what you need.

### Key tools

| Tool | Use when |
|------|----------|
| `detect_changes` | Reviewing code changes — gives risk-scored analysis |
| `get_review_context` | Need source snippets for review — token-efficient |
| `get_impact_radius` | Understanding blast radius of a change |
| `get_affected_flows` | Finding which execution paths are impacted |
| `query_graph` | Tracing callers, callees, imports, tests, dependencies |
| `semantic_search_nodes` | Finding functions/classes by name or keyword |
| `get_architecture_overview` | Understanding high-level codebase structure |
| `refactor_tool` | Planning renames, finding dead code |

### Workflow (when the MCP server is configured)

1. Use `detect_changes` for code review.
2. Use `get_affected_flows` to understand impact.
3. Use `query_graph` with `pattern="tests_for"` to check coverage.
