<!--
  MIRRORED FILE — must stay byte-identical to the same path in gini-mobile-ios
  (listed in .github/mirrored-skills.txt; synced by shared-skills.sync.yml).
  Platform-specific content is resolved from platform.md via [term: name] and
  [snippet: name] references — see SKILL.md Step 4.

  Template: extraction / transfer-summary extension. Derived from the
  published "Instant Payment" feature page in the developer documentation
  space.
  Use when the feature adds or changes a field in the extraction result and/or
  the transfer summary, without a new pipeline or UI flow.
-->

# [Feature Name]

> **Note:** To use the [Feature Name] feature, please contact Gini Customer Support to have it enabled in our backend platform.

> **Info:** We highly recommend having a QA session with Gini before releasing the [Feature Name] feature to your customers.

[One paragraph: what triggers the new extraction — document content, QR code data, user action — and what the user experiences in the integrating app.]

You will see the [fieldName] extraction inside the specific extractions of `[term: success-result-case]`:

```json
[Example extraction payload showing the new field among existing ones, copied from verified source or the Gini Bank API documentation. Mark the new field with a comment.]
```

For more information about the document's extractions, see the Gini Bank API's [Document Extractions documentation](https://gini.atlassian.net/wiki/spaces/PA1/pages/36831473/Document+Extractions).

## Transfer summary with [feature name] information

After the user has reviewed and potentially corrected the extracted payment data, include the **[fieldName] flag** in the `sendTransferSummary` method to help improve the accuracy of future extractions.

[Code block ([term: code-language]): the `sendTransferSummary` call including the new field.]
