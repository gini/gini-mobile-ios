Commit Message Guidelines

This repository follows a structured commit message format based on Conventional Commits.

All commit messages must follow the template below.

Commit Message Format
```
<type>(<project>): <subject>

<body>

<ticket-id>
```


Type

<type> must be one of the following:

feat: New or modified features (including UI and public API changes)

fix: Bug fixes

refactor: Code changes without public breaking changes (no public API or UI modifications)

chore: Maintenance changes (dependency updates, lint fixes, warnings, etc.)

docs: Documentation-only changes

ci: CI/CD, build scripts, or automation config changes

Project

<project> refers to the module affected by the change.

Examples:

GiniBankSDK

GiniCaptureSDK

GiniHealthSDK

BankAPILibrary

HealthSDK

MerchantSDK

Rules:

If only one module is affected → use parentheses:

`feat(GiniBankSDK): Add error logging interface`

If multiple modules are affected or no specific module → omit parentheses:

`chore: Update SwiftLint configuration`
Subject

The subject line must:

Be written in imperative mood (e.g., "Add", "Fix", "Remove")

Be short and concise

Not end with a period

Clearly summarize the change

Good examples:

```
feat(GiniBankSDK): Add photo selection button
fix(GiniCaptureSDK): Prevent crash when document is nil
chore: Fix SwiftLint warnings
```


Body

The body should:

Explain what changed

Explain why it changed

Not explain implementation details (avoid describing how)

Use bullet points if helpful

Be concise but clear

Example:

```
feat(GiniBankSDK): Allow customization of background colors on help screens

- Add configuration option for help screen background colors
- Ensure backward compatibility with existing integrations

PIA-4102
```

Ticket ID

The last line of every commit message must contain the ticket ID.

Example:

`PIA-4102`
Configuration (Optional)

To use a local commit template:

git config --local commit.template .git-stuff/commit-msg-template.txt

If using Sourcetree:

Go to Repository Settings (⇧⌘,)

Paste only the non-comment lines into Commit Template

Important Rules

Do NOT include commented lines (# ...) in commit messages.

Always follow the defined format.

Always include a ticket ID on a new line.