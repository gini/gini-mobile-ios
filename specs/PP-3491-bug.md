# PP-3491: [iOS] RA invoice Landscape mode: while editing article unit price, field is covered by keyboard and not visible on iPhones

Status: fixed
Ticket: https://ginis.atlassian.net/browse/PP-3491

## Symptom

On iPhone (landscape, any iOS 15.8 → 26.5), when the user taps "Edit" on a
Return Assistance / Digital Invoice line item and starts editing a field —
most visibly the **unit price** — the on-screen keyboard appears **on top of
the active text field**. The field is not scrolled into view and the user
has to type blind. Portrait is fine. iPad is fine (keyboard sits below the
form). Repro on iPhone 7 Plus, iPhone XR, iPhone 11, iPhone 16.

## Reproduction

1. Open `GiniBankSDKExample`, scan/upload a Return Assistance (digital)
   invoice.
2. Tap *Get started* on the Digital Invoice notification.
3. Rotate the iPhone to landscape.
4. Tap *Edit* on any line item.
5. Tap the unit-price field.

Expected: field visible above the keyboard. Actual: keyboard covers the
field.

## Root cause

`BankSDK/GiniBankSDK/Sources/GiniBankSDK/Core/ReturnAssistant/EditLineItem/EditLineItemViewController.swift`
hosts the edit form inside an `EmptyScrollView` that is pinned to the
view's edges (lines 103–108):

```swift
scrollView.giniMakeConstraints {
    $0.edges.equalToSuperview()
}
```

The scroll view's bottom therefore sits behind the keyboard. UIKit's
automatic *scroll-first-responder-into-view* logic uses the scroll view's
own bounds to decide whether the first responder is already visible —
from the scroll view's perspective the price field *is* visible (its frame
sits inside the scroll view's rect), so UIKit does nothing. The keyboard,
which lives in a separate window above the sheet, happens to be drawn on
top of that "visible" region. Hence the occlusion.

Portrait and iPad hide the defect incidentally: on portrait iPhone the
form fits above the keyboard; on iPad the keyboard docks below the sheet.

Supporting observation (not the primary bug, but exposed in the same
file): `activeTextField` is declared at line 28 and read in the
`viewWillTransition` completion at line 93, but is never assigned
anywhere in the repo — the post-rotation `becomeFirstResponder()` call is
a no-op today. The chosen fix doesn't need `activeTextField`, so this is
noted but left for a separate ticket (see Out of scope).

## Proposed fix

Use UIKit's `view.keyboardLayoutGuide` (iOS 15+, matches our minimum
deployment target) to tie the scroll view's bottom to the keyboard's top.
When the keyboard is docked, the scroll view shrinks; when it's hidden, the
scroll view returns to the view's bottom. UIKit then handles
"scroll-first-responder-into-view" automatically because the active field
is genuinely outside the shrunken scroll bounds.

Scope: a single file — `EditLineItemViewController.swift`. No public API
change. No design-system or layout changes to `EditLineItemView`. No
notifications, no inset math, no first-responder tracking.

Concrete change in `setupScrollView()`:

```swift
private func setupScrollView() {
    view.addSubview(scrollView)
    scrollView.giniMakeConstraints {
        $0.top.equalToSuperview()
        $0.leading.equalToSuperview()
        $0.trailing.equalToSuperview()
    }
    // Pin the scroll view's bottom to the keyboard's top so UIKit's
    // automatic scroll-first-responder-into-view can act on the real
    // visible region. When the keyboard is undocked / absent, this
    // guide tracks `view.safeAreaLayoutGuide.bottomAnchor`.
    scrollView.bottomAnchor
        .constraint(equalTo: view.keyboardLayoutGuide.topAnchor)
        .isActive = true
}
```

(The one-line constraint is written in the native AutoLayout API because
the `view.gini` DSL doesn't expose a layout-guide anchor — this is the
same pattern Apple's own documentation uses for `keyboardLayoutGuide`.)

Behaviour matrix:

| Context                         | `keyboardLayoutGuide.topAnchor` tracks | Result |
|---------------------------------|----------------------------------------|--------|
| Keyboard hidden                 | `safeAreaLayoutGuide.bottomAnchor`     | Scroll view fills the view, unchanged. |
| iPhone portrait, keyboard up    | Keyboard top                           | Scroll view shrinks; field auto-scrolls into view. |
| iPhone landscape, keyboard up   | Keyboard top                           | **Fixes PP-3491.** |
| iPad, docked keyboard           | Keyboard top                           | No visible change (form already above keyboard). |
| iPad, undocked / floating       | `safeAreaLayoutGuide.bottomAnchor`     | Unchanged. `keyboardLayoutGuide.followsUndockedKeyboard` defaults to `false`, which is the correct behaviour here. |

Rotation: `viewWillTransition` already calls `view.endEditing(true)`
(line 90), which dismisses the keyboard, so the `keyboardLayoutGuide`
returns to the safe-area anchor during the rotation animation. The
existing orientation-constraints rebuild for `editLineItemView` is
untouched.

## Out of scope

- The dead `activeTextField` reference on lines 28 / 93 — the chosen fix
  removes the need for it, but deleting unused state is a separate cleanup
  (file follow-up ticket if desired).
- Linked ticket **PP-1658** (Save/Cancel validation for landscape RA
  editing) — different flow, separate acceptance criteria.
- Similar edit flows elsewhere in the SDK — `SkontoViewController` and
  `DigitalInvoiceSkontoViewController` already solved this with the older
  observer pattern. Migrating them to `keyboardLayoutGuide` is a
  consistency improvement but outside the scope of a bug fix for PP-3491.
- No visual / design-system tweak to the edit form.
- No change to `GiniBottomSheetViewController` or sheet detents.

## Regression test plan

Per user direction, implement the fix directly rather than TDD-first. A
unit test for `keyboardLayoutGuide` behaviour is not meaningful without a
real keyboard — the layout guide only moves when `UIKeyboard` actually
docks, which requires either a UI test on a hardware-like simulator or
`UITextInputMode` + first-responder setup that defeats the point of a unit
test. Verification happens via the manual reproduction in step 2 above
(iPhone 16 / iOS 26.2 simulator in landscape) and by running the existing
`EditLineItemViewControllerTests` suite to confirm nothing in the current
behaviour regresses.

If QA later wants an automated guard, the right home is a UI test in
`GiniBankSDKExampleUITests` (new case: enter edit-line-item, rotate to
landscape, tap price field, assert the field is visible) rather than a
unit test — tracked separately.

## Open questions

- The ticket is priority *Low* (Valentina: "I would deprioritize fixing
  this issue … We can fix it later."). Proceeding anyway because it is
  in-sprint and assigned.
- Any Figma reference? The ticket's "Figma link for UI-related bugs"
  marker is empty, so no visual change is assumed — pure behaviour fix.
