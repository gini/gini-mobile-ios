# QA Skill: Generate Xray Tests — Claude Code

Generates manual test cases from a Jira ticket, local spec file, or pasted AC and writes them as a CSV ready to import into **Xray Cloud**.

---

## Files

```
.claude/skills/
├── generate-xray-tests/
│   └── SKILL.md                  # Skill prompt — Claude Code reads this when you run /generate-xray-tests
└── generate-xray-tests.md        # This file
```

---

## Prerequisites

| Tool | Required for |
|---|---|
| [Claude Code](https://claude.ai/code) | Running `/generate-xray-tests` and writing the CSV to disk |
| Atlassian MCP connector | Using a Jira ticket ID as the source (optional) |

---

## Arguments

| Argument | Required | Default | Description |
|---|---|---|---|
| `--product` | ✅ | — | `GiniBankSDKExample` or `GiniHealthSDKExample` |
| `--out` | ✅ | — | Output path for the CSV file |
| `<source>` | ✅ | — | Jira ticket ID, local file path, or inline AC text |
| `--test-type` | ❌ | `Manual` | Must match a valid Xray test type in your project |
| `--summary-prefix` | ❌ | auto-derived | Feature name prepended to every Summary: `prefix - Area - Scenario`. Auto-derived from AC if omitted. |

> **Platform is auto-detected** from the repository (`gini-mobile-ios` → iOS, `gini-mobile-android` → Android). Do not pass `--platform`.

---

## How to invoke

Start Claude Code in the repo root, then run the skill.

**From a Jira ticket:**
```
/generate-xray-tests --product GiniBankSDKExample --out ~/Desktop/tests/output.csv PP-1234
```

**From a local spec file:**
```
/generate-xray-tests --product GiniBankSDKExample --out ~/Desktop/tests/output.csv docs/features/cx-payments.md
```

**From inline AC (paste after the command):**
```
/generate-xray-tests --product GiniBankSDKExample --out ~/Desktop/tests/output.csv

When productTag=cxExtractions, the SDK does not scan for QR codes
When productTag=cxExtractions, QR Code Education is disabled in all journeys
When productTag=sepaExtractions, QR scanning behavior is unchanged
```

**With a custom summary prefix:**
```
/generate-xray-tests --product GiniBankSDKExample --summary-prefix "Cross-border Payments" --out ~/Desktop/tests/output.csv PP-1234
```
→ Every summary becomes: `Cross-border Payments - QR Code Scanning - Disabled when productTag=cxExtractions`

Claude writes the file and confirms:
```
✅ Written to ~/Desktop/tests/output.csv — 4 test cases, 26 rows.
```

---

## CSV format

```csv
Issue Id,Summary,Test Type,Step,Data,Expected Result
TC-001,"Cross-border Payments - QR Code Scanning - Disabled when productTag=cxExtractions",Manual,Launch the GiniBankSDKExample app.,,App launches and the main screen displays the "Photopayment" button.
TC-001,,Manual,"Open the iOS Settings app and set the product tag to cxExtractions.",productTag = cxExtractions,The setting is applied and saved.
TC-001,,Manual,Tap "Photopayment".,,The camera screen opens.
```

**Column rules:**
- `Summary` on the first row of each test case only
- `Issue Id` and `Test Type` repeated on every row
- No `Precondition` column — setup goes as explicit first steps (Xray expects issue keys there, not free text)

---

## How test steps are written

All test steps reflect hands-on usage of the **demo app** — never the repository source code.

- Steps describe what is visible and tappable on screen: button labels, screen names, gestures, observable results
- AC and the demo app are the only sources of truth — implementation files are never read to infer behaviour
- Each step is one atomic action (one tap, one observation) — never bundled
- Duplicate test cases covering the same observable behaviour are merged before output
- Every feature-disabling condition gets a regression test that restores the feature

| `--product` | Demo app |
|---|---|
| `GiniBankSDKExample` | GiniBankSDKExample |
| `GiniHealthSDKExample` | GiniHealthSDKExample |

---

## Importing into Xray Cloud

1. In Jira, go to **Apps → Xray → Test Cases**.
2. Click **Import** → **CSV**.
3. Upload the generated `.csv` file.
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

**`Unknown skill: generate-xray-tests` in Claude Code**
The skill must be a directory with a `SKILL.md` inside: `.claude/skills/generate-xray-tests/SKILL.md`. A flat `.md` file is not discovered.

**Jira ticket not found**
Enable the Atlassian MCP connector in Claude settings, or paste the ticket content directly as inline source text.

**`Precondition type and test type mismatch` on Xray import**
The CSV must not include a `Precondition` column with free text. The generated CSV does not include this column — if you see this error, check that no extra column was added manually.

**CSV fails to import into Xray**
Check that `--test-type` matches exactly the test type name configured in your Xray project (case-sensitive).
