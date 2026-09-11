# PP-2570 — Manual QA sequence (iOS)

Ticket: <https://ginis.atlassian.net/browse/PP-2570>
Figma: <https://www.figma.com/design/ZYpdKfpaHOpV7RV1TTWdEH/Gini-Photo-Payment--iOS---Android?node-id=35002-11776>
Related: PP-2572 (backend flag, blocks prod) · PP-2569 (design) · PP-2571 (Android sibling)

Walk this doc top-to-bottom. Each section is grouped by device so you don't reinstall constantly. Every check has a ☐ **Pass** / ☐ **Fail** box and a "Notes" line — mark them as you go so the results are legible after.

---

## 0. Preconditions (do once)

- ☐ On branch `PP-2570-ingredeint-brand` at HEAD (`d70cb2f1a` or newer).
- ☐ Xcode 26.2 or later. Open `GiniMobile.xcworkspace`.
- ☐ `AppDelegate.swift` contains the DEBUG override:
  ```swift
  #if DEBUG
      …
      GiniCaptureUserDefaultsStorage.ingredientBrandScreens = ["Analysis"]
  #endif
  ```
  (This lets the badge show without the PP-2572 backend flag.)
- ☐ Scheme `GiniBankSDKExample`, **Debug** configuration.
- ☐ Test material ready on the device / simulator:
  - At least one **invoice photo** in Photos (any invoice with a visible amount + IBAN).
  - At least one **invoice PDF** in Files (drag one into the simulator).
  - Optional: a **SEPA EPC QR code** on paper or another screen for the QR-detection flow (any European bank invoice with a payment QR works).
- ☐ **Figma pixel reference open** in a second window at
  <https://www.figma.com/design/ZYpdKfpaHOpV7RV1TTWdEH/Gini-Photo-Payment--iOS---Android?node-id=35002-11776>
  so you can compare visually against frames "5. Analyze (qr-code engagement, first time)" and "6. Analyze".

### What "clean install" means in this doc

Fastest reset without deleting the app icon:

```bash
xcrun simctl uninstall booted net.gini.bank.gini-bank-sdk-example.swift
```

then Cmd-R in Xcode. Or add `-StartFromCleanState` to the scheme's launch arguments (already wired in `AppDelegate.swift:34`). Either wipes the UserDefaults that hold `ingredientBrandScreens` + education display counters.

### What "the badge" looks like

`[Powered by gini]` — 90×23pt white rounded pill with dark grey "Powered by" text and pink `gini` wordmark. Theme-agnostic (same asset in light + dark). Centered horizontally, 16pt above the safe-area bottom.

---

## Section A — iPhone 17 / iOS 26.2, portrait (primary CI target)

### A1. Fresh install → Camera → capture → Review → Analysis (image, standard path)

- Setup:
  - ☐ Clean install per section 0.
  - ☐ Launch app. Tap the **Screen API** demo.
- Steps:
  - ☐ Camera opens. Point at an invoice, tap the shutter.
  - ☐ Review screen appears. Tap **Next** (right-side button, may be labeled "Weiter" in DE).
- Expected on Analysis:
  - ☐ Spinner + "Analyzing document…" (or "Dokument wird analysiert" in DE) centered vertically.
  - ☐ **Badge visible** at the bottom, centered horizontally, ~16pt above the home-indicator area. Matches Figma frame "6. Analyze".
  - ☐ Because this is an image doc, the **CaptureSuggestions banner** slides up from the bottom within ~1s.
  - ☐ Banner sits **ABOVE** the badge — badge is not covered.
  - ☐ Banner auto-dismisses after ~4s; badge remains in place.
- Notes: __________

### A2. Fresh install → Camera → SEPA QR detected → Analysis (bypasses Review)

Per Figma flow "5.2 QR code flow" and the PO decision to treat `"Analysis"` as the whole analyze user-journey, the badge is expected on BOTH the QR overlay (in-camera) AND the subsequent Analysis screen.

- Setup: ☐ Clean install. Screen API demo → Camera.
- Steps: ☐ Point camera at a SEPA EPC QR code. Green pill **"QR Code erkannt / QR code detected"** appears with a dark full-screen overlay covering the camera preview.
- Expected on the QR overlay (Figma frame `35002:12174`):
  - ☐ Dark 0.8-alpha overlay covers the camera preview.
  - ☐ **Badge visible** at the bottom of the overlay, centered horizontally, ~16pt above the home indicator.
  - ☐ Education content (if enabled) or "analysieren…" hint sits above the badge.
