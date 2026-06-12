---
name: generate-xray-tests
description: "Generates manual test cases from Jira tickets, local spec files, or pasted acceptance criteria and writes them as a CSV ready to import into Xray Cloud (Jira). Use when asked to generate, create, or write Xray test cases for a mobile SDK feature."
---

# Skill: generate-xray-tests

Generate manual test cases for a mobile SDK feature and write them as a CSV file ready to import into Xray Cloud (Jira).

---

## Usage

```
/generate-xray-tests --product <product> [--test-type <type>] [--summary-prefix <prefix>] --out <path> [<source>]
```

`--product` and `--out` are **required**.
If any required argument is missing, **stop and ask the user**. Do not infer or guess.

---

## Arguments

### `--product`

The name of the SDK or product being tested. Used in context and to determine which demo app test steps are written against.

| Value | SDK | Demo app used for test steps |
|---|---|---|
| `GiniBankSDKExample` | GiniBankSDK | GiniBankSDKExample |
| `GiniHealthSDKExample` | GiniHealthSDK | GiniHealthSDKExample |

### `--platform` (removed — auto-detected)

Platform is inferred from the repository the skill is running in:
- iOS repository (e.g. `gini-mobile-ios`) → `ios`
- Android repository (e.g. `gini-mobile-android`) → `android`

Steps are written using the appropriate gestures, UI labels, and navigation patterns for the detected platform. Do not ask the user for this value.

### `--summary-prefix`

Optional. A short human-readable feature or user story name prepended to every `Summary` using the same ` - ` separator as the existing pattern.

Example:
```
--summary-prefix "Cross-border Payments"
→ Cross-border Payments - QR Code Scanning - Disabled when productTag=cxExtractions
```

If omitted, derive a concise 2–4 word feature name automatically from the dominant topic of the AC/spec and use it as the prefix. The derived prefix must be human-readable and feature-focused — never a Jira ticket ID or a technical identifier.

Final summary format: `prefix - Area - Scenario`

### `--test-type`

The Xray test type value used in the CSV. Must match a valid type in the target Xray project.
Default: `Manual`

### `--out`

Absolute or relative path where the CSV file will be written.
Example: `--out ~/Desktop/xray-output/login-feature.csv`

If the directory does not exist, create it before writing.

### `<source>` *(optional)*

What to derive test cases from. Accepted formats:

| Format | Example | How it is read |
|---|---|---|
| Jira ticket URL | `https://company.atlassian.net/browse/PAY-123` | Use Atlassian MCP tool to fetch summary, description, and AC |
| Jira ticket ID | `PAY-123` | Same as above using short form |
| Local markdown file | `docs/features/cross-border-payments.md` | Read file directly from disk |
| Inline text | *(omit `<source>` — paste AC/spec text after the command)* | Use the text provided in the message |

---

## Step-by-Step Instructions

You are given `$ARGUMENTS`. Parse it to extract all flags and `<source>`, then follow these steps exactly.

### Step 1 — Resolve the source

- **Jira ticket URL or ID:** use the Atlassian MCP tool to fetch the ticket's `summary`, `description`, and `acceptance criteria` fields. If the MCP tool is unavailable, stop and ask the user to paste the content directly.
- **Local file:** read the file from disk.
- **Inline text:** use the text provided after the command as-is.

Extract two things from the source:
1. **Acceptance Criteria (AC)** — the explicit conditions that must be met.
2. **Feature Specification** — behavior descriptions, config options, edge cases, screen names, and known limitations.

> **Source of truth rule:** AC and the demo app are the only inputs for generating test cases.
> Never read `.swift` source files or any other implementation file to infer behaviour.
> If a behaviour is absent from the AC, it is out of scope — do not add it based on what the code does.
> Reading a missing behaviour from the code would make the tests blind to the same gap.

### Step 1b — Resolve UI label accuracy (optional)

To use exact button and screen names in step wording, you may read the product's localization `.strings` files for the target platform. Rules:
- **Label accuracy only.** Use strings files only to get precise wording (e.g. the button says `"Photopayment"` not `"Photo Payment"`). Never use them to infer feature behaviour.
- **Platform-scoped.** Detect the platform from the repository (iOS → `en.lproj`, Android → `res/values/strings.xml`). Skip if strings are unavailable or would make the test platform-specific.
- **Optional.** If the strings file is unavailable or the label is sufficiently clear from the AC, skip this step.

### Step 2 — Infer coverage areas

Do **not** use a fixed list of coverage areas. Instead, derive them from the source:
- Each distinct behavior, configuration value, screen, or condition described in the AC or spec becomes a candidate coverage area.
- Group related scenarios under the same area.
- Order areas from core flows → conditional behaviors → edge cases → regression tests.
- **Always include at least one regression test case** for every condition that disables or restricts a feature: add a scenario that removes the condition and confirms the feature re-enables. This is AC-driven coverage — it validates the negative path explicitly.

### Step 3 — Generate test cases

For each coverage area, generate test cases following these rules:

**Steps must reflect hands-on usage of the demo app — not the source code:**
- All steps are written from the perspective of a tester interacting with the product's demo app on the detected platform.
- Never read `.swift` source files, class names, configuration structs, or any implementation detail to write steps. If it is not visible on screen, it does not belong in a step.
- Describe what the tester sees, taps, and observes — **observable actions and outcomes only**.
- Use the screen names, button labels, navigation flows, and UI elements as they appear in the demo app.

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

Use `,` as the column delimiter. Apply these rules:
- Wrap any field containing `,` or line breaks in double quotes `"..."`.
- Use `<<!clear!>>` to explicitly clear a field value when needed.
- One row per test step. Repeat the `Issue Id` for each step of the same test case.
- Fill `Summary` **only on the first row** of each test case. Repeat `Issue Id` and `Test Type` on every row.

**CSV columns:**

| Column | Description |
|---|---|
| `Issue Id` | `TC-001`, `TC-002`, … |
| `Summary` | Test case title following the summary pattern above |
| `Test Type` | Value from `--test-type` |
| `Step` | What the tester does |
| `Data` | Concrete input values or configuration for this step. Populate whenever the step involves a specific setting, value, or document type — for example `productTag = cxExtractions`, `document type = invoice`, `QR code format = EPC`. Leave empty if no specific data applies. |
| `Expected Result` | What the tester expects to observe |

> **Do not include a `Precondition` column.** Xray Cloud expects that column to reference an existing Precondition issue key — passing free text causes a "Precondition type and test type mismatch" import error. Express all setup as explicit first steps in the test case instead.

### Step 5 — Write the file

Write the CSV to the path specified in `--out`. If the directory does not exist, create it.
Do **not** print the CSV content in the chat.
Confirm with a single line once done:

```
✅ Written to <path> — <N> test cases, <M> rows.
```

---

## Security

- Read any local file or Jira ticket for context.
- Write only to the path specified in `--out` (`.csv` files only).
- Never modify source code, documentation, or configuration files.
- Never run shell commands beyond reading files and calling the Atlassian MCP tool.
- All generated test cases require human review before import into Xray.
