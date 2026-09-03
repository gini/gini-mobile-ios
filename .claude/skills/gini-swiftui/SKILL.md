---
name: gini-swiftui
description: >
  SwiftUI conventions for the Gini iOS monorepo. Use when writing or reviewing
  SwiftUI in this repo (new BankSDK/CaptureSDK/HealthSDK UI is SwiftUI-first,
  plus the GiniBankSDKExampleSwiftUI example app): iOS-15+ API gating, design-system
  usage in SwiftUI, the 3-level localization chain, and when to fall back to
  UIKit instead. Backs the swiftui-specialist agent.
---

# gini-swiftui

Repo-local SwiftUI reference for the Gini iOS SDK monorepo. This is the knowledge source the `swiftui-specialist` agent relies on. It layers Gini specifics on top of general modern-SwiftUI practice — for the generic rules, defer to the global `swiftui-expert` skill if loaded; do not duplicate it here.

## Where SwiftUI is used here

- **New UI in `BankSDK`, `CaptureSDK`, and `HealthSDK` is SwiftUI-first** — build new screens/components in SwiftUI where feasible at the target's baseline (iOS 15+; Health iOS 17+), and fall back to UIKit only when SwiftUI can't meet the requirement (see "When to fall back to UIKit"). This is a going-forward default, **not** a mandate to rewrite existing UIKit screens.
- Much existing SDK UI remains **UIKit** — don't rewrite it wholesale; that stays `uikit-specialist` territory.
- New SwiftUI screens still ship behind the SDK's static `UIViewController` factory, embedded via `UIHostingController`. The public entry point signature does not change.
- SwiftUI also lives in **`GiniBankSDKExampleSwiftUI`** (the example app) and any SwiftUI surface an integrator builds on top of the SDKs.

## iOS baseline gating (important)

The monorepo baseline is **iOS 15+** (HealthSDK iOS 17+). Only use iOS 17+ APIs where the specific target is actually iOS 17+:

- `@Observable` / `@Bindable` → iOS 17+. Below 17, use `ObservableObject` + `@StateObject`/`@ObservedObject`. Do **not** treat `ObservableObject` as wrong on an iOS 15/16 target.
- `NavigationStack` is iOS 16+. On an iOS 15 target, `NavigationView` may still be required — gate with `if #available` or set the target explicitly.
- Always confirm the SwiftUI target's minimum before recommending a newer API.

## Design system in SwiftUI

Mirror the UIKit design-system rules — do not hardcode:

- **Colors:** prefer the shared semantic tokens in `GiniColorScheme` (GiniUtilites) via the SDK's scheme factory (e.g. `UIColor.giniBankColorScheme()`) when a matching token exists; otherwise fall back to `UIColor.GiniBank.*` / `UIColor.GiniCapture.*` with `GiniColor(light:dark:)`. Bridge either into SwiftUI via `Color(uiColor:)`. No raw `Color(red:…)` or system colors.
- **Fonts:** derive from `textStyleFonts[textStyle]` (bridge with `Font(uiFont)`), keep Dynamic Type working.
- **Spacing:** use a local `enum Constants`, not magic numbers.

## Localization in SwiftUI

Follow the 3-level lookup chain (host app → custom bundle → SDK bundle): resolve strings via the typed `LocalizableStringResource` accessors so integrators can override. Never inline literal `Text("…")` for user-facing copy, and localize `accessibilityLabel`/`accessibilityHint` too.

## State & composition (modern practice)

- Ownership: `@State` owns; `let`/`@Bindable` receives; `@Environment` for shared.
- `.task` for async loading (auto-cancels on disappear); avoid manual `Task {}` in `onAppear`.
- `LazyVStack`/`LazyHStack` for large collections; stable `Identifiable` IDs in `ForEach` (never array indices).
- No heavy work in `body`; no `AnyView` (use `@ViewBuilder`/`Group`).
- Prefer built-in SwiftUI (`.searchable`, `.refreshable`, `PhotosPicker`, `.sheet`) over custom reimplementations.

## Deprecated APIs (gate every replacement by min-iOS)

Only flag a replacement when the SwiftUI target actually supports it. On an iOS 15/16 target the old API may be the correct choice — do not flag it.

| Deprecated | Modern replacement | Min iOS for replacement |
|---|---|---|
| `.foregroundColor(_:)` | `.foregroundStyle(_:)` | 15+ (broadly available; safe to prefer) |
| `NavigationView` | `NavigationStack` / `NavigationSplitView` | 16+ |
| `ObservableObject` + `@StateObject`/`@ObservedObject` | `@Observable` + `@State`/`@Bindable` | 17+ |
| `.onChange(of:) { newValue in }` (single-param) | `.onChange(of:) { old, new in }` | 17+ (keep single-param below 17) |
| `.accentColor(_:)` | `.tint(_:)` | 15+ |

## Data-flow smells

- **No manual `Binding(get:set:)` in a view body.** Prefer `@State` + `.onChange(of:)`, or a binding derived from an owned source of truth. Manual bindings in `body` re-create every render and hide state ownership.
- **`Equatable` for expensive subviews.** When a subview recomputes on unrelated parent updates, conform its input to `Equatable` (or apply `.equatable()`) so SwiftUI can skip redundant `body` calls.
- Reconfirm ownership: `@State` owns; `let`/`@Bindable` receives; `@Environment` shares. `@ObservedObject` must never create the object it observes.

## Alerts, sheets & dialogs

- Drive `.alert`, `.sheet`, `.fullScreenCover`, `.confirmationDialog`, `.popover` from state — `isPresented:` Bool or `item:` `Identifiable`, not ad-hoc flags mutated in closures.
- One presentation source of truth per modifier; avoid stacking two `.sheet` on the same view. Prefer `item:` when the sheet needs the selected value.
- Localize all titles/messages/button labels through the 3-level chain.

## Accessibility

Apply `mobile-a11y-specialist` rules: labels/hints/traits on interactive elements, Dynamic Type, reading order, and Voice Control label-match. Route localized a11y strings through the localization chain. Concrete checks:

- **Icon-only buttons need a label.** Use `Button("Localized label", systemImage: "…") { }` (or an explicit `.accessibilityLabel`) — never an image-only closure with no label.
- **Reduce Motion.** Gate non-essential animation on `@Environment(\.accessibilityReduceMotion)`; provide a cross-fade or no-op fallback.
- **Dynamic Type.** No fixed frame heights that clip scaled text; verify at the largest accessibility sizes.

## When to fall back to UIKit

New BankSDK/CaptureSDK/HealthSDK UI defaults to SwiftUI, but fall back to UIKit (hand off to `uikit-specialist`) when:

- The screen is camera/`AVFoundation`-heavy capture, or relies on UIKit-only capabilities the SDK already implements.
- A required API isn't available at the target's baseline (iOS 15+; Health iOS 17+) and can't be gated cleanly with `if #available`.
- You'd be modifying an existing UIKit screen rather than adding a new surface — don't half-convert; keep it UIKit unless a full, reviewed migration is intended.

When feasibility is genuinely unclear, surface the tradeoff and ask before committing to a stack.
