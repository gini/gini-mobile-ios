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

- Use the repository PR template exactly
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

### Pull Request Description

[JIRA-TICKET](https://ginis.atlassian.net/browse/JIRA-TICKET)

Briefly explain what this PR does and why it is needed.

Add a short high-level explanation of how it was implemented. Mention relevant refactoring, tradeoffs, or architectural decisions if applicable.

### Notes for Reviewers

Explain how the changes were verified.

Include:

- test scenario(s) reviewers can follow
- unit/integration tests added or updated
- manual validation performed
- anything that needs extra attention in review
- known limitations or follow-up work, if any

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
