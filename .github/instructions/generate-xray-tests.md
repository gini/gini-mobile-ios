# QA Skill: Generate Xray Tests — GitHub Copilot Chat

Generates manual test cases from a Jira ticket, local spec file, or pasted AC and outputs them as a CSV ready to import into **Xray Cloud**.

> **Note:** Copilot cannot write files to disk. After generating the CSV content, copy it from the chat and save it manually to the path you specified. To write the file automatically, use the Claude Code skill instead (`/generate-xray-tests`).

---

## Files

```
.github/instructions/
├── generate-xray-tests.instructions.md   # Copilot Chat instruction prompt
└── generate-xray-tests.md               # This file
```

---

## Prerequisites

| Tool | Required for |
|---|---|
| GitHub Copilot Chat | Running the `#generate-xray-tests.instructions.md` workflow |
| Atlassian MCP connector | Using a Jira ticket ID as the source (optional) |

---

## Arguments

| Argument | Required | Default | Description |
|---|---|---|---|
| `--product` | ✅ | — | `GiniBankSDKExample` or `GiniHealthSDKExample` |
| `--out` | ✅ | — | Intended output path (for reference — save the file manually) |
| `<source>` | ✅ | — | Jira ticket ID, local file path, or inline AC text |
| `--test-type` | ❌ | `Manual` | Must match a valid Xray test type in your project |
| `--summary-prefix` | ❌ | auto-derived | Feature name prepended to every Summary: `prefix - Area - Scenario`. Auto-derived from AC if omitted. |

> **Platform is auto-detected** from the repository (`gini-mobile-ios` → iOS, `gini-mobile-android` → Android). Do not pass `--platform`.

---

## How to invoke

In Copilot Chat, reference the instructions file with `#` and follow up with your request.

**From inline AC:**
```
#generate-xray-tests.instructions.md

Generate Xray test cases:
--product GiniBankSDKExample
--out ~/Desktop/tests/output.csv

When productTag=cxExtractions, the SDK does not scan for QR codes
When productTag=cxExtractions, QR Code Education is disabled in all journeys
When productTag=sepaExtractions, QR scanning behavior is unchanged
```

**From a Jira ticket:**
```
#generate-xray-tests.instructions.md

Generate Xray test cases:
--product GiniBankSDKExample
--out ~/Desktop/tests/output.csv
PP-1234
```

**With a custom summary prefix:**
```
#generate-xray-tests.instructions.md

Generate Xray test cases:
--product GiniBankSDKExample
--summary-prefix "Cross-border Payments"
--out ~/Desktop/tests/output.csv

[paste your AC here]
```

Copilot outputs the CSV in a code block. Copy it and save it to the path you specified in `--out`.

---

## Importing into Xray Cloud

1. In Jira, go to **Apps → Xray → Test Cases**.
2. Click **Import** → **CSV**.
3. Upload the saved `.csv` file.
4. Map columns:
   - `Issue Id` → **Issue Id**
   - `Summary` → **Summary**
   - `Test Type` → **Test Type**
   - `Step` → **Step Action**
   - `Data` → **Step Data**
   - `Expected Result` → **Step Expected Result**
5. Review and confirm.

> Always spot-check the CSV before importing — generated test cases require human review.

---

## Troubleshooting

**Jira ticket not found**
Enable the Atlassian MCP connector in Copilot settings, or paste the ticket content directly as inline source text.

**`Precondition type and test type mismatch` on Xray import**
The CSV must not include a `Precondition` column with free text. The generated CSV does not include this column — if you see this error, check that no extra column was added manually.

**CSV fails to import into Xray**
Check that `--test-type` matches exactly the test type name configured in your Xray project (case-sensitive).
