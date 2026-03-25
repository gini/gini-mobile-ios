---
name: swift-doc-style-enforcer
description: enforce a single swift documentation style for code comments and api documentation. use when writing, reviewing, or rewriting swift documentation comments for methods, functions, classes, structs, enums, protocols, properties, initializers, and extensions, especially in ios or sdk codebases. use when the user wants comments rewritten to follow a strict house style, apple-style wording, block doc comments with /** ... */, inline explanatory comments with ///, or wants to prevent other documentation styles.
---

Rewrite Swift documentation and comments to match this exact house style. Do not preserve alternative doc styles.

## Rules to enforce

1. // → used for inline comments inside method bodies ✅

  /// → used for documentation comments on declarations (functions, classes, properties) ❌ for inline use

2. Use `/** ... */` for declaration documentation on functions, methods, classes, structs, enums, protocols, properties, initializers, and extensions.
3. Do not use `///` as the documentation format for declarations.
4. Do not use other documentation styles unless the user explicitly overrides the rule.
5. Apply the style to all declarations, with extra care for public API.
6. Keep wording concise, neutral, and Apple-style.
7. Prefer present tense and describe what the symbol does, not what the developer was doing.
8. Use backticks for code identifiers, enum cases, types, and literal values such as `true`, `false`, and `nil`.

## Required output patterns

### Declaration without parameters or return value
Use this shape:

```swift
/**
 Brief summary sentence.
 Optional second sentence with important context.
 */
```

### Declaration with one or more parameters
Use this shape:

```swift
/**
 Brief summary sentence.
 - Parameters:
   - firstParameter: Description.
   - secondParameter: Description.
 */
```

### Declaration with return value
Use this shape:

```swift
/**
 Brief summary sentence.
 - Returns: Description of the returned value.
 */
```

### Declaration with parameters and return value
Use this shape:

```swift
/**
 Brief summary sentence.
 - Parameters:
   - firstParameter: Description.
   - secondParameter: Description.
 - Returns: Description of the returned value.
 */
```

### Inline comment inside executable code
Use this shape:
// → used for inline comments inside method bodies ✅

/// → used for documentation comments on declarations (functions, classes, properties) ❌ for inline use


## Style guidance

- Start with a direct summary sentence.
- Keep the first line meaningful on its own.
- Add only information that helps the reader use or understand the symbol.
- Document behavior, side effects, defaults, constraints, and platform-specific details when relevant.
- For booleans, prefer wording like "Indicates whether..." or "Specifies whether..." for properties, and "A Boolean value that..." only when it reads naturally.
- For methods, start with an active verb such as "Sets", "Updates", "Returns", "Configures", or "Retrieves".
- For protocols, explain the capability the protocol provides and, when useful, include brief notes and topic groupings.
- Preserve valid markdown links when they add value.

## Rewrite workflow

1. Determine whether the target is a declaration doc comment or an inline code comment.
2. Convert declaration docs to `/** ... */`.
3. Convert inline explanatory comments to `///`.
4. Normalize wording to concise Apple-style prose.
5. For declarations with multiple parameters, use `- Parameters:`.
6. For a single return value, use `- Returns:`.
7. Remove redundant, vague, or conversational phrasing.
8. Keep the original meaning unless the user asked for content changes.

## Preferred examples

### Inline comment
```swift
func configureBottomSheet(shouldIncludeLargeDetent: Bool = false) {
    /// For iOS versions prior to 15, the view controller is presented as a standard modal sheet.
    if #available(iOS 15, *) {
        // ...
    }
}
```

### Public method
```swift
/**
 Sets the configuration flags back. Used only in the example app. See `SettingsViewController` for details.
 */
public func updateConfiguration(withCaptureConfiguration configuration: GiniConfiguration)
```

### Public property
```swift
/**
 Indicates whether the Payment Due Hint feature is enabled.
 If set to `true`, a hint is displayed in the payment flow to remind the user about the upcoming payment due date.
 */
public var paymentDueHintEnabled: Bool = true
```

### Method with parameters and return value
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

## Response behavior

When the user asks for a rewrite, return the rewritten Swift comments directly.
When the user asks for a review, point out every violation against this style and show the corrected form.
When generating new code documentation, produce comments in this style by default.