- Steps: ☐ Follow prompt / wait for automatic advance to Analysis.
- Expected on Analysis: ☐ Lands directly on Analysis (no Review). ☐ **Badge visible** again on the Analysis screen. ☐ No CaptureSuggestions banner (QR is a non-image trigger).
- Notes: __________

### A2b. Invalid QR / undetected QR — no badge on overlay

- Setup: ☐ On the camera screen from A2.
- Steps: ☐ Point at a QR that is **not** a SEPA EPC payment QR (e.g. a random Wikipedia link QR). A small red / incorrect pill appears at the top of the camera frame with a mostly-transparent overlay.
- Expected on the incorrect-QR overlay:
  - ☐ Background is **clear** (camera preview fully visible), only the incorrect-QR hint pill shows at the top.
  - ☐ **Badge is NOT visible** — a white pill floating on live camera preview would look wrong; Figma does not show it in this state.
- Notes: __________

### A3. Fresh install → Import from Photos → Review → Analysis

- Setup: ☐ Clean install. Screen API demo.
- Steps: ☐ Tap the gallery / import button → pick an invoice from Photos → Review → **Next**.
- Expected: ☐ Badge visible. ☐ CaptureSuggestions banner appears above badge (same as A1). ☐ Banner dismisses, badge remains.
- Notes: __________

### A4. Fresh install → Import from Files (PDF) → Analysis (bypasses Review)

- Setup: ☐ Clean install. Screen API demo.
- Steps: ☐ Import → Files → pick a PDF invoice.
- Expected: ☐ Lands directly on Analysis (no Review — PDFs skip Review). ☐ Badge visible. ☐ **No CaptureSuggestions banner** (image-only feature).
- Notes: __________

### A5. Open-URL from another app → Analysis

- Setup: ☐ Clean install. Kill the example app so it launches fresh from the URL.
- Steps: ☐ In Files, tap a PDF invoice → **Share** → choose **GiniBankSDKExample** (or "Copy to GiniBankSDKExample").
- Expected: ☐ Example app opens directly on Analysis (`isFromOtherApp` path). ☐ Badge visible.
- Notes: __________

### A6. Coexistence guard — badge survives banner removal

Covered implicitly by A1/A3. Explicit spot check:

- Setup: ☐ On the Analysis screen from A1/A3 with the banner visible.
- Steps: ☐ Tap **Close** (X) in the top-left to leave Analysis, then re-enter (repeat A1 quickly). If Close isn't available, wait for the banner to auto-dismiss.
- Expected: ☐ After banner dismisses, badge is still centered at the bottom in the same position.
- Notes: __________

### A7. No-regression on screens outside the analyze journey

Walk through the flow. The badge appears in the analyze user journey (QR overlay valid state + Analysis) — every other screen must be untouched:

- ☐ Onboarding screens (first launch only after clean install) — **no badge**.
- ☐ Camera screen (no QR in frame) — **no badge**.
- ☐ Camera screen with **invalid** QR (see A2b) — **no badge**.
- ☐ Review screen — **no badge**.
- ☐ Help / Menu screens (open from Screen API demo settings) — **no badge**.
- ☐ NoResults screen (if you can trigger it — e.g. capture a blank/black frame) — **no badge**.
- Notes: __________

---

## Section B — iPhone 17, landscape

Same device, rotate to landscape and repeat the critical checks. The Figma landscape spec (`35002:12312`) shows the badge stays pinned to the safe-area bottom, centered.

### B1. Rotate mid-Analysis

- Setup: ☐ Complete A1 up to landing on Analysis (in portrait).
- Steps: ☐ Rotate simulator (Cmd + ← or Cmd + →) while Analysis is visible.
- Expected: ☐ Badge remains centered horizontally, pinned above home indicator. ☐ No clipping. ☐ Spinner + text re-layout as normal, badge doesn't overlap them.
- Notes: __________

### B2. Enter Analysis while already landscape

- Setup: ☐ Clean install, rotate to landscape BEFORE tapping Screen API demo.
- Steps: ☐ Run A1 flow entirely in landscape.
- Expected: ☐ Badge visible at bottom, matches Figma landscape frame.
- Notes: __________

