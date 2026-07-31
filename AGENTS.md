This file defines how AI agents should operate in this repository.

All code, documentation, comments, pull request descriptions, and review outputs must follow the conventions defined in this file unless the user explicitly requests otherwise.

User instructions override these defaults only when they explicitly request a different format or style.

---

# Agent Instructions: Code Change Verification

## Verification

When reviewing code changes to `BankSDK/GiniBankSDK/` or `CaptureSDK/GiniCaptureSDK/`, verify:

### 1. Compilation Validation

```bash
# Validate affected SDK compiles
make lint scheme=GiniBankSDK    # For BankSDK changes
make lint scheme=GiniCaptureSDK # For CaptureSDK changes
```

---

## Pull Request Description Generation

When generating a pull request description:

### Requirements

- Use the repository PR template (`.github/pull_request_template.md`) exactly
- Extract the Jira ticket from the commit message
- Replace the placeholder ticket (e.g. PP-XXXX) with the real one
- Describe:
  - what changed
  - why the change was needed
  - how it was implemented (high level)
- Mention affected modules, SDKs, flows, or APIs explicitly
- Keep the description concise and reviewer-friendly

### Notes for Reviewers

Include:

- how the changes were verified
- test scenarios reviewers can follow
- unit/integration tests added or updated
- known limitations or follow-up work

### Rules

- Do not invent missing details
- Use only information from:
  - git diff
  - changed files
  - commit messages
- If something is unknown, state it clearly instead of guessing

---

## PR Template

The canonical PR template is [`.github/pull_request_template.md`](.github/pull_request_template.md) — the file GitHub pre-fills when a pull request is opened. Use it verbatim as the structure for every generated PR description; do not redefine or paraphrase the template here, so the two never drift apart.

Fill it in following the Requirements and Rules above:

- Replace the `[PP-####]` placeholder with the real Jira ticket from the commit message.
- Complete the **Pull Request Description** section — what changed and why, plus a high-level how.
- Complete the **Notes for Reviewers** section — how the changes were verified, tests added or updated, and anything that needs extra attention in review.

---

## Swift Documentation and Comment Style

Always write and rewrite Swift documentation and comments to match this exact house style. Do not preserve alternative documentation styles unless explicitly requested.

### Rules to Enforce

1. Use `///` only for inline explanatory comments inside function or method bodies.
2. Use `/** ... */` for declaration documentation on functions, methods, classes, structs, enums, protocols, properties, initializers, and extensions.
3. Do not use `///` as the documentation format for declarations.
4. Do not use other documentation styles unless the user explicitly overrides this rule.
5. Apply this style to all declarations, with extra care for public API.
6. Keep wording concise, neutral, and Apple-style.
7. Prefer present tense and describe what the symbol does, not what the developer was doing.
8. Use backticks for code identifiers, enum cases, types, and literal values such as `true`, `false`, and `nil`.

---

### Required Output Patterns

#### Declaration without parameters or return value

```swift
/**
 Brief summary sentence.
 Optional second sentence with important context.
 */
```

#### Declaration with one or more parameters

```swift
/**
 Brief summary sentence.
 - Parameters:
   - firstParameter: Description.
   - secondParameter: Description.
 */
```

#### Declaration with return value

```swift
/**
 Brief summary sentence.
 - Returns: Description of the returned value.
 */
```

#### Declaration with parameters and return value

```swift
/**
 Brief summary sentence.
 - Parameters:
   - firstParameter: Description.
   - secondParameter: Description.
 - Returns: Description of the returned value.
 */
```

#### Inline comment inside executable code

```swift
/// Explains the behavior of the next line or block.
```

---

### Style Guidance

- Start with a direct summary sentence. Keep the first line meaningful on its own.
- Add only information that helps the reader use or understand the symbol.
- Document behavior, side effects, defaults, constraints, and platform-specific details when relevant.
- For booleans, prefer wording like "Indicates whether…" or "Specifies whether…".
- For methods, start with an active verb: "Sets", "Updates", "Returns", "Configures", or "Retrieves".
- For protocols, explain the capability the protocol provides.
- Preserve valid markdown links when they add value.

### Rewrite Workflow

