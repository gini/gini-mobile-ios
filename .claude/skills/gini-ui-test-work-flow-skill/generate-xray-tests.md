---
name: generate-xray-tests
description: "Generates manual test cases from Jira tickets, local spec files, or pasted acceptance criteria and writes them as a CSV ready to import into Xray Cloud (Jira). Runs stand-alone (no repo required) or inside a repository. Use when asked to generate, create, or write Xray test cases for any product or feature."
---

# Skill: generate-xray-tests

Generate manual test cases for a mobile SDK feature and write them as a CSV file ready to import into Xray Cloud (Jira).

---

## Usage

```
/generate-xray-tests --product <product> [--platform <ios|android>] [--test-type <type>] [--summary-prefix <prefix>] --out <path> [<source>]
```

`--product` and `--out` are **required**.
If any required argument is missing, **stop and ask the user**. Do not infer or guess.

This skill is **stand-alone** — it does not require a Gini repository or any specific codebase.
Run it from anywhere. Repo-specific features (platform auto-detection, `.strings` label lookup)
degrade gracefully when no repo is present (see the relevant arguments below).

**Reference:** `references/example-tests.csv` is the canonical example of the expected CSV output
shape — column layout, step wording, `Data` values, and `Expected Result` style. When generating,
match that file's shape. See [Reference output shape](#reference-output-shape) below.

---

## Arguments

### `--product`

The name of the SDK, app, or product being tested. Any string is accepted.
Used in context and to name the app the test steps are written against.

If the product maps to a known demo app, steps reference that app by name. The table below
lists known Gini mappings as **examples** — it is not an allowlist. Any other product name is
valid; steps then reference "the <product> app" (or the app name the user gives).

| Example value | SDK | Demo app used for test steps |
|---|---|---|
| `GiniBankSDKExample` | GiniBankSDK | GiniBankSDKExample |
| `GiniHealthSDKExample` | GiniHealthSDK | GiniHealthSDKExample |

### `--platform`

`ios` or `android`. Determines the gestures, UI labels, and navigation patterns used in steps.

Resolution order:
1. If `--platform` is passed, use it.
2. Else, if running inside a known repository, auto-detect:
   - iOS repository (e.g. `gini-mobile-ios`) → `ios`
   - Android repository (e.g. `gini-mobile-android`) → `android`
3. Else (stand-alone, no repo, no flag) → **ask the user**. Do not guess.

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
- **Repo-only.** This step applies only when running inside a repository that contains the product's localization files. In stand-alone use (no repo), skip it entirely and take labels from the AC/spec and the example CSV wording.
- **Label accuracy only.** Use strings files only to get precise wording (e.g. the button says `"Photopayment"` not `"Photo Payment"`). Never use them to infer feature behaviour.
- **Platform-scoped.** Read strings for the resolved platform (iOS → `en.lproj`, Android → `res/values/strings.xml`). Skip if strings are unavailable or would make the test platform-specific.
- **Optional.** If the strings file is unavailable or the label is sufficiently clear from the AC, skip this step.

### Step 2 — Infer coverage areas

Do **not** use a fixed list of coverage areas. Instead, derive them from the source:
- Each distinct behavior, configuration value, screen, or condition described in the AC or spec becomes a candidate coverage area.
- Group related scenarios under the same area.
- Order areas from core flows → conditional behaviors → edge cases → regression tests.
- **Always include at least one regression test case** for every condition that disables or restricts a feature: add a scenario that removes the condition and confirms the feature re-enables. This is AC-driven coverage — it validates the negative path explicitly.
- **Localized copy (e.g. EN/DE screen texts) is never its own coverage area** — see the localized-copy rule in Step 3.
- **Accessibility criteria collapse into a single coverage area when the feature is one small screen** — see the accessibility consolidation rule in Step 3.

### Step 3 — Generate test cases

For each coverage area, generate test cases following these rules:

**Steps must reflect hands-on usage of the demo app — not the source code:**
- All steps are written from the perspective of a tester interacting with the product's demo app on the detected platform.
- Never read `.swift` source files, class names, configuration structs, or any implementation detail to write steps. If it is not visible on screen, it does not belong in a step.
- Describe what the tester sees, taps, and observes — **observable actions and outcomes only**.
- Use the screen names, button labels, navigation flows, and UI elements as they appear in the demo app.

The app the steps reference is the one named by `--product` (or its known demo-app mapping).
Known Gini mappings (examples, not an allowlist):

| `--product` | App referenced in steps |
|---|---|
| `GiniBankSDKExample` | GiniBankSDKExample |
| `GiniHealthSDKExample` | GiniHealthSDKExample |

For any other product, reference the app by the `--product` name.

**Observable behaviour rule — do not test internal state:**
Steps must describe what the tester can directly see or interact with. Never assert on internal configuration values, property states, or side-effects that are invisible on screen.