### B3. Rotate DURING CaptureSuggestions banner

- Setup: ☐ Run A1, and at the moment the banner slides up, rotate to landscape.
- Expected: ☐ Banner re-lays out. ☐ Banner still sits above badge. ☐ Badge still centered / not clipped.
- Notes: __________

---

## Section C — iPhone SE (3rd gen) — small screen

Small-screen check: safe-area bottom is closer to the bottom edge, less vertical room. Watch for overlap between the loading-text block and the badge.

### C1. Boot iPhone SE simulator

- Setup: ☐ In Xcode's destination picker, pick **iPhone SE (3rd generation)** on iOS 17.2 (or newest available). Run.
- ☐ Clean install still applies (installing to a new sim = fresh state).

### C2. Portrait — critical flow (A1 repeat)

- Steps: ☐ Screen API → Camera → capture invoice → Next.
- Expected: ☐ Badge visible, centered, above home indicator. ☐ Spinner + "Analyzing…" text visible above badge with clear vertical gap (no overlap). ☐ CaptureSuggestions banner sits above badge.
- Notes: __________

### C3. Landscape — critical flow

- Steps: ☐ Rotate to landscape, repeat A1.
- Expected: ☐ Badge visible, non-clipped, centered. ☐ Text/spinner don't overlap badge.
- Notes: __________

---

## Section D — iPad (large screen)

