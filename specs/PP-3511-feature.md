# PP-3511: [iOS] Ingredient Brand — Gini loading indicator on Analysis screen

Status: implemented
Ticket: https://ginis.atlassian.net/browse/PP-3511
Epic: PP-2568 (Ingredient Brand in Photo Payment SDK — phase 1)

## Resolved open questions (locked before /gini-build)

- **Q1 (view name):** `PoweredByGiniLoadingIndicatorView` — kept, parallels `PoweredByGiniBadgeView`.
- **Q2 (data-asset name):** `gini_loading_indicator` — snake_case, matches the folder the user staged.
- **Q3 (dark-mode variant, superseded by Q8):** Original plan shipped two GIFs (light + dark) in two separate datasets — see Q8 for the final HEIC-based solution.
- **Q8 (asset format, added post-QA):** Swapped from two ~900 KB GIFs (light + dark, ~1,791 KB combined) to a single ~278 KB animated HEIC (`HEICS`) at `1005×1005 px`, 79 frames, 16.7 fps. The Gini brand mark is theme-agnostic (blue on transparent), so a single asset reads correctly on both light and dark backgrounds — the per-appearance split was unnecessary. Payload shrinks **~85%** (1,791 KB → 278 KB). `PoweredByGiniLoadingIndicatorView.decodeFrames()` is now single-arg (no `UIUserInterfaceStyle`), and `frameDelay(source:index:)` checks `kCGImagePropertyHEICSDictionary` first (matching the shipped format), falling back to `kCGImagePropertyGIFDictionary` so the same code path can also decode a substitute GIF during development. `traitCollectionDidChange` override removed from the view — no reload on appearance flip because the asset is theme-agnostic. Asset: `GiniBrand.xcassets/gini_loading_indicator.dataset/giniLoadingIndicator.heic`.
- **Q4 (education icon size):** Both paths render the animated `UIImage` at its intrinsic size. Verified against Figma frames `36375:182135` (education) and `36375:182438` (standard PDF) — both use the identical `Animation Gini` container (`335×135pt`) with the g-mark at `~54×68pt`. Kate's GIF export dictates the pt size; no explicit size constraint in code. The spec's earlier `Constants.indicatorSize = 60×60` is superseded — see updated Design section.
- **Q5 (bugfix during QA, added post-implementation):** Kate's GIFs export at retina-scale pixel dimensions (~810px tall). `UIImage(cgImage:)` defaults to `scale = 1.0`, which caused the g mark to render at ~810pt — ~6× Figma's 135pt container — and push the loading text off-screen. Fixed in `decodeFrames(from:)` by computing a per-frame scale factor so `UIImage.size.height == Constants.targetPointHeight (135)` regardless of the exported resolution; width scales proportionally via `scaleAspectFit`. Both the standalone view and the education carousel benefit (they consume the same `ExtractedFrames`). Verified via video capture from the running app.
- **Q7 (blank-screen-after-education bugfix, added post-QA):** Pre-existing SDK bug exposed by R6: after the education flow's `~6s` timer expires, `showEducationLoadingMessage` calls `customLoadingView.removeFromSuperview()` but nothing replaces it — the Analysis screen goes blank (only nav bar + Powered-by badge) until extraction completes and the coordinator transitions. Under PP-3511 this means the Gini-branded g mark shown in the education carousel disappears entirely once the education finishes, making the ingredient-brand experience feel incomplete. Fixed by calling `showOriginalLoadingMessage()` immediately after `customLoadingView.removeFromSuperview()` — the standard loading UI (Gini indicator when flag is on, spinner otherwise) takes over, keeping visual continuity through the remainder of the extraction request. `waitUntilAnimationCompleted()`, `animationCompletionContinuations`, and `educationAnimationFinished` state remain correct (they were already drained by `finalizeEducationAnimation`); adding the standard indicator is purely additive to the view hierarchy.

- **Q6 (landscape + Figma-position bugfix, added post-QA):** The Gini indicator sat at `view.centerY` (50%), matching existing spinner behavior — but Figma's `top: calc(50% - 80.5px)` places the `Animation Gini` container at ~40% from top on the reference 812pt screen, and in landscape the g's bottom was cut off by the capture-suggestions tip banner. First attempt (assigning `centerYConstraint` so the existing spinner-path landscape offset `-48pt` applied) fixed landscape but stayed at 50% in portrait and would over-shift on smaller landscape screens. Final fix: **two size-class-specific constraint sets** applied via `traitCollectionDidChange`:
  - **Regular vertical (portrait iPhone, iPad)**: `centerY = view.centerY × 0.80` (Figma's 40%-from-top on every device), intrinsic height (~135pt matching Figma's `Animation Gini` container).
  - **Compact vertical (landscape iPhone)**: `centerY = view.centerY × 0.55` (~28% from top). No height cap — the g mark stays at its intrinsic Figma height (~135pt) in landscape too. Only the vertical center changes between orientations, not the mark's size (per product feedback that the animation should render at the same size regardless of orientation).
  - Constraints are stored per-set and swapped in `traitCollectionDidChange` when the vertical size class flips at runtime (rotation). The spinner path is untouched — its `centerYConstraint` + `viewDidLayoutSubviews` landscape adjustment continues to work as before.