- ❌ `"The QR code scanning toggle turns OFF in Settings"` — this tests an internal override side-effect.
- ✅ `"Point the camera at a QR code — no detection overlay or banner appears and the document is processed as a regular image."` — this tests what the AC actually requires.

**Step granularity — follow the example CSV shape:**
`references/example-tests.csv` is the canonical style. Match it:
- Start each test case with a launch step (e.g. `"Launch the <product> app"` → `"The <product> app is launched"`).
- One logical step per row. A step may offer an equivalent either/or choice when the AC treats the paths as interchangeable (e.g. `"Scan / Upload a document"`) — mirror the example rather than forcing an artificial split.
- Keep genuinely distinct actions on separate rows; do not bundle two unrelated actions into one step.
- `Expected Result` may hold multiple observations; the example uses ` - ` dash-bullets for lists.

- ✅ `"Scan / Upload a document"` with Data `pdf/image` → `"The document is successfully captured."` (interchangeable paths — one row, per example)
- ❌ `"Tap the delete icon and then add a new page and re-upload."` — unrelated actions bundled; split these.

**Localized copy (EN/DE) — never separate test cases:**
Never generate standalone test cases whose sole purpose is verifying screen copy or its translations. Fold copy verification into the normal test cases as final observation step(s) on the specific screen the copy belongs to:
- The **primary/core test case** that first reaches a given screen or state ends with observation step(s) reading its visible texts (title, description, buttons).
- The `Expected Result` of those steps lists the exact copy for **every** required language from the AC, e.g. `EN: "Proceed Anyway" / DE: "Trotzdem fortfahren"`, plus any format rules (e.g. date displayed as dd.mm.yyyy).
- Use the `Data` column to note the language dimension, e.g. `device language = EN and DE (repeat observation in both languages)`.
- One screen, one carrier: other test cases that land on the same screen must not repeat the copy observation.

- ❌ A separate `... - Content - German copy` test case that repeats the whole flow just to read the texts.
- ✅ The core display-logic test case ends with `"Read the title, description, and buttons of the bottom sheet."` and an expected result listing the EN and DE copy.

**Accessibility — consolidate for small screens (auto-decide, ask only when unclear):**
When the AC contains accessibility criteria (VoiceOver, dynamic font sizes, contrast, landscape, external keyboard, …), decide their shape by the size of the UI under test:
- **Single small screen or component** (one screen, bottom sheet, dialog, banner): generate **one** consolidated accessibility test case. It navigates to the screen once, then verifies every accessibility criterion as sequenced observation steps. For criteria requiring device setup (VoiceOver, largest text size, external keyboard), order the steps as: apply the setting → observe → revert the setting before the next criterion. Put the setting in the `Data` column of each step.
- **Complex multi-screen feature**: keep separate accessibility test cases per criterion or per screen.
- **Borderline or unclear** which of the two applies: ask the user which shape they want before generating. Do not guess silently.

- ❌ Five separate `... - Accessibility - <criterion>` test cases, each repeating the full navigation flow to a single bottom sheet.
- ✅ One `... - Accessibility - <screen> meets accessibility requirements` test case: reach the sheet once, then sequenced steps for Dynamic Type, VoiceOver, landscape, contrast, and keyboard, each with its own observation.

**Summary pattern:** `prefix - Area - Scenario`
Examples:
- `Cross-border Payments - SDK Initialization - productTag set to cxExtractions`
- `Cross-border Payments - QR Code Scanning - Disabled when productTag=cxExtractions`
- `Extraction Feedback - Payment Review - Updated value reflected in Invoice list`

### Step 3b — Deduplication check

Before proceeding to formatting, review all candidate test cases:
- If two test cases cover the same observable behaviour from the same starting state, merge them into one or drop the weaker one.
- A test case is a duplicate if its steps and expected results are functionally identical, even if the summary wording differs.

### Reference output shape

`references/example-tests.csv` (bundled with this skill) is the canonical example of a correct
output. Read it before generating and match its shape:

- **Header row:** `Issue Id,Summary,Test Type,Step,Data,Expected Result` — exact column order.
- **One row per step**, `Issue Id` repeated across a test case's rows, `Summary` filled only on the first row.
- **Launch-first pattern:** every test case opens with a launch step and its expected result.
- **`Data` column:** short concrete inputs like `pdf/image`, `productTag = cxExtractions`; empty when nothing specific applies.
- **`Expected Result`:** observable outcomes; multiple observations joined with ` - ` dash-bullets.
- **Quoting:** fields containing `,`, `"`, or line breaks wrapped in double quotes, inner `"` doubled (`""`).

Use the example for the *shape and wording style* only — never copy its scenarios. Every test
case must be derived from the actual source (AC/spec) per the rules above.

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