Pick any iPad simulator (iPad 10th gen or iPad Pro 11" both fine). Repeat critical flows in both orientations.

### D1. Portrait

- Setup: ☐ Clean install on iPad simulator. Screen API demo.
- Steps: ☐ Run A1 (capture → Review → Analysis).
- Expected: ☐ Badge visible at bottom, centered. ☐ Badge stays 90×23pt (does NOT stretch to fill iPad width). ☐ CaptureSuggestions banner above badge.
- Notes: __________

### D2. Landscape

- Setup: ☐ Rotate iPad to landscape.
- Steps: ☐ Run A1 again (or rotate mid-flow like B1).
- Expected: ☐ Badge still 90×23pt, centered, pinned to safe-area bottom. ☐ Not stretched.
- Notes: __________

### D3. Split View (optional stress test)

- Setup: ☐ On iPad landscape, open the app in Split View alongside Files or Safari.
- Steps: ☐ Run A1 with the example app taking half the screen.
- Expected: ☐ Badge still centered relative to the app's window, still 90×23pt, still visible.
- Notes: __________

---

## Section E — Accessibility

### E1. Dynamic Type at largest accessibility size

- Setup: ☐ Settings → Accessibility → Display & Text Size → Larger Text → toggle **Larger Accessibility Sizes** ON, drag the slider to the **max** (AX5).
- Steps: ☐ Re-launch example app, run A1.
- Expected: ☐ The loading text below the spinner **DOES** grow. ☐ The badge size **stays exactly 90×23pt** (does NOT scale — it's a brand mark, not text). ☐ Growing text does NOT overlap or push the badge.
- If the loading text grows enough to hit the badge zone, that's a **bug** — badge sits at safe-area bottom with 16pt inset; the loading container has `bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.padding)`, so it should stop above the badge.
- Notes: __________

### E2. VoiceOver

- Setup: ☐ Settings → Accessibility → VoiceOver ON. (On simulator: menu bar → Features → Toggle VoiceOver, or triple-tap Home.)
- Steps: ☐ Run A1 to land on Analysis. Swipe RIGHT repeatedly to move focus through elements.
- Expected: ☐ When focus lands on the badge, VoiceOver announces exactly **"Powered by Gini, image"**. ☐ Focus does NOT stop separately on an inner image element (only the container is focusable). ☐ The spinner / title / close button announce normally too.
- Notes: __________

### E3. Reduce Motion (regression check)

- Setup: ☐ Settings → Accessibility → Motion → Reduce Motion ON.
- Steps: ☐ Run A1.
- Expected: ☐ Badge appears normally (it's static — no animation to reduce). ☐ CaptureSuggestions banner may skip its slide animation but still positions above the badge.
- Notes: __________

---

## Section F — Dark mode

Badge PDF is theme-agnostic (single asset for light + dark).

### F1. System dark mode

- Setup: ☐ Settings → Display & Brightness → Dark. Or Xcode toolbar → Environment Overrides → Interface Style → Dark.
- Steps: ☐ Run A1.
- Expected: ☐ Analysis background switches to dark. ☐ **Badge is identical to light mode** — white pill, pink `gini` wordmark, dark grey "Powered by" text. (This is intentional and matches Figma.)
- Notes: __________

### F2. Toggle mid-Analysis

- Setup: ☐ Run A1 in light mode to land on Analysis.
- Steps: ☐ Toggle to dark mode without leaving the screen (Environment Overrides in Xcode is fastest).
- Expected: ☐ Everything except the badge re-renders for dark. ☐ Badge visually unchanged, no re-layout, no flicker beyond the standard trait update.
- Notes: __________

---

## Section G — Education flow (Figma flow "5. Analyze (qr-code engagement, first time)")

Only fires with `qrCodeEducationEnabled: true` in storage AND the captureInvoice display counter < 2. The DEBUG override doesn't turn this on. To test:

- ☐ Add `GiniCaptureUserDefaultsStorage.qrCodeEducationEnabled = true` right after the `ingredientBrandScreens` line in `AppDelegate.swift`. Rebuild.

### G1. First-time education flow

- Setup: ☐ Clean install (so the education display counter is 0).
- Steps: ☐ Camera → capture invoice → Review → Next. (Must be a non-imported image doc for this to fire.)
- Expected on Analysis: ☐ `QRCodeEducationLoadingView` (animated education content) shows centered. ☐ **Badge visible at bottom**, no overlap with the education view. ☐ Matches Figma frame "5. Analyze (qr-code engagement, first time)".
- Notes: __________

### G2. Second-time education flow

- Setup: ☐ Same install, back out and repeat G1.
- Expected: ☐ Education animation runs a second time. ☐ Badge still visible at bottom.
- Notes: __________

### G3. Third time → falls back to plain state, badge stays

- Setup: ☐ Same install, repeat G1 a third time.
- Expected: ☐ Education counter hit its max (2). Plain spinner + text state shows instead. ☐ Badge still visible.
- Notes: __________

### G4. Clean up

- ☐ Remove the `qrCodeEducationEnabled` line you added (not shipping in this ticket — it belongs to a different feature flag).

---

## Section H — Negative / disabled path (proves nothing regresses when the flag is off)

Do this AFTER removing the DEBUG override, so you're simulating the real production state where PP-2572 hasn't shipped or a bank hasn't opted in.

### H1. Remove the DEBUG override

- ☐ Delete these lines from `AppDelegate.swift` (or `git checkout` the file):
  ```swift
  // TEMPORARY (PP-2570 manual QA — remove before merging): …
  GiniCaptureUserDefaultsStorage.ingredientBrandScreens = ["Analysis"]
  ```
- ☐ Also remove `import GiniCaptureSDK` if it's not otherwise needed.

### H2. Clean install → Analysis → no badge

- Setup: ☐ Clean install (**required** — otherwise the stale `["Analysis"]` value from earlier is still in UserDefaults and the badge will still show).
- Steps: ☐ Run A1 flow.
- Expected on Analysis: ☐ Loading UI is **byte-identical to pre-PP-2570** — spinner + text, no badge visible anywhere. ☐ CaptureSuggestions banner pins to safe-area bottom (not to the missing badge) — the fallback path in `suggestionsBannerBottomAnchor()`.
- Notes: __________

### H3. Backend-response negative — simulated key present but empty

Only doable end-to-end when PP-2572 is available. Skip for now, or mock via a local server that returns `ingredientBrandScreens: []`. If you can, verify: ☐ Analysis screen shows no badge.

---

## Section I — Test summary

Total scenarios: **A1–A7 (7)** + **B1–B3 (3)** + **C1–C3 (2 + boot)** + **D1–D3 (3)** + **E1–E3 (3)** + **F1–F2 (2)** + **G1–G4 (3 + cleanup)** + **H1–H3 (2 + cleanup)** = **~25 checkpoints**.

**Sign-off (fill in after completion):**

- Tester: __________
- Date: __________
- Xcode version: __________
- Simulator OS versions used: __________
- Physical devices used (if any): __________
- Pass / Fail counts: ____ pass / ____ fail
- Blockers found: __________
- Merge recommendation: ☐ Ready to merge · ☐ Blocked (see notes)
