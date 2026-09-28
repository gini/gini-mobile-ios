<!--
  MIRRORED FILE — must stay byte-identical to the same path in gini-mobile-ios
  (listed in .github/mirrored-skills.txt; synced by shared-skills.sync.yml).
  Platform-specific content is resolved from platform.md via [term: name] and
  [snippet: name] references — see SKILL.md Step 4.

  Template: OS-integration feature. Derived from the published "E-Invoice"
  feature page in the developer documentation space.
  Use when the feature requires app-level setup: manifest or entitlement
  declarations, new document formats, share-sheet entry points, or OS
  permissions.
-->

# [Feature Name]

> **Note:** To use the [Feature Name] feature, please contact Gini Customer Support to have it enabled in our backend platform.

> **Info:** We highly recommend having a QA session with Gini before releasing the [Feature Name] feature to your customers.

[One paragraph: regulatory or business context if relevant (e.g. a mandate or standard), then what the feature enables and which formats/inputs it supports.]

[Feature Name] entry points:

1. **[Entry point]** — [How the user reaches the feature and what changes in the UI (name UI elements by label, not position). Link the related guide.]
2. **[Entry point]** — [...]

## Setup [entry point] to support [format]

> **Note:** [Prerequisites — e.g. a related feature that is disabled by default and must be enabled first, with a link to its guide. Remove if none.]

[Why the app-level declaration is needed — what it enables from the user's perspective, e.g. "This enables your app to appear as a valid target when users attempt to open [format] files from other apps (e.g., Files, Mail)."]

### Declare supported document types

Add the following entry to your `[term: manifest-file]`:

[snippet: os-integration-declaration]

[Include only if the feature uses an OS permission requiring user consent — describe the built-in permission handling:]

This feature includes built-in permission handling:

- If the user has not been asked for [permission] before, the SDK requests it at runtime when [trigger action].
- If the user previously denied permission, the SDK [describe behavior — e.g. shows a rationale screen and redirects to Settings].

> **Warning:** Without the `[term: manifest-file]` entry the permission request will fail and the feature will not work.

Find out how to customize the [Feature Name] feature [here]([term: ui-customization-guide-url]).
