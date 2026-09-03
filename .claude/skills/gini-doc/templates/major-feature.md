<!--
  MIRRORED FILE — must stay byte-identical to the same path in gini-mobile-ios
  (listed in .github/mirrored-skills.txt; synced by shared-skills.sync.yml).
  Platform-specific content is resolved from platform.md via [term: name] and
  [snippet: name] references — see SKILL.md Step 4.

  Template: major feature. Derived from the published "Cross-Border Payments"
  feature page in the developer documentation space.
  Use when the feature introduces a new extraction pipeline or result type,
  changes how results are delivered, or interacts with multiple existing features.
  Replace every [placeholder]; include a section only when source provides
  evidence for it; use a TOBEADDED comment for anything unverifiable.
-->

# [Feature Name]

> **Note:** To use the [Feature Name] feature, contact Gini Customer Support to have it enabled in the backend platform.

> **Info:** We highly recommend having a QA session with Gini before releasing the [Feature Name] feature to your customers.

[One paragraph: what the feature does, when it activates, and what the user experiences. Present tense, second person. Accurately reflect all supported input methods — camera capture, file import, documents opened via the share sheet — unless there is explicit evidence the feature is camera-only.]

## Configuration

The feature is controlled via the `[propertyName]` property on `[term: config-object]`. The **default value** is `[defaultValue]`.

**Enable [Feature Name]:**

[snippet: enable-configuration]

**Revert to the default behavior:**

[snippet: revert-configuration]

[Include only if the property is an enum-like type:]

The `[TypeName]` type defines the following values:

| Value | Description |
|---|---|
| `[value]` | [Description. Mark reserved values with "(Do NOT use, for future use only)".] |

> **Note:** [Automatic overrides the SDK applies when this feature is active — e.g. "When [value] is set, the SDK automatically disables [other feature], regardless of the values you pass to `[otherFlag]`. You do not need to disable these flags manually." Remove if none.]

## Extraction Result

When the user completes the capture flow with [Feature Name] active, the SDK delivers the extraction result via the `[term: sdk-entry-point]` result callback:

[snippet: result-callback]

With [Feature Name] active, the extraction result contains:

| Field | Behavior with [Feature Name] |
|---|---|
| `[fieldName]` | [What this feature sets, adds, or removes — including fields removed before the result is delivered.] |

**Accessing [Feature Name] fields:**

[Code block ([term: code-language]): complete example showing how to read the new fields from the result.]

[State the partial-result semantics if applicable — what counts as a valid result delivered as `[term: success-result-case]` vs. what is delivered as `[term: empty-result-case]`.]

## Sending Transfer Summary

[Include only if the feature changes how `sendTransferSummary` is called or adds a new overload. Name the exact overload to use — and the one NOT to use, if calling the wrong one sends incorrect feedback.]

[Code block ([term: code-language]): complete example.]

Call `sendTransferSummary` before calling `[term: cleanup-call]`, after the user has confirmed the payment. Provide the values the user has reviewed and confirmed — not the initially extracted values.

## Impact on Other Features

[One sub-section per existing feature whose behavior changes when this feature is active. Remove this entire section only if there are genuinely no interactions.]

### [Feature Name] and [Other Feature]

[What changes, the mechanism, and which configuration flags are ignored — e.g. "The [Other Feature] screen is not shown when `[propertyName]` is set to `[value]`. The `[compoundExtraction]` is removed from the result before the screen is evaluated, so the screen does not appear regardless of whether `[otherFlag]` is `true` in `[term: config-object]`."]

## Edge Cases

| Scenario | SDK behavior |
|---|---|
| [scenario — e.g. "The backend returns no [extraction]"] | [What the SDK does, naming the exact `[term: result-type]` delivered.] |

## UI Customization

[Include only if the feature renders user-visible UI. One sentence, matching the published pages:]

Find out how to customize the [Feature Name] feature [here]([term: ui-customization-guide-url]).

## Localization Keys

[Optional appendix — published feature pages normally cover strings in the UI Customisation Guides instead. Include only when QA explicitly needs the string keys on the feature page.]

| Key | Default (de) | Default (en) | Description |
|---|---|---|---|
| `[key]` | `[German default]` | `[English default]` | [What this string is used for.] |