1. Determine whether the target is a declaration doc comment or an inline code comment.
2. Convert declaration docs to `/** ... */`.
3. Convert inline explanatory comments to `///`.
4. Normalize wording to concise Apple-style prose.
5. For declarations with multiple parameters, use `- Parameters:`.
6. For a single return value, use `- Returns:`.
7. Remove redundant, vague, or conversational phrasing.
8. Keep the original meaning unless the user explicitly asks for content changes.

---

### Preferred Examples

#### Inline comment

```swift
func configureBottomSheet(shouldIncludeLargeDetent: Bool = false) {
    // For iOS versions prior to 15, the view controller is presented as a standard modal sheet.
    if #available(iOS 15, *) {
        // ...
    }
}
```
// → used for inline comments inside method bodies ✅

/// → used for documentation comments on declarations (functions, classes, properties) ❌ for inline use

#### Public method

```swift
/**
 Sets the configuration flags back. Used only in the example app. See `SettingsViewController` for details.
 */
public func updateConfiguration(withCaptureConfiguration configuration: GiniConfiguration)
```

#### Public property

```swift
/**
 Indicates whether the Payment Due Hint feature is enabled.
 If set to `true`, a hint is displayed in the payment flow to remind the user about the upcoming payment due date.
 */
public var paymentDueHintEnabled: Bool = true
```

#### Method with parameters and return value

```swift
/**
 Retrieves the localized bundle for the specified locale key.
 - Parameters:
   - parentBundle: The parent bundle to search.
   - localeKey: The locale key for the localized bundle.
 - Returns: The localized bundle if found; otherwise, `nil`.
 */
private static func localizedBundle(parentBundle: Bundle, localeKey: String?) -> Bundle?
```

---

### Response Behavior

- When the user asks for a rewrite, return the rewritten Swift comments directly.
- When the user asks for a review, point out every violation against this style and show the corrected form.
- When generating new code documentation, produce comments in this style by default.

---

## graphify

This monorepo has a **graphify knowledge graph** at `graphify-out/` covering all six SDKs
(BankAPILibrary, HealthAPILibrary, CaptureSDK, BankSDK, HealthSDK, GiniComponents), built from
Swift/Ruby/shell AST plus semantic extraction over the docs.

### Rules

- Before answering architecture or codebase questions, read `graphify-out/GRAPH_REPORT.md` for
  the god nodes (`GiniCaptureSDK`, `GiniHealthAPILibrary`, `GiniConfiguration`,
  `GiniBankAPILibrary`, `GiniBankConfiguration` …) and the community structure.
- For cross-module "how does X relate to Y" questions, prefer graph traversal over grep — it
  follows the graph's EXTRACTED + INFERRED edges instead of scanning files:
  - `graphify query "<question>"` — broad context (BFS)
  - `graphify path "<A>" "<B>"` — shortest path between two concepts (e.g. `"GiniBankSDK" "GiniUtilites"`)
  - `graphify explain "<concept>"` — plain-language explanation of a node
- Open `graphify-out/graph.html` in a browser for the interactive community view.
- **The graph auto-rebuilds on branch switch** via a `post-checkout` git hook (AST-only, no API
  cost), installed at `.git/hooks/post-checkout`. This is the only hook installed: commits do
  **not** trigger a rebuild, and a plain `git pull` does **not** either (a pull fires no checkout).
- After a `git pull` (e.g. pulling `main`) that you don't follow with a branch switch, run
  `graphify update .` to refresh the graph against the pulled code.
- After changing **docs, images, or PDFs** in a session (the hook only covers code), run
  `/graphify --update` to fold them into the graph.
- To rebuild manually at any time: `graphify update .` (AST-only, no API cost).

---

## MCP Tools: code-review-graph (optional — only if configured)

> **NOTE:** The `code-review-graph` MCP server is **not currently connected** to this project.
> The tools below are only available once that MCP server has been added to the Claude Code /
> Claude Desktop config. Until then, use the `graphify` CLI commands in the `## graphify` section
> above and fall back to Grep/Glob/Read. graphify can expose a subset of these live via
> `/graphify --mcp` (tools: `query_graph`, `get_node`, `get_neighbors`, `get_community`,
> `god_nodes`, `graph_stats`, `shortest_path`).

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
