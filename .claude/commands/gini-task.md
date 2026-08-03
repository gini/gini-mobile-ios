---
description: Hand a Swift/iOS task to the Gini agent team — the gini-orchestrator routes it to the right specialists to review or implement per the repo standards.
argument-hint: <what you want done or reviewed>
---

Use the **gini-orchestrator** agent to coordinate the following task. Invoke it via the Task tool with `subagent_type: "gini-orchestrator"` and pass the task through.

Task:
$ARGUMENTS

gini-orchestrator will read the task, select the right specialists (uikit, swiftui, accessibility, testing), and enforce the standards in `CLAUDE.md`, `AGENTS.md`, and `.claude/rules/mandatory-rules.md` (MVVM + Coordinator, design-system namespaces, 3-level localization, `/** */` + `///` doc style, one-parameter-per-line initializers, no placeholders/stubs in production code — test mocks as manual protocol conformances per `CLAUDE.md` are allowed — built-ins first). Architecture, design-system, localization, concurrency, security, performance, and background-execution standards still apply and are enforced inline (their dedicated specialists are paused).

When it finishes, synthesize the specialists' findings into a single clear answer for me — grouped by specialist, most important issues first.
