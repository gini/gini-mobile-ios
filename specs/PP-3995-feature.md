# PP-3995: Add expandable info component to Bank SDK (SwiftUI)

Status: implemented
Ticket: https://ginis.atlassian.net/browse/PP-3995
Parent epic: [PP-3518 — Fraud prevention warnings – phase 1](https://ginis.atlassian.net/browse/PP-3518)

## Problem

The upcoming fraud warning screens (PP-3960 IBAN mismatch, PP-3962 IBAN
selection sheet, and the follow-up country-mismatch screen under PP-3518)
need a card that starts compact and expands to reveal detail on tap —
"what we found", a per-IBAN explanation, etc. The same affordance will be
reused across future SwiftUI screens in the Bank SDK and the Internal
Payment SDK. No such component exists in SwiftUI today; the only precedent
is `PaymentInfoQuestionHeaderViewCell` in `GiniInternalPaymentSDK` (UIKit
table cell).

The Figma design frame (node `39413-30230`, Gini Photo Payment file) shows
the collapsed card at 327 × 136 pt with the fraud-warning blue background
(`#C4DDF7` at 20% opacity). The consumer screens are vertically scrolling
SwiftUI views, so the component must grow in place inside a `ScrollView`
without jank and must announce state changes to VoiceOver.

## Requirements

**R1 (MUST, entry):** Given a SwiftUI parent view imports `GiniUtilites`
and owns `@State private var isExpanded: Bool`, when it instantiates
`GiniExpandableInfoView(viewModel:isExpanded:expandedContent:)` with that
state's binding, then the component renders at the collapsed layout when
`isExpanded == false` on first appearance — showing the caller-supplied
icon on the leading edge, the title, and a trailing chevron — and no
public API outside `GiniUtilites` is required. (Matches the `viewModel:`
config-struct precedent in `GiniCarouselView.swift:23-30` and SwiftUI's
own `DisclosureGroup(isExpanded:)` pattern.)

**R2 (MUST, happy path):** Given the component is visible in its collapsed
state and `isExpanded` is bound to a parent `@State`, when the user taps
the header (icon / title / chevron row), then the bound `isExpanded`
flips to `true`, the expanded-content view builder is rendered beneath
the header, and the chevron glyph rotates 180° to its "expanded"
position (or swaps to `chevron.up` under Reduce Motion — see R8). The
expanded-content area is **not** a toggle hit target; it carries its own
content and any sub-interactions, matching SwiftUI's own
`DisclosureGroup` behavior (resolved by review 2026-11-09).

**R3 (MUST, happy path):** Given the component is visible in its expanded
state, when the user taps the header, then the bound `isExpanded` flips
to `false`, the expanded-content view is removed with an opacity
transition, and the chevron rotates back to its "collapsed" position.

**R4 (MUST, happy path — ScrollView host):** Given the component is placed
inside a vertical `ScrollView { LazyVStack { … } }`, when it toggles
between states, then the component's intrinsic height updates (collapsed
height = Figma 136 pt at default Dynamic Type; expanded height = content
height) and the surrounding `ScrollView` reflows without clipping the
expanded content.

