# XCUITest reference

Consult this instead of recalling XCUITest APIs from memory. The framework has several near-miss names (`progressIndicators` not `progressViews`, `staticTexts` not `labels`) where a wrong guess produces code that reads correctly and matches nothing.

## Contents

- [Interactions](#interactions)
- [Queries](#queries)
- [Waiting and assertions](#waiting-and-assertions)
- [Accessibility identifiers](#accessibility-identifiers)
- [Permission dialogs](#permission-dialogs)
- [Screenshots and grouping](#screenshots-and-grouping)
- [Launch arguments](#launch-arguments)
- [Why each audit rule exists](#why-each-audit-rule-exists)

## Interactions

Taps:

| Call | Notes |
|---|---|
| `tap()` | On a text field it begins editing; on a button it fires the action |
| `doubleTap()` | Two taps in quick succession |
| `twoFingerTap()` | One tap, two fingers |
| `tap(withNumberOfTaps:numberOfTouches:)` | Full control over both counts |
| `press(forDuration:)` | Long-press gesture recognisers |

Gestures:

| Call | Notes |
|---|---|
| `swipeLeft()` / `swipeRight()` / `swipeUp()` / `swipeDown()` | No distance parameter — you cannot say how far |
| `pinch(withScale:velocity:)` | Scale < 1 zooms out, > 1 zooms in; velocity is scale-factor per second, 0 for a precise pinch |
| `rotate(_:withVelocity:)` | Angle in radians, velocity in radians per second |

Element-specific:

| Call | Notes |
|---|---|
| `typeText(_:)` | Types a whole string. Much faster than tapping `app.keys["t"]` one letter at a time |
| `adjust(toNormalizedSliderPosition:)` | 0 is the leading edge, 1 the trailing edge, regardless of the slider's own range. Use this rather than `swipeRight()`, which does not say how far |
| `adjust(toPickerWheelValue:)` | Scrolls a picker to a value |

## Queries

Element type collections: `buttons`, `staticTexts`, `textFields`, `secureTextFields`, `navigationBars`, `alerts`, `switches`, `sliders`, `progressIndicators`, `segmentedControls`, `tables`, `cells`, `collectionViews`, `scrollViews`, `images`, `otherElements`, `keyboards`, `pickers`, `keys`.

Two easy mistakes:

- **`staticTexts`, not `labels`.** XCUITest is cross-platform, and AppKit blurs the line between a text field and a label, so the generic name is what exists.
- **`progressIndicators`, not `progressViews`.** There is no `progressViews`.

Six ways to narrow a query:

| Form | Behaviour |
|---|---|
| `app.buttons["Blue"]` | Subscript by identifier, title, or label |
| `.element` | "There is exactly one of these." Throws if the query matches several |
| `.element(boundBy: n)` | Index into the matches |
| `.firstMatch` | Stop at the first match |
| `children(matching:)` | Direct children only |
| `descendants(matching:)` | The whole subtree — children, grandchildren, and down |

A subscript matches against identifier *or* title *or* label, which is why `app.buttons["Omega"]` and `app.segmentedControls.buttons["Omega"]` both work. That flexibility is also why an identifier and a piece of copy can collide.

Reading a value: `XCUIElement.value` is `Any?`, so it needs a cast, and the cast can fail:

```swift
guard let completion = app.progressIndicators.element.value as? String else {
    XCTFail("Unable to find the progress indicator.")
    return
}
XCTAssertEqual(completion, "0%")
```

Values often carry their formatting — a progress view reads back as `"0%"`, not `0.0`.

## Waiting and assertions

`waitForExistence(timeout:)` returns true as soon as the element appears, or false at the timeout. It is the right default:

```swift
XCTAssertTrue(app.alerts["Blue"].waitForExistence(timeout: 1))
```

A one-second timeout costs almost nothing when the element is already there and saves a spurious failure when it is not. Bare `exists` asks about this instant, which races against animation, layout, and network.

`isHittable` is stronger than `exists` — an element can exist while covered by another view or scrolled out of frame. When a tap "does nothing", `isHittable` is usually the check that explains why.

For waiting on something to *disappear*, use a predicate expectation:

```swift
let gone = NSPredicate(format: "exists == false")
let expectation = XCTNSPredicateExpectation(predicate: gone, object: element)
XCTWaiter().wait(for: [expectation], timeout: 30)
```

## Accessibility identifiers

Set on any UIKit or SwiftUI view, internal only, never read aloud by VoiceOver. `accessibilityLabel` *is* read aloud — do not repurpose it as a test hook.

```swift
// programmatic UIKit
confirmButton.accessibilityIdentifier = "skontoConfirmButton"

// xib / storyboard
// Identity inspector → Accessibility → Identifier

// SwiftUI
Button("Confirm") { … }
    .accessibilityIdentifier("skontoConfirmButton")
```

They are what makes a test survive a copy change, a translation, and a locale the suite has never seen. They are also what lets XCUITest find an element quickly, since the framework scans identifiers as it walks the tree.

## Permission dialogs

Two approaches, and the suite currently uses the weaker one.

Driving springboard directly means enumerating every button title in every language:

```swift
let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
springboard.buttons["Allow"]            // en
springboard.buttons["Nicht erlauben"]   // de
springboard.buttons["Don't Allow"]      // U+0027, iOS 26+
springboard.buttons["Don’t Allow"]      // U+2019, earlier
```

That last pair is a real trap already present in this repo — Apple changed the apostrophe, so a title match that worked stopped working on a new OS.

`addUIInterruptionMonitor` is the framework's own answer. It runs a closure whenever an interruption appears; return true if handled, false to let other monitors try. Monitors run in reverse order of registration:

```swift
addUIInterruptionMonitor(withDescription: "Allow camera access") { alert in
    alert.buttons["Allow"].tap()
    return true
}
```

The catch, and the reason the repo's TODO comments exist: a monitor fires only when the test next interacts with the app, so an interaction has to follow the action that triggered the dialog.

## Screenshots and grouping

Xcode screenshots every step automatically and deletes them for passing tests. Named attachments are for the moments you will want to look at later:

```swift
let attachment = XCTAttachment(screenshot: app.screenshot())
attachment.name = "Showing Skonto discount screen"
attachment.lifetime = .deleteOnSuccess
add(attachment)
```

`.deleteOnSuccess` keeps only failures. `.keepAlways` retains everything and gets expensive fast when a suite runs often. `XCTAttachment` also takes any `Codable`, `NSCoding`, or raw `Data` — useful for capturing an extraction payload beside the screenshot.

`XCTContext.runActivity(named:)` groups steps under a heading in the report. Purely organisational, and worth it for long flows:

```swift
XCTContext.runActivity(named: "Upload invoice and reach extraction") { _ in
    // …
}
```

## Launch arguments

Forcing initial state from the test side is fragile. Passing a flag the app reads at launch is not:

```swift
app.launchArguments = ["-StartFromCleanState", "YES"]
```

This repo already does exactly that, handled in `AppDelegate.swift`. The same hook is where animations get disabled, which removes a class of timing flake:

```swift
if CommandLine.arguments.contains("-StartFromCleanState") {
    UIView.setAnimationsEnabled(false)
}
```

XCUITest waits for the UI to come to rest after every synthesised action, so every animation is a pause.

## Why each audit rule exists

**Localised string lookups.** Couples a test to copy, translation, and locale coverage. Three independent reasons for it to break, none of them a real regression.

**`sleep(n)`.** Pays the full cost every run and still fails when the device is slower than the guess. `waitForExistence` returns the moment the element appears.

**`firstMatch`.** Legitimate when the element is genuinely unique. Otherwise it suppresses the error XCUITest would raise about a non-unique match — the ambiguity remains, the warning does not.

**`element(boundBy: n)`.** Indexes into a live UI. Reorder the layout and the test quietly exercises a different control. Xcode's recorder emits these (`boundBy: 6` with no explanation), which is why they cluster in recorded code.

**`descendants(matching:)`.** Walks the entire subtree. `children(matching:)` when the parent is known is both faster and more precise.

**Tests without assertions.** Pass whenever the app does not crash, which is not the property anyone wanted to verify.

**Simulator skips.** A suite guarded by `#if targetEnvironment(simulator) throw XCTSkip` reports success locally without running. Skipped is not passed.
