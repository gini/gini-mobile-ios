<!--
  MIRRORED FILE — must stay byte-identical to the same path in gini-mobile-ios
  (listed in .github/mirrored-skills.txt; synced by shared-skills.sync.yml).
  Platform-specific content is resolved from platform.md via [term: name] and
  [snippet: name] references — see SKILL.md Step 4.

  Template: configuration-flag feature. Derived from the published
  "Save Invoices Locally" and "Warnings & Hints" feature pages in the
  developer documentation space.
  Use when the feature is toggled by one configuration property and adds
  no new extraction result fields. When documenting several small related
  features on one page (the Warnings & Hints pattern), repeat this whole block
  once per sub-feature, each with its own H1.
-->

# [Feature Name]

> **Note:** To use the [Feature Name] feature, please contact Gini Customer Support to have it enabled in our backend platform.

[One or two paragraphs: what the feature does and when it activates. Name the OS mechanisms it uses (link the official documentation), the user-visible behavior on which screen, and timing/thresholds. If the user gets choices, list the calls to action:]

- [CTA label] → [what happens]
- [CTA label] → [what happens]

[State the supported input methods explicitly — e.g. "Supports photos and PDFs captured or imported via Camera, Upload, or Open With." — and any exclusions or interactions, e.g. "Excludes cases where Skonto or Return Assistant would be shown."]

> **Info:** This feature is enabled by default with the `[propertyName]` property set to `true` in `[term: config-object]`.

[If the feature is disabled by default, replace the Info line above with: "This feature is disabled by default. Enable it with the `[propertyName]` property in `[term: config-object]`."]

[snippet: flag-configuration]

Find out how to customize the [Feature Name] feature [here]([term: ui-customization-guide-url]).