**R5 (MUST, entry — accessibility):** Given VoiceOver is active, when the
user focuses the header, then VoiceOver announces the header as a
button (SwiftUI `Button` role, not synthesized via `.accessibilityAddTraits`),
reads the title as the label, and reports the state via
`.accessibilityValue(Text(isExpanded ? expanded : collapsed))` where both
strings come from `GiniExpandableInfoViewModel.expandedAccessibilityValue`
/ `collapsedAccessibilityValue` (caller-owned localized strings — see
resolved open question #1). The expanded-content slot sits under the
header-button and is reachable as individually-navigable rotor elements
(outer uses `.accessibilityElement(children: .contain)`, resolved by
review 2026-11-09 — WCAG 2.4.3 / 1.3.1 rotor navigation of rich content).

**R6 (MUST, happy path — accessibility activation):** Given VoiceOver is
active and the header is focused, when the user performs the default
accessibility action (double-tap), then the component toggles its
expanded state exactly as in R2/R3. The same button is reachable through
Full Keyboard Access (Tab + Space) and Switch Control because the header
is a real SwiftUI `Button` — WCAG 2.1.1 / 2.4.7 (added by review
2026-11-09).

**R7 (MUST, happy path — Dynamic Type):** Given the host app sets the
preferred content size category to any value between `.extraSmall` and
`.accessibilityExtraExtraExtraLarge` (XS → AX5), when the component
renders in either state, then the title and the expanded content use
`.dynamicTypeSize(...)` propagation (no fixed `.font(.system(size:))`) so
text scales and does not get vertically clipped by the collapsed frame.

**R8 (MUST, happy path — Reduce Motion):** Given the system accessibility
setting "Reduce Motion" is enabled, when the component toggles, then no
`.animation(...)` modifier runs on the expand/collapse transition
(`@Environment(\.accessibilityReduceMotion)` guards the animation call)
**and** the chevron does not rotate — instead, the glyph swaps between
`chevron.down` (collapsed) and `chevron.up` (expanded), so the control
conveys state without any interpolated motion. WCAG 2.3.3 (added by
review 2026-11-09).

**R9 (MUST, happy path — design system):** Given a caller supplies a
`GiniColorScheme` (e.g. `UIColor.giniBankColorScheme()`), when the
component renders, then its background, title color, and chevron tint
resolve from that scheme (no hardcoded `Color(red:green:blue:)`), so the
component inherits the SDK's dark-mode colors through
`GiniColor.uiColor(from:)`.

**R10 (MUST, entry — initial state):** Given the caller initializes its
bound `@State` to `true` before the view appears, when the component is
first rendered, then it renders expanded, the expanded-content builder
has already been called once, and the chevron is in its rotated
position. (State ownership is always external — there is no
`initiallyExpanded` parameter on the view; the binding carries the
initial value.)

**R11 (MUST, happy path — external drive):** Given the caller mutates
the bound `isExpanded` from outside the component (e.g. to programmatically
collapse the card when a different UI element is tapped), when the binding
changes, then the component animates to match the new state using the same
transition as R2/R3 and without emitting a duplicate state write.

**R12 (MUST, happy path — icon):** Given the caller supplies a non-empty
`UIImage` in `GiniExpandableInfoViewModel.icon`, when the component
renders in either state, then the icon appears at the leading edge of
the header row, is sized at `Constants.iconSize` (fixed pt per Figma)
and scales with Dynamic Type via `.accessibility(hidden: true)` plus
`.scaledToFit()`. The icon is marked `accessibility(hidden: true)` so
it is not announced as a separate element — the combined-element label
(R5) already describes the card.

## Affected modules

| Module | Change kind | Why |
| --- | --- | --- |
| `GiniUtilites` | Add new SwiftUI source files + one localized `.strings` entry per locale + unit tests | The component is a reusable SwiftUI primitive. GiniUtilites is the shared SwiftUI home (next to `GiniHeightPreferenceKey`, `Font+Extensions`, `GiniColorScheme`) and it's a dependency of every downstream SDK. Minimum deployment target: iOS 15. |

No other module is touched by PP-3995 itself. The consumer screens
(PP-3960, PP-3962) are separate tickets and will add `import GiniUtilites`
in their own branches.

## Public API impact

`GiniUtilites` gains new `public` declarations (visibility is `public` for
cross-SPM-package access, not an invitation for integrators to use it —
mirrors `GiniHeightPreferenceKey`):

- `public struct GiniExpandableInfoViewModel` — a plain value-type
  configuration bundle (**not** `ObservableObject`), mirroring the
  `GiniCarouselViewModel` precedent at
  `GiniComponents/InternalPaymentSDK/GiniInternalPaymentSDK/Sources/GiniInternalPaymentSDK/PaymentReview/Views/GiniCarouselView.swift:10-15`.
  Stores immutable config:
  - `public let icon: UIImage`
  - `public let title: String`
  - `public let colorScheme: GiniColorScheme`
  - `public let titleFont: UIFont`
  - `public let expandedAccessibilityValue: String`
  - `public let collapsedAccessibilityValue: String`
  - `public init(icon: UIImage, title: String, colorScheme: GiniColorScheme, titleFont: UIFont, expandedAccessibilityValue: String, collapsedAccessibilityValue: String)`

  Icon is a required `UIImage` passed in by the caller (same shape as
  `PoweredByGiniViewModel.configuration.giniIcon` consumed by
  `PoweredByGiniSwiftUIView.swift:20-29` via `Image(uiImage:)`). Callers
  that have no icon pass `UIImage()` explicitly — making the parameter
  non-optional forces that decision at the call site and keeps the
  header layout stable.
- `public struct GiniExpandableInfoView<ExpandedContent: View>: View`
  with a **single init** — state ownership is always external via
  `@Binding<Bool>`, following SwiftUI's own `DisclosureGroup(isExpanded:)`
  shape:
  - `public init(viewModel: GiniExpandableInfoViewModel, isExpanded: Binding<Bool>, @ViewBuilder expandedContent: @escaping () -> ExpandedContent)`

Change kind: **additive only** — no existing declaration is modified,
renamed, or removed. Nothing in the Bank SDK, Capture SDK, Health SDK, or
API libraries changes.

Localization: **none added to `GiniUtilites`.** Resolved open question #1:
`GiniUtilites` ships no `Localizable.strings` today (its `Resources/` folder
contains only `GiniBrand.xcassets`). Rather than bootstrap a new locale
bundle + key convention for two strings, the view model carries the already-
localized accessibility values — matching the existing pattern for `title`.
Each consumer SDK supplies the strings from its own locale bundle at the
call site.

## Technical conventions

1. **Language & access control** — Swift; `public` where justified above
   (cross-package access), `internal` for helpers (e.g. a private
   `ChevronIcon` view or `Constants` enum). Doc style per
   `.claude/rules/mandatory-rules.md` (`/** */` on every new public
   declaration, `///` for inline). Copyright header: `© 2026 Gini GmbH`
   to match neighboring 2026 files (`GiniHeightPreferenceKey.swift`,
   `Font+Extensions.swift`).

2. **UI framework** — **SwiftUI** (the whole point of this ticket).
   Lives under
   `GiniComponents/Utilities/GiniUtilites/Sources/GiniUtilites/SwiftUI/`
   next to `GiniHeightPreferenceKey.swift`. Colors come from
   `GiniColorScheme` via `GiniColor.uiColor(from: ColorScheme)` →
   `Color(uiColor:)`; fonts via `Font(giniFont: UIFont)`
   (`Font+Extensions.swift`); spacing from a `private enum Constants`
   inside `GiniExpandableInfoView.swift`. No Liquid Glass adoption in
   this ticket.

3. **Architecture** — Lightweight **MV** (view + config struct), not
   MVVM-with-observable-object. `GiniExpandableInfoViewModel` is a
   plain value type that carries display configuration only;
   `isExpanded` is hoisted to the parent via `@Binding<Bool>`,
   mirroring Apple's `DisclosureGroup(isExpanded:)` and matching the
   repo's `GiniCarouselView(viewModel:)` precedent
   (`GiniComponents/InternalPaymentSDK/GiniInternalPaymentSDK/Sources/GiniInternalPaymentSDK/PaymentReview/Views/GiniCarouselView.swift:23-30`).
   No Coordinator — this is a reusable view primitive, not a screen.
   No static factory entry point: the component is constructed in-place
   by callers, not presented modally.

4. **Wiring** — Constructor injection via the `viewModel:` config
   struct + `isExpanded:` binding + `expandedContent:` closure. No
   singletons. No async code — toggling is synchronous on the main
   actor via SwiftUI state update, which the SwiftUI runtime guarantees
   runs on `@MainActor`. Because `GiniExpandableInfoViewModel` is a
   plain value type with no mutable state, concurrency isolation is a
   non-issue; the only mutable state (`isExpanded`) is owned by the
   parent view and therefore inherits the parent view's main-actor
   isolation.

5. **Localization** — **none in `GiniUtilites`**. Resolved open question
   #1: caller passes already-localized accessibility-value strings into
   `GiniExpandableInfoViewModel`, same shape as `title`. Consumer SDKs
   (GiniBankSDK / GiniCaptureSDK / etc.) own the keys and translations
   in their own locale bundles.

6. **Quality gates** — `make lint scheme=GiniUtilites` clean before
   push; re-run on CI parity destination (iPhone 17 / iOS 26.2) per
   platform.md note about local-vs-CI drift. Swift Testing framework
   for new test files (dominant in `GiniUtilitesTests/`). Multi-
   parameter `init` uses one-parameter-per-line formatting per
   `.claude/rules/mandatory-rules.md`.

## Design

### File layout

```
GiniComponents/Utilities/GiniUtilites/Sources/GiniUtilites/SwiftUI/
├── GiniHeightPreferenceKey.swift                 (existing)
├── GiniExpandableInfoView.swift                  (new — View + View.body)
└── GiniExpandableInfoViewModel.swift             (new — plain config struct)

GiniComponents/Utilities/GiniUtilites/Tests/GiniUtilitesTests/
└── GiniExpandableInfoViewModelTests.swift        (new — memberwise-init round-trip)
```

### Class sketch (view model — plain value type)

```swift
/** Immutable display configuration for `GiniExpandableInfoView`. */
public struct GiniExpandableInfoViewModel {
    public let icon: UIImage
    public let title: String
    public let colorScheme: GiniColorScheme
    public let titleFont: UIFont
    public let expandedAccessibilityValue: String
    public let collapsedAccessibilityValue: String

    public init(icon: UIImage,
                title: String,
                colorScheme: GiniColorScheme,
                titleFont: UIFont,
                expandedAccessibilityValue: String,
                collapsedAccessibilityValue: String) {
        self.icon = icon
        self.title = title
        self.colorScheme = colorScheme
        self.titleFont = titleFont
        self.expandedAccessibilityValue = expandedAccessibilityValue
        self.collapsedAccessibilityValue = collapsedAccessibilityValue
    }
}
```

### Class sketch (view — single init, external state)

```swift
public struct GiniExpandableInfoView<ExpandedContent: View>: View {
    private let viewModel: GiniExpandableInfoViewModel
    private let expandedContent: () -> ExpandedContent
    @Binding private var isExpanded: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(viewModel: GiniExpandableInfoViewModel,
                isExpanded: Binding<Bool>,
                @ViewBuilder expandedContent: @escaping () -> ExpandedContent) {
        self.viewModel = viewModel
        self._isExpanded = isExpanded
        self.expandedContent = expandedContent
    }

    public var body: some View { … }
}
```

### Call site (what a consumer screen writes)

```swift
@State private var isWarningExpanded = false

GiniExpandableInfoView(
    viewModel: .init(icon: UIImageNamedPreferred(named: "warningTriangle") ?? UIImage(),
                     title: Strings.ibanMismatchTitle,
                     colorScheme: UIColor.giniBankColorScheme(),
                     titleFont: textStyleFonts[.body]),
    isExpanded: $isWarningExpanded
) {
    VStack(alignment: .leading, spacing: 8) {
        Text(Strings.ibanMismatchBody)
        Text(Strings.ibanMismatchQrLabel)
        // …caller-owned localized content
    }
}
```

### Behavior

- **Header layout**: `HStack(spacing: Constants.headerSpacing)` with the
  icon on the leading edge (`Image(uiImage: viewModel.icon).resizable()
  .scaledToFit().frame(width: Constants.iconSize, height: Constants.iconSize)
  .accessibility(hidden: true)`), the title in the middle expanding to
  fill, and the chevron trailing. Matches the shape of
  `PoweredByGiniSwiftUIView.swift:20-29` where the Gini badge image
  sits in an `HStack` alongside text.
- **Hit target**: **header-only** `Button { toggle() } label: { HStack(...) }`
  wrapped in `.buttonStyle(.plain)`, so the header is the entire button
  (icon + title + chevron) and expanded content is not a toggle target.
  Matches `DisclosureGroup` behavior and keeps any interactive elements
  the caller places in the expanded slot free from nested-button
  semantics.
- **Chevron**: `Image(systemName: "chevron.down")` with
  `.rotationEffect(.degrees(isExpanded ? 180 : 0))`, tint from
  `colorScheme.content.navigation` (resolved open question #2). Under
  Reduce Motion the glyph swaps `chevron.down` ↔ `chevron.up` with zero
  rotation so state is conveyed without motion (R8).
- **Animation**: `.animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: isExpanded)` applied to the outer `VStack`, driving both the chevron rotation and the expanded-content container.
- **Expanded-content container**: a vertical `VStack` with
  `if isExpanded { expandedContent().transition(.opacity) }`. The
  `.transition(.opacity)` prevents a hard pop on reveal/dismiss; the
  outer `.animation(_:value:)` drives the fade. SwiftUI's layout grows
  the card to fit when expanded; collapsed frame is pinned via
  `.frame(minHeight: Constants.collapsedMinHeight)` so the initial
  render matches the 136 pt Figma spec but Dynamic Type can grow it.
- **Accessibility**:
  - Outer `.accessibilityElement(children: .contain)` so expanded
    content remains individually navigable (R5, review 2026-11-09).
  - Header is a real `Button` — `.isButton` trait is inherited, Full
    Keyboard Access / Switch Control reachable, default action
    activates toggle (R6).
  - `.accessibilityLabel(Text(title))` on the Button.
  - `.accessibilityValue(Text(isExpanded ? expandedState : collapsedState))`
    on the Button, strings from `viewModel.expandedAccessibilityValue` /
    `collapsedAccessibilityValue` (R5).
  - Icon and chevron both `.accessibility(hidden: true)` so they don't
    double-announce.
  - `.foregroundStyle(...)` everywhere (not deprecated `.foregroundColor`).
- **Toggle logic**: `Button(action: { isExpanded.toggle() })` writes
  through the external `@Binding<Bool>`. There is no local state and no
  second code path — the parent's `@State` is the single source of
  truth.

### Precedents referenced (read in this session)

- `GiniComponents/Utilities/GiniUtilites/Sources/GiniUtilites/SwiftUI/GiniHeightPreferenceKey.swift:1-17`
  — file-layout + copyright + public-visibility style for this folder.
- `GiniComponents/Utilities/GiniUtilites/Sources/GiniUtilites/Font/Font+Extensions.swift:21-23`
  — `Font(giniFont:)` constructor used for the title font.
- `GiniComponents/Utilities/GiniUtilites/Sources/GiniUtilites/Color/GiniColorScheme.swift:9-80`
  — `GiniColorScheme` token layout (Background, Content, etc.).
- `GiniComponents/InternalPaymentSDK/GiniInternalPaymentSDK/Sources/GiniInternalPaymentSDK/PaymentInfo/PaymentInfoQuestionHeaderViewCell.swift`
  — behavioral precedent for toggle + chevron rotation + accessibility
  mapping (UIKit).
- `GiniComponents/Utilities/GiniUtilites/Tests/GiniUtilitesTests/GiniConstraintMakerTests.swift:1-15`
  — Swift Testing header/import style for the new test file.

## Test plan

With state ownership hoisted to the parent, the component itself has no
mutable logic to unit-test. What remains testable at the primitive level
is the `GiniExpandableInfoViewModel` value-type contract (property
storage via memberwise init). Keep a small, honest suite there — do not
pad with mocks that test SwiftUI framework behavior.

New test file: **`GiniComponents/Utilities/GiniUtilites/Tests/GiniUtilitesTests/GiniExpandableInfoViewModelTests.swift`**
— new `@Suite`-based struct using Swift Testing (`import Testing`,
`#expect`), following the header style of `GiniConstraintMakerTests.swift`
(copyright 2026, suite name describes the class). Expected count:
**1 test** — anything more would be re-testing Swift's memberwise
initializer. Pick the one test that actually catches a regression
(accidentally dropping a parameter from the init).

| Test | Covers | Requirement |
| --- | --- | --- |
| `init_storesAllProperties` | `GiniExpandableInfoViewModel(icon:title:colorScheme:titleFont:)` round-trips its four inputs into the matching `let` properties | R1, R12 (config surface stays stable) |

### Not tested

- **Toggle behavior (R2, R3, R11)** — the toggle logic is one line
  (`isExpanded.toggle()`) on a parent-owned `@Binding`. Testing it
  would require either a SwiftUI harness (`ViewInspector`, not in
  this repo) or inventing a wrapper that defeats the "state is the
  parent's" invariant. The consumer screen's own view model (e.g.
  PP-3960's fraud-warning VM) owns the `@Published var isExpanded`
  and its tests will cover toggle + external-drive behavior there.
- **SwiftUI view rendering (`GiniExpandableInfoView` itself)** — the
  repo has no snapshot-testing library and no existing SwiftUI view
  tests in `GiniUtilitesTests` to imitate. R4 (`ScrollView` reflow),
  R5–R6 (VoiceOver), R7 (Dynamic Type), R8 (Reduce Motion), R9
  (`GiniColorScheme` resolution), R10 (initial-state render), and
  the chevron rotation in R2/R3 are verified by **manual QA** on the
  example app that will embed the consumer screen (PP-3960).
- **Framework behavior** — SwiftUI's `@Binding` propagation and
  system accessibility settings are not under test.

Manual QA plan hand-off (attached to the PP-3960 ticket, not this
one): toggle the card under VoiceOver, with Reduce Motion both on
and off, at Dynamic Type XS and AX5, in light and dark mode,
inside a `ScrollView` on a short and a tall screen.

## Out of scope

- The fraud warning screen itself (PP-3960) — lives in a separate
  ticket. This spec only ships the reusable primitive.
- The IBAN selection sheet (PP-3962).
- Country-mismatch warning variant.
- Country-mismatch combined screen.
- Any Bank SDK public API changes other than adding new `public`
  declarations inside `GiniUtilites`.
- UIKit variant of the component. If a UIKit screen later needs the
  same affordance, wrap this view in a `UIHostingController` from the
  call site — do not port.
- Snapshot or SwiftUI view tests (see "Not tested" for the reason).
- Documentation page for integrators (the component is deliberately
  not integrator-facing in intent, only technically `public`).

## Open questions

All resolved before build (2026-11-09):

1. **GiniUtilites locale bundle** — `GiniUtilites` ships no
   `Localizable.strings` today (Resources/ holds only `GiniBrand.xcassets`).
   Resolution: caller owns the two accessibility-value strings — new
   `expandedAccessibilityValue` / `collapsedAccessibilityValue` fields on
   `GiniExpandableInfoViewModel`.
2. **Chevron tint token** — `colorScheme.content.navigation`
   (exists in `GiniColorScheme.Content` at `GiniColorScheme.swift:55`).
3. **Icon rendering & size** — `.renderingMode(.original)` (caller's
   asset keeps its own colors, e.g. the multi-color warning triangle)
   with `Constants.iconSize = 24` pt matching the Figma 136 pt collapsed
   header.

## Implementation plan

- [x] 1. Add `GiniExpandableInfoViewModel.swift` — public plain-value
      configuration struct with the six fields (icon, title, colorScheme,
      titleFont, expandedAccessibilityValue, collapsedAccessibilityValue)
      and one-parameter-per-line init. (R1, R12)
- [x] 2. Add `GiniExpandableInfoView.swift` — public generic SwiftUI
      view with the single `(viewModel:isExpanded:expandedContent:)` init,
      header/chevron/expanded-content layout, Dynamic Type propagation,
      Reduce Motion-guarded animation, and the a11y modifiers (combine
      children, isButton trait, label, value, default action).
      (R1–R11)
- [x] 3. Add `GiniExpandableInfoViewModelTests.swift` — one Swift Testing
      `@Suite` with a single test that round-trips all six init
      parameters into the matching `let` properties. (R1, R12)
