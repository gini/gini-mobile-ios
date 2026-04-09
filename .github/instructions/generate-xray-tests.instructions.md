---
description: Generates Xray-ready manual test case CSVs from Jira tickets, local spec files, or pasted AC. Reference this file in Copilot Chat with #generate-xray-tests.instructions.md and follow up with your request.
---

# Instruction: Generate Xray Test Cases

Generate manual test cases for a mobile SDK feature and format them as a CSV ready to import into **Xray Cloud** (Jira).

> **Note:** Copilot cannot write files to disk. After generating the CSV content, copy it from the chat and save it manually to the path you specified. To write the file automatically, use this skill in Claude Code instead (`/generate-xray-tests`).

---

## How to invoke

In Copilot Chat, reference this file and describe your request:

```
#generate-xray-tests.instructions.md

Generate Xray test cases:
--product GiniBankSDKExample
--out ~/Desktop/tests/output.csv

[paste your AC or spec here, or provide a Jira ticket ID]
```

---

## Arguments

| Argument | Required | Default | Description |
|---|---|---|---|
| `--product` | ✅ | — | `GiniBankSDKExample` or `GiniHealthSDKExample` |
| `--out` | ✅ | — | Intended output path (for reference — you must save the file manually) |
| `<source>` | ✅ | — | Jira ticket ID, local file path, or inline AC text |
| `--test-type` | ❌ | `Manual` | Must match a valid Xray test type in your project |
| `--summary-prefix` | ❌ | auto-derived | Feature or user story name prepended to every Summary: `prefix - Area - Scenario`. If omitted, a 2–4 word prefix is derived from the dominant topic of the AC. |

Platform is auto-detected from the repository the instructions file is used in (iOS repo → `ios`, Android repo → `android`). Do not pass `--platform`.

If any required argument is missing, stop and ask before proceeding.

---

## Step-by-step instructions

### Step 1 — Resolve the source

- **Jira ticket ID** (e.g. `PAY-123`): fetch the ticket's `summary`, `description`, and `acceptance criteria` via the Jira MCP tool if available. Otherwise ask the user to paste the content.
- **Local file path**: read the file content.
- **Inline text**: use the text provided in the message as-is.

Extract:
1. **Acceptance Criteria (AC)** — explicit conditions that must be met.
2. **Feature Specification** — behavior descriptions, config options, edge cases, screen names, limitations.

> **Source of truth rule:** AC and the demo app are the only inputs for generating test cases.
> Never read `.swift` source files or any other implementation file to infer behaviour.
> If a behaviour is absent from the AC, it is out of scope — do not add it based on what the code does.
> Reading a missing behaviour from the code would make the tests blind to the same gap.

### Step 1b — Resolve UI label accuracy (optional)

To use exact button and screen names in step wording, you may read the product's localization `.strings` files for the target platform. Rules:
- **Label accuracy only.** Use strings files only to get precise wording. Never use them to infer feature behaviour.
- **Platform-scoped.** Detect the platform from the repository (iOS → `en.lproj`, Android → `res/values/strings.xml`). Skip if strings are unavailable or would make the test platform-specific.
- **Optional.** If the strings file is unavailable or the label is sufficiently clear from the AC, skip this step.

### Step 2 — Infer coverage areas

Derive coverage areas from the source — do not use a fixed list:
- Each distinct behavior, config value, screen, or condition becomes a candidate coverage area.
- Group related scenarios under the same area.
- Order: core flows → conditional behaviors → edge cases → regression tests.
- **Always include at least one regression test case** for every condition that disables or restricts a feature: add a scenario that removes the condition and confirms the feature re-enables. This is AC-driven coverage — it validates the negative path explicitly.

### Step 3 — Generate test cases

**Steps must reflect hands-on usage of the demo app — not the source code:**
- Write from the perspective of a tester interacting with the demo app on the detected platform.
- Never read `.swift` source files, class names, configuration structs, or any implementation detail to write steps. If it is not visible on screen, it does not belong in a step.
- Describe what the tester sees, taps, and observes — **observable actions and outcomes only**.
- Use screen names, button labels, and UI elements as they appear in the demo app.

The demo app per product:

| `--product` | Demo app |
|---|---|
| `GiniBankSDKExample` | GiniBankSDKExample |
| `GiniHealthSDKExample` | GiniHealthSDKExample |

**Observable behaviour rule — do not test internal state:**
Steps must describe what the tester can directly see or interact with. Never assert on internal configuration values, property states, or side-effects that are invisible on screen.

- ❌ `"The QR code scanning toggle turns OFF in Settings"` — this tests an internal override side-effect.
- ✅ `"Point the camera at a QR code — no detection overlay or banner appears and the document is processed as a regular image."` — this tests what the AC actually requires.

**Step granularity — one atomic action per row:**
Each step row must contain exactly one action (a tap, a swipe, entering text, observing a result). Never bundle two actions or an action and an observation into the same step.

- ❌ `"Capture the document and proceed to the analysis screen."` — two actions in one step.
- ✅ Step 1: `"Tap the shutter button to capture the document."` / Step 2: `"Observe the screen that appears after capture."` — split into two rows.

**Summary pattern:** `prefix - Area - Scenario`
Examples:
- `Cross-border Payments - SDK Initialization - productTag set to cxExtractions`
- `Cross-border Payments - QR Code Scanning - Disabled when productTag=cxExtractions`
- `Extraction Feedback - Payment Review - Updated value reflected in Invoice list`

### Step 3b — Deduplication check

Before proceeding to formatting, review all candidate test cases:
- If two test cases cover the same observable behaviour from the same starting state, merge them into one or drop the weaker one.
- A test case is a duplicate if its steps and expected results are functionally identical, even if the summary wording differs.

### Step 4 — Format as CSV

Use `,` as the delimiter. Rules:
- Wrap any field containing `,` or line breaks in double quotes `"..."`.
- One row per test step. Repeat `Issue Id` for each step of the same test case.
- Fill `Summary` **only on the first row** of each test case. Repeat `Issue Id` and `Test Type` on every row.

**Columns:**

| Column | Description |
|---|---|
| `Issue Id` | `TC-001`, `TC-002`, … |
| `Summary` | Test case title following the summary pattern |
| `Test Type` | Value from `--test-type` |
| `Step` | What the tester does |
| `Data` | Concrete input values or configuration for this step. Populate whenever the step involves a specific setting, value, or document type — for example `productTag = cxExtractions`, `document type = invoice`, `QR code format = EPC`. Leave empty if no specific data applies. |
| `Expected Result` | What the tester expects to observe |

> **Do not include a `Precondition` column.** Xray Cloud expects that column to reference an existing Precondition issue key — passing free text causes a "Precondition type and test type mismatch" import error. Express all setup as explicit first steps in the test case instead.

### Step 5 — Output the CSV

Print the full CSV content in a code block so the user can copy it.
Then confirm with:

```
✅ <N> test cases, <M> rows — copy the CSV above and save it to <--out path>.
```

---

> All generated test cases require human review before import into Xray.