- **Q9 (QRCodeOverlay expansion, added mid-implementation):** Product requested the ingredient-brand visuals on the camera's QR overlay too, mirroring the Analysis screen — the animated Gini indicator in place of the standard `UIActivityIndicatorView` while a QR is being processed, and the "Powered by Gini" badge on the dark-overlay state after a correct QR is detected. `QRCodeOverlay.swift` gains `poweredByGiniLoadingIndicatorView`, `installBrandedLoadingIndicatorIfNeeded()`, and `addPoweredByGiniBadgeIfNeeded()`. The `QRCodeEducationLoadingView` used by the QR overlay keeps its default `useIngredientBrandIndicator: false` — the animated g is only used by the standard (non-education) loading path on the overlay. **Precedence:** the branded indicator wins over both the standard `UIActivityIndicatorView` and the integrator's `GiniConfiguration.customLoadingIndicator` — same contract R1 already applies on the Analysis screen (wherever the flag is on, the Gini mark shows; an integrator's custom loading UI is not consulted on this path). Supersedes the original "QRCodeOverlay loading indicator — Analysis screen only" scoping in Q3.

- **Q11 (asset dark-mode split re-adopted, supersedes Q8):** Q8 shipped a single theme-agnostic HEIC (blue mark on transparent) on the assumption that one asset would read cleanly on both light and dark backgrounds. Design revisited this post-QA and asked for a dedicated dark variant so the mark's fill and glow read at the intended contrast on dark screens. Final asset layout: two universal `.dataset` folders — `gini_loading_indicator_light.dataset/giniLoadingIndicator-light.heic` and `gini_loading_indicator_dark.dataset/giniLoadingIndicator-dark.heic`. `PoweredByGiniLoadingIndicatorView.decodeFrames(for style: UIUserInterfaceStyle)` picks by dataset name; `traitCollectionDidChange` is restored so the appearance flip reloads the frames without recreating the view. Two datasets (rather than one dataset with `luminosity` appearance variants) work around Xcode's asset-catalog editor warning on animated payloads while `actool` compiles either layout cleanly.

- **Q10 (async config-fetch race, added post-QA):** On fresh install, `QRCodeOverlay` was observed to select the standard `UIActivityIndicatorView` and skip the "Powered by Gini" badge even for clients whose `/configurations` response returns `ingredientBrandScreens = ["Analysis"]`. Root cause: `QRCodeOverlay.init()` reads `GiniCaptureUserDefaultsStorage.ingredientBrandScreens` synchronously, but `GiniBankNetworkingScreenApiCoordinator.startSDK` fires the `/configurations` fetch asynchronously and returns the camera UI immediately — so the overlay latches whatever value UserDefaults held at construction (often `nil` on fresh install) for the rest of the camera session. Fix: defer both decisions to show-time — `installBrandedLoadingIndicatorIfNeeded()` runs from `showAnimation()` and swaps the standard indicator for the branded one in `loadingContainer` on the first show where the flag is on; `addPoweredByGiniBadgeIfNeeded()` runs from `configureQrCodeOverlay(withCorrectQrCode:)` and installs the badge on the first QR detection when the flag is on. `AnalysisViewController` is not touched — its `poweredByGiniLoadingIndicatorView` lazy var is accessed several seconds later (after camera interaction + document upload), by which time the config fetch has reliably landed; the race is not reproducible on Analysis in practice.

## Problem

When an integrator's `/configurations` payload lists `Analysis` in
`ingredientBrandScreens`, the SDK already shows the "Powered by Gini" badge on
the Analysis screen (PP-2570). Right above that badge, the analysis-in-progress
loading indicator is still the plain `UIActivityIndicatorView` (or the
integrator's own `CustomLoadingIndicatorAdapter` view) — the ingredient-brand
experience is incomplete: the badge is Gini-branded but the biggest moving
element on the screen isn't. PP-3511 finishes the pair by showing an animated
Gini loading indicator (GIF from the design handoff) in that spot while the
Analysis flag is on, and reverting to today's behavior when it's off.

## Requirements

R1 (MUST, entry): Given `GiniCaptureUserDefaultsStorage.ingredientBrandScreens` contains `"Analysis"` (case-insensitive, matched via `IngredientBrandScreen.isEnabled(.analysis, in:)`), when `AnalysisViewController` reaches the original loading-message path (`showOriginalLoadingMessage`), then the Gini loading indicator view is added and animated instead of `UIActivityIndicatorView`, regardless of whether `GiniConfiguration.customLoadingIndicator` is set.

R2 (MUST, happy): Given the Analysis screen is showing the Gini loading indicator (R1), when `AnalysisViewController.showAnimation()` / `hideAnimation()` are called, then the Gini indicator's animation starts / stops in lockstep with those calls, and no `UIActivityIndicatorView.startAnimating()`/`stopAnimating()` is invoked, and any `CustomLoadingIndicatorAdapter.startAnimation()`/`stopAnimation()` is NOT invoked.

R3 (MUST, entry): Given `ingredientBrandScreens` is `nil` OR `[]` OR contains no case-insensitive `"Analysis"` match, when `AnalysisViewController.showOriginalLoadingMessage` runs, then the existing branch is taken unchanged: `GiniConfiguration.customLoadingIndicator?.injectedView()` is used when non-nil; otherwise the default `UIActivityIndicatorView` is used. No behavior change from today for DeuBa / VR / any client without the flag.

R4 (MUST, happy): Given the Gini loading indicator view is instantiated, when it lays out and renders, then it plays the GIF frames from `GiniBrand.xcassets` in a smooth continuous loop (no visible pause at loop boundary, no flicker on start or on stop) using `UIImage.animatedImage(with: [UIImage], duration: TimeInterval)` reconstructed from per-frame `CGImage` + total loop duration extracted via `CGImageSource` (sum of per-frame `kCGImagePropertyGIFDelayTime`). Note: `UIImage.animatedImage(with:duration:)` distributes `duration` uniformly across frames — this works when Kate's asset has near-uniform per-frame delays; if the asset has variable delays and R4 smoothness fails visual QA, /gini-build swaps to a manual `CADisplayLink`-driven frame advance.

R5 (MUST, entry): Given the app is in Dark Mode, when the Gini loading indicator view renders, then it displays the dark-appearance variant of the GIF asset; given Light Mode, it displays the light variant. The variant switch happens on `traitCollectionDidChange` when appearance flips at runtime, without a full view recreation.

R6 (MUST, happy): Given `ingredientBrandScreens` contains `"Analysis"` and `AnalysisViewController` enters the education-loading path (`showEducationLoadingMessage` → `QRCodeEducationLoadingView`), when each `QRCodeEducationLoadingItem` in the carousel is shown, then the item's `.image` (today `qrCodeEducationIntroIcon` / `qrCodeEducationUploadIcon`) is replaced by the animated Gini GIF, while the item's `.text` (`"In case you didn't know…"`, `"Upload PDFs, images, or GIFs"`) and the carousel's per-item `.duration` are preserved unchanged. (Correction — the original Q2 answer "education keeps priority" was based on an ambiguous question; the Figma explicitly shows the Gini GIF in place of both education icons.)

R6.1 (MUST, happy — non-brand): Given `ingredientBrandScreens` is `nil`/empty/no-`"Analysis"`, when the education-loading path runs, then each item renders its own `.image` unchanged (no behavior change from today for DeuBa / VR / any client without the flag).

R7 (MUST, error): Given the GIF asset cannot be loaded from `GiniBrand.xcassets` for any reason (missing data, decode failure), when the Gini loading indicator view is instantiated with the flag set, then the view falls back to the default `UIActivityIndicatorView` behavior and logs the failure via `GiniUtilites` `Log` (no crash, no `fatalError`, no `assertionFailure`). The badge (PP-2570) and the "Powered by Gini" mark on the screen are unaffected.

R8 (MUST, happy — a11y): Given the Gini loading indicator view is on screen, when VoiceOver navigates to it, then it announces the same loading-status text the existing `UIActivityIndicatorView` uses — via the inherited `UIView.accessibilityValue`, set by `AnalysisViewController` from `loadingIndicatorText.text` at the same site line 287 already sets it on the default spinner today. The view exposes `.updatesFrequently` trait so VoiceOver doesn't re-read the label every frame. No new public accessibility property on the view.

R9 (SHOULD, happy): Given the Gini loading indicator is animating, when the Analysis screen is offscreen (`viewWillDisappear`), then the animation stops to release the CADisplayLink / animation-loop resources; when the screen returns to foreground (`viewWillAppear` and analysis still ongoing), it resumes.

## Affected modules

- **GiniUtilites** — new view type `PoweredByGiniLoadingIndicatorView` in `Sources/GiniUtilites/Brand/`, next to the existing `PoweredByGiniBadgeView`. New data asset in `Sources/GiniUtilites/Resources/GiniBrand.xcassets` (the GIF, with Light/Dark appearance variants). `public` visibility on the view type — matches `PoweredByGiniBadgeView`'s existing shape; per `platform.md` §1 GiniUtilites is an internal shared package, so `public` here is not customer-facing API.
- **GiniCaptureSDK** — call-site edits in three files:
  - `Sources/GiniCaptureSDK/Core/Screens/Analysis/AnalysisViewController.swift` — four methods gain a branch on `IngredientBrandScreen.isEnabled(.analysis, in:)`: `showOriginalLoadingMessage`, `showAnimation`, `hideAnimation`, `addLoadingView(intoContainer:)`; plus `showEducationLoadingMessage` (line 305) passes the ingredient-brand flag into `QRCodeEducationLoadingView.Style`.
  - `Sources/GiniCaptureSDK/Core/EducationFlow/Views/QRCodeEducation/QRCodeEducationLoadingView.swift` — `Style` struct gains a `useIngredientBrandIndicator: Bool` (default `false`); when `true`, the private `imageView` (line 40) renders the animated Gini GIF instead of `item.image`, for every carousel item (R6).
  - `Sources/GiniCaptureSDK/Core/Screens/Camera/Views/QRCodeOverlay/QRCodeOverlay.swift` (Q9) — holds a `poweredByGiniLoadingIndicatorView: PoweredByGiniLoadingIndicatorView?` and installs it lazily on the first `showAnimation()` via `installBrandedLoadingIndicatorIfNeeded()`, swapping the standard `UIActivityIndicatorView` in `loadingContainer`. The "Powered by Gini" badge is installed lazily on the first `configureQrCodeOverlay(withCorrectQrCode:)` via `addPoweredByGiniBadgeIfNeeded()`. Both readers re-evaluate `IngredientBrandScreen.isEnabled(.analysis, in:)` at show-time (Q10). `didMoveToWindow` starts/stops the indicator's animation with the window lifecycle.
- **Downstream ripple:** GiniBankSDK consumes GiniCaptureSDK — no code change needed on that side; behavior propagates. `bank-sdk.check.yml` covers both.

## Public API impact

**None to customer-facing surface.** No changes to `GiniCaptureSDK`, `GiniBankSDK`, or any of the `.library()` products integrators depend on.

**Inside GiniUtilites (internal-shared-package, not customer-facing per platform.md §1):**
- **Added:** `public final class PoweredByGiniLoadingIndicatorView: UIView`. Public `init()`, plus `public func startAnimation()`, `public func stopAnimation()`, and `public static func animatedImage() -> UIImage?` (the last used by GiniCaptureSDK's `QRCodeEducationLoadingView` to render the same animated mark in the education carousel's icon slot — see R6 in Design). Otherwise matches `PoweredByGiniBadgeView`'s shape.

No changes to `CustomLoadingIndicatorAdapter`, `GiniConfiguration.customLoadingIndicator`, `AnalysisViewController` public methods, or any other integrator-touchable declaration.

## Technical conventions

1. **Language & access control:** Swift, `internal` by default for the AnalysisViewController-side call-site edits. New `PoweredByGiniLoadingIndicatorView` in GiniUtilites is `public final class` — matches the sibling `PoweredByGiniBadgeView` shape (gini-orchestrator-enforced per `.claude/rules/mandatory-rules.md`). Doc-comment style per mandatory-rules.

2. **UI framework:** UIKit — extending an existing UIKit screen inside GiniCaptureSDK; the new view is a UIKit `UIView` subclass to match `PoweredByGiniBadgeView`. Colors: no colors introduced (the GIF itself carries the brand mark). Fonts: none. Spacing: local `private enum Constants` on the new view for any layout numbers. Liquid Glass: not applicable — this is an animated raster loop, no glass materials.

   **Auto Layout — `giniMakeConstraints` DSL is mandatory here.** Every `addSubview` in this feature (inside `PoweredByGiniLoadingIndicatorView.init()`, in the AnalysisViewController call-site edits, and in the `QRCodeEducationLoadingView` bind edit) MUST use `view.giniMakeConstraints { $0... }` from GiniUtilites (`GiniComponents/Utilities/GiniUtilites/Sources/GiniUtilites/Layout/UIView+Constraints.swift`) — no hand-rolled `NSLayoutConstraint.activate([...])` and no `.translatesAutoresizingMaskIntoConstraints = false` boilerplate (the DSL sets it automatically). This matches the CaptureSDK UIKit layout rule in `.claude/rules/mandatory-rules.md` and the pattern already applied in `PoweredByGiniBadgeView` and the badge-insertion call sites on `AnalysisViewController` / `QRCodeOverlay` (PP-2570 migration). Reference example from that migration: `badge.giniMakeConstraints { $0.centerX.equalToSuperview(); $0.bottom.equalTo(view.safeBottom).constant(-Constants.badgeBottomInset) }`.

3. **Architecture:** MVVM + Coordinator applies to feature-scale work; this ticket is a single view + call-site edits and doesn't warrant a new coordinator/viewmodel pair (matches how `PoweredByGiniBadgeView` is used today). The new view is a pure UIView with no view model — it owns its animated `UIImageView` child directly. AnalysisViewController continues to compose the view manually as it does with the spinner today.

4. **Wiring:** DI — constructor injection. The Gini indicator view is instantiated in AnalysisViewController with no dependencies. Async: no new async surface — the GIF frame decode happens synchronously in the view's `init` from the asset catalog `NSDataAsset` data; frame count and total loop duration are computed once and handed to `UIImage.animatedImage(with:duration:)`. Falls back to the closure-based `showAnimation`/`hideAnimation` API already in use.

5. **Localization:** No new user-visible strings — the GIF is a graphic. Existing `Strings.loadingBaseText` / `Strings.loadingPDFText` / `Strings.analysisLoadingTextWithPhotoLibrary` on the sibling label are unchanged. No `Resources/*.strings` files gain entries.

6. **Quality gates:** `make lint scheme=GiniCaptureSDK` and `make lint scheme=GiniBankSDK` must run clean per `AGENTS.md`. New tests in the GiniUtilites test target use Swift Testing (`@Suite`, `@Test`, `@MainActor`) — matches `PoweredByGiniBadgeViewTests.swift` in the same suite. New tests in `AnalysisViewControllerTests.swift` use **XCTest** — matches the file's existing framework and the PP-2570 cases added there. Multi-parameter formatting per mandatory-rules.

## Design

### View: `GiniUtilites/Brand/PoweredByGiniLoadingIndicatorView.swift`

Public UIView, backed by an `UIImageView` playing a GIF loaded from the shared brand asset catalog. Structure and file placement mirror the existing sibling `GiniComponents/Utilities/GiniUtilites/Sources/GiniUtilites/Brand/PoweredByGiniBadgeView.swift` line-for-line (imports, `public final class`, `imageView` child, autolayout in `init()`, `translatesAutoresizingMaskIntoConstraints = false`, `isAccessibilityElement`, `accessibilityLabel`, `accessibilityTraits`).

**Layout (per Figma sizing):** the child `UIImageView` is pinned to the view's edges via `giniMakeConstraints`; sizing is driven by the GIF's intrinsic content size (see Q4 resolution above — both placements render at the GIF's exported pt size, no explicit `Constants.indicatorSize`):

```swift
addSubview(imageView)
imageView.giniMakeConstraints { $0.edges.equalToSuperview() }
```

`contentMode = .scaleAspectFit` preserves the mark's aspect ratio. `giniMakeConstraints` sets `translatesAutoresizingMaskIntoConstraints = false` automatically — no explicit flip needed. Same DSL used at every `addSubview` in this feature (see Technical conventions §2). Since the containing view has no intrinsic content size of its own, override `intrinsicContentSize` to return `imageView.intrinsicContentSize` so callers (`AnalysisViewController`) can lay it out without knowing the GIF's dimensions.

**Frame extraction (executed once, in `init()`):**

```swift
guard let dataAsset = NSDataAsset(name: "gini_loading_indicator", bundle: .module),
      let source = CGImageSourceCreateWithData(dataAsset.data as CFData, nil) else {
    self.frames = []
    self.duration = 0
    return
}
let count = CGImageSourceGetCount(source)
var frames: [UIImage] = []
var duration: TimeInterval = 0
for i in 0..<count {
    guard let cg = CGImageSourceCreateImageAtIndex(source, i, nil) else { continue }
    frames.append(UIImage(cgImage: cg))
    duration += Self.frameDelay(source: source, index: i)  // reads kCGImagePropertyGIF{Unclamped,}DelayTime
}
```

Then `imageView.image = UIImage.animatedImage(with: frames, duration: duration)` — `UIImageView` auto-loops the returned animated image. `startAnimating()` / `stopAnimating()` on the child image view controls playback.

**Public API on the view — single consolidated list:**
- `public init()` — decodes frames from the asset once, sets up layout + a11y (matches `PoweredByGiniBadgeView.init()`).
- `public func startAnimation()` — calls `imageView.startAnimating()`.
- `public func stopAnimation()` — calls `imageView.stopAnimating()`.
- `public static func animatedImage() -> UIImage?` — returns the cached animated `UIImage` used by both the view itself and by `QRCodeEducationLoadingView` (R6). Backed by a `private static let cachedAnimatedImage: UIImage? = decode()` — decoding runs at most once per process, so calling from multiple sites doesn't re-parse the GIF.
- Read-only `hasValidAsset: Bool` — internal, not public. Read by `AnalysisViewController` via `@testable import` in tests and by direct access at the call site (same module — GiniUtilites → CaptureSDK). If cross-module access requires `public`, promote it then.

*(Naming keeps parallelism with `CustomLoadingIndicatorAdapter.startAnimation()` / `stopAnimation()` so AnalysisViewController's call sites read symmetrically. Accessibility label is passed via inherited `UIView.accessibilityValue` — no new public property; see R8.)*

**Dark mode (R5):** `GiniBrand.xcassets/gini_loading_indicator.dataset` uses the asset catalog's luminosity-appearance split with two paired GIFs (`gini_loading_indicator_light.gif`, `gini_loading_indicator_dark.gif`). `NSDataAsset(name:bundle:)` automatically picks the variant matching the current `traitCollection.userInterfaceStyle`. On appearance flip at runtime, `traitCollectionDidChange(_ previous:)` reloads the frames and swaps the animated image — no view recreation needed.

**A11y (R8):** `isAccessibilityElement = true`, `accessibilityTraits = [.updatesFrequently, .image]`, and the `accessibilityValue` inherited from `UIView` is set by `AnalysisViewController` from `loadingIndicatorText.text` at the same site line 287 already sets it on the default spinner. No new public accessibility property on the view.

**Failure fallback (R7):** if `NSDataAsset` or `CGImageSourceCreateWithData` returns nil, the view keeps a `hasValidAsset: Bool` flag = false; AnalysisViewController checks this before adding it, and if false, falls back to the default `UIActivityIndicatorView` path (as if the flag were off) plus a `Log.error("Gini ingredient-brand loading indicator asset failed to load")` via `GiniUtilites/Logger/`.

**Lifecycle (R9):** AnalysisViewController calls the view's `stopAnimation()` in `viewWillDisappear` and `startAnimation()` in `viewWillAppear` when the analysis is still ongoing (matches existing `hideAnimation`/`showAnimation` lifecycle — no new logic).

### AnalysisViewController call-site edits (standard path — R1, R2, R3)

Four methods gain a gate on `IngredientBrandScreen.isEnabled(.analysis, in: GiniCaptureUserDefaultsStorage.ingredientBrandScreens)`:

- **`showOriginalLoadingMessage`** (`AnalysisViewController.swift:284–302`) — when flag is on AND `poweredByGiniLoadingIndicatorView.hasValidAsset` is true, add the Gini view and skip both the default spinner and the customLoadingIndicator branch. Text below (`loadingIndicatorText`) still shown as today.
- **`showAnimation`** (`AnalysisViewController.swift:192–199`) — when gated on, call `poweredByGiniLoadingIndicatorView.startAnimation()` instead of spinner or customLoadingIndicator.
- **`hideAnimation`** (`AnalysisViewController.swift:201–208`) — symmetric.
- **`addLoadingView(intoContainer:)`** (`AnalysisViewController.swift:393–401`) — return the Gini view when gated on, otherwise the existing customLoadingIndicator?.injectedView() ?? loadingIndicatorView.

The gate is called once in `viewDidLoad` and cached in a stored property `private lazy var poweredByGiniLoadingIndicatorView: PoweredByGiniLoadingIndicatorView?` — created only when the flag is on, so unbranded flows pay no cost. AnalysisViewController holds a strong reference; the child `UIImageView`'s animation is stopped in `viewWillDisappear` (R9).

### QRCodeEducationLoadingView edit (education path — R6, R6.1)

`Sources/GiniCaptureSDK/Core/EducationFlow/Views/QRCodeEducation/QRCodeEducationLoadingView.swift` today renders each `QRCodeEducationLoadingItem` by setting `imageView.image = item.image` (line 40 declares the `imageView`; the bind happens in the view model subscription). The edit:

1. Extend the existing `Style` struct with `useIngredientBrandIndicator: Bool = false`. Kept `false`-default so all existing call sites (`QRCodeOverlay`, and the non-brand branch inside AnalysisViewController) are behavior-identical.
2. In the item-binding closure, when `style.useIngredientBrandIndicator == true`, set the `imageView.image` to the animated Gini `UIImage` produced by `PoweredByGiniLoadingIndicatorView.animatedImage()` (a new public static helper on the view that returns the same `UIImage.animatedImage(with:duration:)` the view itself uses). When `false`, keep the existing `item.image` path.
3. Update `AnalysisViewController.showEducationLoadingMessage` (`AnalysisViewController.swift:305`) to construct `QRCodeEducationLoadingView.Style(..., useIngredientBrandIndicator: IngredientBrandScreen.isEnabled(.analysis, in: GiniCaptureUserDefaultsStorage.ingredientBrandScreens))`.

The `.text` and per-item `.duration` fields of `QRCodeEducationLoadingItem` are untouched — the education carousel still cycles through `intro` ("In case you didn't know…") → `uploadTip` ("Upload PDFs, images, or GIFs") with their existing timings; only the icon slot changes to the animated Gini mark.

**Public API on the view — already listed above** under "Public API on the view — single consolidated list." The `public static func animatedImage() -> UIImage?` returns the process-cached animated `UIImage`, so `QRCodeEducationLoadingView` renders it directly into its `imageView` without instantiating a full `PoweredByGiniLoadingIndicatorView` subtree.

**`Style` visibility stays internal.** The existing `QRCodeEducationLoadingView.Style` struct has no `public` modifier today. Adding `useIngredientBrandIndicator: Bool = false` keeps the struct internal — no accidental public-surface widening.

**QRCodeOverlay is unaffected** — it also constructs `QRCodeEducationLoadingView.Style(...)` but always with the default `useIngredientBrandIndicator: false` (Q3 answered "Analysis screen only" — QR overlay stays out of scope).

## Test plan

Every MUST requirement maps to at least one named test.

### `GiniComponents/Utilities/GiniUtilites/Tests/GiniUtilitesTests/PoweredByGiniLoadingIndicatorViewTests.swift` (new file, Swift Testing)

**Extend existing suite?** No — new file matching `PoweredByGiniBadgeViewTests.swift`'s shape. `@Suite("PoweredByGiniLoadingIndicatorView — animated Gini ingredient-brand indicator")`, `@MainActor`, `struct`.

Rough test count: **6**.

- `initExtractsFramesFromDataAsset` (R4) — instantiates the view, `#expect(view.hasValidAsset)`, `#expect(view.frameCount > 0)`, `#expect(view.loopDuration > 0)`.
- `initWithMissingAssetLeavesHasValidAssetFalse` (R7) — patches the bundle lookup or uses a manual test-double `NSDataAsset` stub; asserts `!view.hasValidAsset`, `#expect(view.frameCount == 0)`.
- `startAnimationStartsUnderlyingImageView` (R2) — asserts `imageView.isAnimating` becomes true after `startAnimation()`.
- `stopAnimationStopsUnderlyingImageView` (R2) — asserts `imageView.isAnimating` becomes false after `stopAnimation()`.
- `darkAppearancePicksDarkVariant` (R5) — creates the view under `.dark`, asserts the first frame's `cgImage` (or a bytewise signature) matches the dark variant; flips to `.light`, asserts frame swap after `traitCollectionDidChange`.
- `accessibilityIsSingleImageElementWithUpdatesFrequentlyTrait` (R8) — asserts `isAccessibilityElement`, `accessibilityLabel`, `accessibilityTraits.contains(.updatesFrequently)`.

### `CaptureSDK/GiniCaptureSDK/Tests/GiniCaptureSDKTests/AnalysisViewControllerTests.swift` (extend existing XCTest suite)

**Extend existing class?** Yes — same class the PP-2570 badge tests live in. New methods use the `test` prefix (XCTest discovery requirement).

Rough test count: **7** additions.

- `testAnalysisShowsPoweredByGiniLoadingIndicatorWhenScreensListContainsAnalysis` (R1) — sets `ingredientBrandScreens = ["Analysis"]`, instantiates AnalysisViewController, forces `viewDidLoad`, asserts `findLoadingIndicator(in: view.subviews) is PoweredByGiniLoadingIndicatorView`.
- `testAnalysisShowsPoweredByGiniLoadingIndicatorWhenScreenNameIsLowercase` (R1) — same with `["analysis"]`.
- `testAnalysisHidesPoweredByGiniLoadingIndicatorWhenIngredientBrandScreensIsEmpty` (R3) — asserts no `PoweredByGiniLoadingIndicatorView` in view tree; asserts `UIActivityIndicatorView` or `customLoadingIndicator.injectedView()` present instead.
- `testAnalysisPoweredByGiniLoadingIndicatorOverridesCustomLoadingIndicator` (R1) — sets both the flag AND a mock `CustomLoadingIndicatorAdapter`; asserts the Gini indicator wins and the mock's `startAnimation()` is NOT called.
- `testAnalysisFallsBackToDefaultSpinnerWhenGiniIndicatorAssetIsUnavailable` (R7) — sets flag on but forces `PoweredByGiniLoadingIndicatorView.hasValidAsset == false` (via a test hook that swaps the asset lookup to return nil, or by patching the bundle); asserts `UIActivityIndicatorView` is added instead of `PoweredByGiniLoadingIndicatorView` and no crash / no `assertionFailure`.
- `testAnalysisEducationLoadingReplacesItemIconWithGiniIndicatorWhenFlagOn` (R6) — sets flag on, forces `showEducationLoadingMessage` to run; asserts the `QRCodeEducationLoadingView` that gets added has `style.useIngredientBrandIndicator == true`, and its rendered `imageView.image?.images?.count ?? 0 > 0` (i.e. is an animated image, not `Images.intro` / `Images.uploadFile`'s static single-frame `UIImage`), and `imageView.image !== item.image` (identity check proves the swap happened).
- `testAnalysisEducationLoadingKeepsItemIconWhenFlagOff` (R6.1) — sets flag off, forces education path; asserts the `QRCodeEducationLoadingView` has `style.useIngredientBrandIndicator == false` and its `imageView.image === item.image` (identity holds; the item's own icon is used unchanged).

### `CaptureSDK/GiniCaptureSDK/Tests/GiniCaptureSDKTests/QRCodeEducationLoadingViewTests.swift` (new file, Swift Testing — matches PP-2570-era new-suite convention)

**Extend existing suite?** No — no existing test file for this view. New file matching `PoweredByGiniBadgeViewTests.swift`'s shape (`@Suite`, `@Test`, `@MainActor`).

Rough test count: **3**.

- `imageViewShowsItemImageWhenIngredientBrandFalse` (R6.1) — instantiate view with `Style(useIngredientBrandIndicator: false)`, bind a fixture `QRCodeEducationLoadingItem`, assert `imageView.image === item.image` (identity — the item's own icon is used unchanged).
- `imageViewShowsGiniAnimatedImageWhenIngredientBrandTrue` (R6) — instantiate view with `Style(useIngredientBrandIndicator: true)`, bind the same fixture item, assert `imageView.image?.images?.count ?? 0 > 0` (animated image, not the item's single-frame static icon) AND `imageView.image !== item.image` (identity fails — proves the swap happened). Does NOT assert `=== PoweredByGiniLoadingIndicatorView.animatedImage()` because the cached-image accessor may return a distinct-instance-but-same-frames `UIImage` depending on how UIKit rehydrates it — count + non-identity vs `item.image` is the reliable assertion.
- `textLabelAndAnalysingSuffixAreUnaffectedByIngredientBrandFlag` (R6) — both flag states show the same `.text` and `.animatedSuffixLabelView` — the ingredient-brand flag only affects the icon slot.

### Not tested

- The actual GIF playback timing — Cocoa's `UIImage.animatedImage(with:duration:)` and `UIImageView`'s built-in loop are Apple framework behavior; we test that we hand them the right frames, not that they render at 60fps.
- Visual comparison of light vs dark variants at the pixel level — the asset catalog appearance switch is Apple framework behavior; we only test the view reacts to `traitCollectionDidChange`.
- The GIF asset's compressed size or its exact frame count — that's a design/asset-quality concern, not a code invariant.
- Behavior on QRCodeOverlay — explicitly out of scope (Q3 answered "Analysis screen only").
- Interaction with `bank-sdk.check.yml` on downstream GiniBankSDK — the change is a call-site edit in CaptureSDK plus a new asset in GiniUtilites; downstream is behavior-transparent. CI's BankSDK build covers compile-time verification.

Manual QA (single-shot, in the release cut for 4.6.0):
- Fire the Analysis screen with `ingredientBrandScreens = ["Analysis"]` on the example app — confirm the Gini indicator plays smoothly, loops without visible seam, and the "Powered by Gini" badge from PP-2570 still shows at the bottom.
- Flip Dark ↔ Light in the simulator (Cmd-Shift-A) while the screen is up — confirm the indicator swaps variant without recreating the view.

## Out of scope

- **QRCodeOverlay loading indicator** — originally out of scope per Q3; brought in mid-implementation per Q9 (product request for parity with the Analysis screen). Now covered in this ticket.
- **A new public opt-out** (`giniConfiguration.disableGiniIngredientBrandIndicator`) — Q4 answered "purely internal, no new public symbols". The flag itself is the on/off switch (integrators control it via the backend `/configurations` `ingredientBrandScreens` array).
- **Retrofitting existing UIKit screens to SwiftUI** — the AnalysisViewController remains UIKit as it is today; adding a SwiftUI-native indicator would be a bigger refactor. Kept UIKit for surgical scope.
- **Onboarding / Camera / Review screens' loading indicators** — none of them are in the ingredient-brand scope for phase 1 (per epic PP-2568).
- **Rewriting the `CustomLoadingIndicatorAdapter` protocol or `GiniConfiguration.customLoadingIndicator` public API** — AC7 is satisfied by overriding at the call site, not by changing the public surface.

## Open questions

All resolved — see "Resolved open questions" block above.

## Implementation plan

- [x] 1. **GiniUtilites — GIF assets landed in two `.dataset` folders** (done). Split into `gini_loading_indicator_light.dataset` (with `giniLoadingIndicator-light.gif`) and `gini_loading_indicator_dark.dataset` (with `giniLoadingIndicator-dark.gif`), both universal. Reason: Xcode's `.dataset` editor UI mishandles `luminosity` appearance variants for GIF payloads and shows a spurious "unassigned child" warning even when `actool` compiles clean. Two separate datasets sidestep the editor bug. Swift side selects asset name by `traitCollection.userInterfaceStyle`. Both datasets compile via `actool` with no warnings.
- [x] 2. **GiniUtilites — `PoweredByGiniLoadingIndicatorView` view** (`Brand/PoweredByGiniLoadingIndicatorView.swift`): `public final class` mirroring `PoweredByGiniBadgeView`. `init()` decodes frames via `NSDataAsset` + `CGImageSource`; per-frame delay summed via `kCGImagePropertyGIFUnclampedDelayTime` (falls back to `kCGImagePropertyGIFDelayTime`); `UIImage.animatedImage(with:duration:)` cached via `private static let cachedAnimatedImage: UIImage?` so both the view and `PoweredByGiniLoadingIndicatorView.animatedImage()` share one decode. Adds `imageView` child via `giniMakeConstraints { $0.edges.equalToSuperview() }` — no size constraint (Q4). A11y: `isAccessibilityElement = true`, `accessibilityTraits = [.image, .updatesFrequently]`. `traitCollectionDidChange` re-decodes on light/dark flip. `startAnimation()`/`stopAnimation()` forward to `imageView`. `hasValidAsset: Bool` (`internal`) for AnalysisViewController fallback gate. On decode failure, `Log.error(...)` via `GiniUtilites/Logger/`. (R4, R5, R7, R8)
- [x] 3. **GiniUtilites — tests** (`PoweredByGiniLoadingIndicatorViewTests.swift`, Swift Testing, `@Suite`, `@MainActor`): 6 cases per test plan. R4 (`hasValidAsset && frameCount > 0 && loopDuration > 0`), R7 (missing asset → `!hasValidAsset`), R2 (start/stop toggle `imageView.isAnimating`), R5 (dark-appearance selects dark variant, flip works via `traitCollectionDidChange`), R8 (a11y traits). (Requirements R2, R4, R5, R7, R8)
- [x] 4. **GiniCaptureSDK — `AnalysisViewController` standard-path wiring** (`Core/Screens/Analysis/AnalysisViewController.swift`): `private lazy var poweredByGiniLoadingIndicatorView: PoweredByGiniLoadingIndicatorView?` created only when `IngredientBrandScreen.isEnabled(.analysis, ...)` AND the view's `hasValidAsset`. Branch `showOriginalLoadingMessage`, `showAnimation`, `hideAnimation`, `addLoadingView(intoContainer:)` on that gate. `viewWillDisappear`/`viewWillAppear` pause/resume (R9). `accessibilityValue` set from `loadingIndicatorText.text` at the same site (R8). (R1, R2, R3, R7, R9)
- [x] 5. **GiniCaptureSDK — `AnalysisViewController` XCTest additions** (5 of the planned 7 — the two AVC-level education-flow tests are covered directly in `QRCodeEducationLoadingViewTests` where the view lifecycle is controllable without stubbing `EducationFlowController` state) (`AnalysisViewControllerTests.swift`, extend existing class): 7 `test*` methods per plan — screens-list case sensitivity, empty/nil no-op, customLoadingIndicator override, asset-missing fallback, both education flag-on/flag-off cases. (R1, R3, R7, R6, R6.1)
- [x] 6. **GiniCaptureSDK — `QRCodeEducationLoadingView` Style extension** (`Core/EducationFlow/Views/QRCodeEducation/QRCodeEducationLoadingView.swift`): add `useIngredientBrandIndicator: Bool = false` to `Style` init. In `configure(with model:)` (line 178), when `style.useIngredientBrandIndicator == true` set `imageView.image = PoweredByGiniLoadingIndicatorView.animatedImage() ?? model.image` (fallback keeps carousel usable if asset decode failed). Otherwise unchanged. `AnalysisViewController.showEducationLoadingMessage` (line 304) passes the flag from `IngredientBrandScreen.isEnabled(.analysis, ...)`. QRCodeOverlay unchanged (default `false`). (R6, R6.1)
- [x] 7. **GiniCaptureSDK — `QRCodeEducationLoadingViewTests`** (new file, Swift Testing): 3 cases per plan — flag-off keeps item.image, flag-on swaps to animated image, text/suffix unaffected by flag. (R6, R6.1)
- [x] 8. **Verification**: `make lint` is broken locally due to a Ruby/bundler mismatch on the developer machine (unrelated to this ticket) — CI's `shared-config.yml` runs the same command and will gate on merge. Locally verified via `xcodebuild build`: `GiniCaptureSDK` and `GiniBankSDK` both compile clean. `xcodebuild test`: `AnalysisViewControllerTests` all 18 pass (5 new + 13 pre-existing), `QRCodeEducationLoadingViewTests` all 3 pass, `PoweredByGiniLoadingIndicatorViewTests` all 6 pass. Total new tests: 14/14 green.
- [x] 9. **GiniCaptureSDK — `QRCodeOverlay` ingredient-brand wiring** (see Q9) (`Core/Screens/Camera/Views/QRCodeOverlay/QRCodeOverlay.swift`): holds a `poweredByGiniLoadingIndicatorView: PoweredByGiniLoadingIndicatorView?` and swaps whichever indicator is currently in `loadingContainer` — the standard `UIActivityIndicatorView` or the integrator's `customLoadingIndicator.injectedView()` — for the branded indicator when `IngredientBrandScreen.isEnabled(.analysis, in:)`. `showAnimation` / `hideAnimation` prefer the branded indicator over the custom one, so an integrator's start/stop is not called on this path once brand is installed. Adds the "Powered by Gini" badge on the first correct-QR-detection when the flag is on. `QRCodeOverlayTests` covers both paths. `didMoveToWindow` starts/stops the branded indicator's animation with the window.
- [x] 10. **GiniCaptureSDK — fix async config-fetch race in `QRCodeOverlay`** (see Q10): defer `installBrandedLoadingIndicatorIfNeeded()` from `init` to first `showAnimation`, and defer `addPoweredByGiniBadgeIfNeeded()` to first `configureQrCodeOverlay(withCorrectQrCode:)`. Both re-read `GiniCaptureUserDefaultsStorage.ingredientBrandScreens` at show-time so a value that lands from `/configurations` after the overlay was constructed is picked up on the next show. Confirmed via console logs on fresh install: overlay now correctly picks the branded indicator once the fetch resolves.
