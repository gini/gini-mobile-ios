# PP-2570: Ingredient Brand — "Powered by Gini" component on Analysis screen (iOS)

Status: implemented
Ticket: https://ginis.atlassian.net/browse/PP-2570
Related: PP-2572 (backend feature flag, blocks this), PP-2569 (design spec, in progress), PP-2571 (Android sibling)

## Problem

Product wants the "Powered by Gini" wordmark visible during the payment/capture flow for banks that opt in — starting with the Analysis (document processing) screen. Rollout is per-client via a backend feature flag with no SDK release required: the SDK reads `ingredientBrandScreens: [String]` from `/configurations` and shows the badge on every screen whose name is in that list. Today only `"Analysis"` is supported, but the field is designed to expand to other screens later.

The feature must not visually regress any existing Analysis-screen state (original loading, education flow, capture-suggestions banner) and must not touch the existing `qrCodeEducationEnabled` education flows.

## Requirements

**R1 (MUST, entry):** Given a Gini integrator initializes the SDK via `GiniBank.startSDK(…)`/`GiniBankNetworkingScreenApiCoordinator` with a `ClientConfigurationService`, when the `/configurations` response contains `ingredientBrandScreens: ["Analysis"]` (case-insensitive), then the persisted client-configuration snapshot (`GiniBankUserDefaultsStorage.clientConfiguration`) exposes the value and the propagated flag `GiniCaptureUserDefaultsStorage.ingredientBrandScreens` contains `"Analysis"`.

**R2 (MUST, happy):** Given `GiniCaptureUserDefaultsStorage.ingredientBrandScreens` contains `"Analysis"` (case-insensitive match), when `AnalysisViewController.viewDidLoad()` runs, then a `PoweredByGiniBadgeView` (from `GiniUtilites`) is added as a subview of `view` and constrained centered horizontally with its bottom pinned `Constants.badgeBottomInset` above `view.safeAreaLayoutGuide.bottomAnchor`.

**R3 (MUST, happy):** Given `ingredientBrandScreens` is empty (`[]`) or does not contain `"Analysis"` (case-insensitive), when `AnalysisViewController.viewDidLoad()` runs, then no `PoweredByGiniBadgeView` is added to the view hierarchy — the Analysis screen is byte-identical to today's rendering in both `showOriginalFlow` and `showEducationFlow` states.

**R4 (MUST, happy):** Given the badge is visible and the current interface style toggles between light and dark, when the trait collection changes, then the badge PDF renders identically (single theme-agnostic asset: white pill background + pink `gini` wordmark) with no re-layout or content redraw beyond the standard system trait update.

**R5 (MUST, happy):** Given the badge is visible and VoiceOver is on, when the user swipes to the badge, then VoiceOver announces exactly `"Powered by Gini"` (hardcoded, non-localized brand string) and the inner `UIImageView` is excluded from VoiceOver focus (`isAccessibilityElement = false` on the image, `true` on the container).

**R6 (MUST, happy):** Given the badge is visible and Dynamic Type text size changes to any accessibility size, when the trait change is applied, then the badge PDF asset dimensions stay fixed at design size (badge is a brand mark, not text — does not scale with Dynamic Type) and does not overlap the loading spinner, the loading text, or the `CaptureSuggestionsView` banner.

**R7 (MUST, happy):** Given the Analysis screen is in `showEducationFlow` state (captureInvoice education, `QRCodeEducationLoadingView` centered) AND `ingredientBrandScreens` contains `"Analysis"`, when the education animation runs, then the badge remains visible at the bottom, does not overlap the education view, and the education flow's display count is incremented normally (no interference with `EducationFlowController.markMessageAsShown()`).

**R8 (MUST, happy — per Figma "6.1.1" vs "6.3.x" review):** Given the Analysis screen displays an image document AND the badge is enabled, when the screen appears, then the badge is initially visible during the `CaptureSuggestionsView.start(after: 4)` delay (matching Figma frame `35002:12000` "6.1.1 iOS-ph-analyzePhoto" — badge alone). When the banner first slides in, the badge hides (matching Figma frames `35002:12016`/`35002:12045` "6.3.x iOS-ph-analyzeTipps" — banner alone) **and stays hidden for the rest of the Analysis session** — subsequent banner cycles do not re-reveal the badge. This one-way transition avoids the badge flickering back into view between banner cycles right before the next one starts sliding up. Implemented via a new `onBannerVisibilityChange: ((Bool) -> Void)?` callback on `CaptureSuggestionsView` invoked inside each animation block; the Analysis screen's callback only responds to the `isVisible == true` case. The banner pins to `view.safeAreaLayoutGuide.bottomAnchor` (pre-PP-2570 position). On `removeCaptureSuggestions()` (called from `viewWillDisappear`) the badge is restored to visible so the view controller is in a clean state if re-presented.

**R9 (MUST, entry):** Given `ClientConfiguration` is decoded from the `/configurations` JSON response, when the response contains `"ingredientBrandScreens": ["Analysis"]`, then `ClientConfiguration.ingredientBrandScreens` equals `["Analysis"]`; when the response contains `"ingredientBrandScreens": []`, then the property equals `[]`. The property is `public let ingredientBrandScreens: [String]` (non-optional — backend contract PP-2572 mandates presence).

**R10 (MUST, error):** Given the `/configurations` response entirely omits `ingredientBrandScreens` (older backend before PP-2572 ships, or misconfiguration), when decoding `ClientConfiguration`, then decoding fails with `DecodingError.keyNotFound` and the badge is not shown for the session (falls back to no visual change, same behavior as an empty array). This matches how the struct treats every other required field today — no silent defaults.

**R11 (SHOULD, happy):** Given the badge is added to any container view (Analysis screen or a future consumer), when the container measures the badge via `intrinsicContentSize`, then the badge returns a size of `Constants.badgeSize` (90 × 23 pt, matching the Figma component) so parent stacks/constraints size it deterministically without hard-coded literals at every call site.

**R12 (MUST, happy — scope extension per Figma):** Given `GiniCaptureUserDefaultsStorage.ingredientBrandScreens` case-insensitively contains `"Analysis"` AND a valid SEPA QR code has been detected on the Camera screen (`QRCodeOverlay.configureQrCodeOverlay(withCorrectQrCode: true)` has run), when the overlay is visible with its dark 0.8-alpha background, then a `PoweredByGiniBadgeView` is shown inside the overlay, centered horizontally with its bottom pinned `Constants.badgeBottomInset` above the overlay's `safeAreaLayoutGuide.bottomAnchor`. On the invalid-QR state (`configureQrCodeOverlay(withCorrectQrCode: false)` — clear background) the badge is hidden. This matches the Figma flow "5.2 QR code flow" (frames `35002:12174` et al.) where the badge is documented across the whole analyze user journey including the camera+QR detection moment; per PP-2570 review with the PO, the string `"Analysis"` gates the whole analyze flow, not just `AnalysisViewController`.

## Affected modules

Named by SPM product (per `platform.md`):

- **GiniBankAPILibrary** — add `ingredientBrandScreens` field to `ClientConfiguration`. iOS 15+.
- **GiniUtilites** — new `PoweredByGiniBadgeView` UIKit component + a new resource bundle (`GiniBrand.xcassets`) hosting the badge PDF. iOS 15+.
- **GiniCaptureSDK** — propagate the flag from the client-config snapshot into `GiniCaptureUserDefaultsStorage`; render the badge in `AnalysisViewController` **and** in `QRCodeOverlay` when a valid QR code is detected (per R12). iOS 15+.
- **GiniBankSDK** — extend `GiniBankNetworkingScreenApiCoordinator` to write the propagated flag after `/configurations` succeeds (parallel to the existing `qrCodeEducationEnabled` propagation). iOS 15+.

Dependency chain: `GiniBankAPILibrary` (data model change) → `GiniBankSDK` (propagation); `GiniUtilites` (badge component + asset) → `GiniCaptureSDK` (Analysis screen integration). `GiniBankSDK` already depends on both `GiniCaptureSDK` and `GiniBankAPILibrary`.

## Public API impact

**GiniBankAPILibrary — additive (source-breaking for hand-constructed instances if no default is chosen):**
- `ClientConfiguration`: adds `public let ingredientBrandScreens: [String]`.
- `ClientConfiguration.init(...)`: adds one parameter `ingredientBrandScreens: [String] = []` (default `[]` preserves source-compat for integrators who construct the struct by hand for tests/mocks). Follows the one-parameter-per-line rule (`CLAUDE.md` › Code Style).

**GiniUtilites — additive:**
- New `public final class PoweredByGiniBadgeView: UIView` with a single `public init()` (no parameters — the badge is self-contained). Exposes an `override public var intrinsicContentSize: CGSize` returning `90 × 23`.
- New resource: `GiniBrand.xcassets/poweredByGiniBadge.imageset/poweredByGiniBadge.pdf` (single-scale template-off, preserves color). Filename matches the imageset name (lowerCamelCase, no spaces) so `UIImage(named: "poweredByGiniBadge", …)` and asset-catalog lookup align cleanly.
- Both `Package.swift` (local dev) AND `Package-release.swift` (mirrored to the `gini/utilites-ios` release repo on tag) target `GiniUtilites` gain `resources: [.process("Resources")]`. Missing the release manifest ships the asset only in local builds — silent runtime failure.

**GiniCaptureSDK — additive:**
- `GiniCaptureUserDefaultsStorage`: adds `public static var ingredientBrandScreens: [String]?` (nil default) with UserDefaults key `"ginicapture.defaults.clientConfigurations.ingredientBrandScreens"`. Mirrors the existing `qrCodeEducationEnabled` precedent (`GiniCaptureUserDefaultsStorage.swift:21`).
- `AnalysisViewController` internally adds a private `PoweredByGiniBadgeView` subview when `ingredientBrandScreens` contains `"Analysis"`. No new public declarations.

**GiniBankSDK — none.** `GiniBankNetworkingScreenApiCoordinator.startSDK(...)` internal propagation (line 305–306) gains one more line to mirror the flag into `GiniCaptureUserDefaultsStorage.ingredientBrandScreens`. Existing public entry points unchanged.

## Technical conventions

1. **Language & access control:** Swift, `internal` by default. Only the additions listed in "Public API impact" are `public`, and each is justified there. Doc-comment style per `.claude/rules/mandatory-rules.md` (gini-orchestrator-enforced).

2. **UI:** UIKit only — `PoweredByGiniBadgeView` is a `UIView` subclass and the Analysis screen it integrates into is a UIKit `UIViewController`. Match the neighboring UIKit code in `GiniCaptureSDK/Sources/GiniCaptureSDK/Core/Screens/Analysis/`. Programmatic Auto Layout (matches `AnalysisViewController.addLoadingContainer()`); no new colors needed (badge PDF has its own baked-in white pill + pink brand); no fonts (badge is fully rasterized in the PDF); layout constants live in a private `enum Constants` on `PoweredByGiniBadgeView` (badge size, insets) and a new `Constants.badgeBottomInset` + `Constants.badgeSuggestionsGap` on `AnalysisViewController`. No Liquid Glass adoption — badge is a legacy image asset.

3. **Architecture:** No new coordinator, view model, or delegate — the badge is a passive stateless subview with no data flow. MVVM + Coordinator per `.claude/rules/mandatory-rules.md` (gini-orchestrator-enforced) is trivially satisfied because there is no new user-facing feature entry point, only a decoration added to an existing screen owned by `GiniScreenAPICoordinator`.

4. **Wiring:** Constructor injection — `PoweredByGiniBadgeView()` takes no dependencies; the Analysis screen reads the flag statically from `GiniCaptureUserDefaultsStorage.ingredientBrandScreens` (matches the `qrCodeEducationEnabled` precedent used two lines above the change site, `AnalysisViewController.swift:57`). No async work: badge is inserted synchronously in `viewDidLoad`; the flag was persisted during `/configurations` fetch on session start.

5. **Localization:** No new localizable strings. The badge text ("Powered by") is baked into the PDF asset. VoiceOver announces the hardcoded English brand phrase `"Powered by Gini"` (accessibility label set inline on the container view — brand names conventionally don't translate, matches the `poweredByGiniText` treatment in `GiniInternalPaymentSDK/PoweredByGiniStrings.swift`). No `.strings` files gain entries in this ticket.

6. **Quality gates:** `make lint scheme=GiniBankSDK` and `make lint scheme=GiniCaptureSDK` must be clean (see AGENTS.md). CI parity destination is `iPhone 17 / iOS 26.2`. Test-framework coverage expectation: `AnalysisViewControllerTests` extends existing XCTest suite (module dominant framework is XCTest for GiniCaptureSDK screen tests — matches neighboring `AnalysisViewControllerTests.swift:9`). New `PoweredByGiniBadgeViewTests` in GiniUtilites uses **Swift Testing** — GiniUtilites has no test framework precedent, and Swift Testing is the platform-mandated default for new suites. New `ClientConfigurationTests` additions extend existing XCTest suite (BankAPILibrary is XCTest-dominant). Multi-parameter formatting rule per `.claude/rules/mandatory-rules.md` applies to the new `ClientConfiguration.init(...)` signature.

## Design

**Data flow:**

1. Session start → `GiniBankNetworkingScreenApiCoordinator.startSDK(...)` calls `ClientConfigurationService.fetchConfigurations` (BankAPILibrary).
2. On success, the coordinator writes the decoded `ClientConfiguration` to `GiniBankUserDefaultsStorage.clientConfiguration` and mirrors the `qrCodeEducationEnabled` bool into `GiniCaptureUserDefaultsStorage.qrCodeEducationEnabled` — see `GiniBankNetworkingScreenApiCoordinator.swift:305-306`. **Add one line here:** `GiniCaptureUserDefaultsStorage.ingredientBrandScreens = configuration.ingredientBrandScreens`.
3. When `AnalysisViewController.viewDidLoad()` runs, after `setupView()` completes, check `GiniCaptureUserDefaultsStorage.ingredientBrandScreens?.contains { $0.caseInsensitiveCompare("Analysis") == .orderedSame } == true`. If true, instantiate `PoweredByGiniBadgeView()` and insert it above `overlayView`.

**Key files & sites:**

- `BankAPILibrary/GiniBankAPILibrary/Sources/GiniBankAPILibrary/Documents/Configuration/ClientConfiguration.swift` — add stored property + initializer parameter (both at end of parameter list, keeping alphabetical/logical grouping aside — matches how `unsupportedQRCodeWarningEnabled` was last-appended).
- `CaptureSDK/GiniCaptureSDK/Sources/GiniCaptureSDK/Core/Storage/GiniCaptureUserDefaultsStorage.swift` — add `@GiniUserDefault("ginicapture.defaults.clientConfigurations.ingredientBrandScreens", defaultValue: nil) public static var ingredientBrandScreens: [String]?` after the `unsupportedQRCodeWarningEnabled` block (line 38).
- `BankSDK/GiniBankSDK/Sources/GiniBankSDK/Core/GiniBankNetworkingScreenApiCoordinator.swift:305-306` — append the mirror line.
- `GiniComponents/Utilities/GiniUtilites/Sources/GiniUtilites/Brand/PoweredByGiniBadgeView.swift` — new file, `public final class PoweredByGiniBadgeView: UIView` wrapping a private `UIImageView(image: UIImage(named: "poweredByGiniBadge", in: .module, with: nil))`. Local `enum Constants { static let badgeSize = CGSize(width: 90, height: 23) }`. Constructor sets `translatesAutoresizingMaskIntoConstraints = false`, adds the image view pinned to all four edges, sets `isAccessibilityElement = true`, `accessibilityLabel = "Powered by Gini"`, `accessibilityTraits = .image`, and marks the inner `UIImageView` as `isAccessibilityElement = false`.
- `GiniComponents/Utilities/GiniUtilites/Sources/GiniUtilites/Resources/GiniBrand.xcassets/poweredByGiniBadge.imageset/` — **already scaffolded** in the branch. Contains `Contents.json` (single universal PDF, `preserves-vector-representation: true`, `template-rendering-intent: original`) and the exported PDF `poweredByGiniBadge.pdf` (Figma node `35631:1805`, 90×23 pt, white pill + pink gini wordmark, theme-agnostic).
- `GiniComponents/Utilities/GiniUtilites/Package.swift` AND `GiniComponents/Utilities/GiniUtilites/Package-release.swift` — target `GiniUtilites` gains `resources: [.process("Resources")]` in both manifests.
- `CaptureSDK/GiniCaptureSDK/Sources/GiniCaptureSDK/Core/Screens/Analysis/AnalysisViewController.swift` — add `private var poweredByGiniBadgeView: PoweredByGiniBadgeView?`, a private `addPoweredByGiniBadgeIfEnabled()` method called from `setupView()` after `addOverlay()`, and update `addOverlay()` so the badge sits above the overlay in the view hierarchy. Update `Constants` enum: `static let badgeBottomInset: CGFloat = 16`, `static let badgeSuggestionsGap: CGFloat = 8`. Adjust the constraint in `CaptureSuggestionsView.start(superView:bottomAnchor:)` call site so the banner's bottom anchor points to `poweredByGiniBadgeView?.topAnchor ?? view.safeAreaLayoutGuide.bottomAnchor` (backward-compatible: if badge is absent, banner pins to safe area as today).

**Coexistence rules on Analysis screen:**

- `showOriginalFlow` state (spinner + text): badge visible, no overlap (spinner is centered, text sits below spinner but above the badge inset).
- `showEducationFlow` state (`QRCodeEducationLoadingView` centered): badge visible, no overlap. Education flow's `markMessageAsShown()` untouched (R7).
- `CaptureSuggestionsView` banner (image documents only, 4-second auto-dismiss): banner pins above the badge when badge is present (R8).
- `AnalysisViewController.removeCaptureSuggestions()` on `viewWillDisappear`: badge remains (subview of `view`, not of the banner).

**Screen-name matching:** case-insensitive `caseInsensitiveCompare` in the Analysis screen check, matching the user's chosen contract (allows backend to send `"Analysis"`, `"analysis"`, or `"ANALYSIS"` equivalently).

**Flows leading to Analysis screen (all get the badge when enabled — no branching):**

1. Camera → Review → Analysis (image docs, `GiniScreenAPICoordinator+Review.swift:52` → `showAnalysisScreen()`)
2. Camera → Analysis directly (QR code detected via `QRCodeOverlay`; `GiniScreenAPICoordinator+Camera.swift:191,198`)
3. Import (Files/Photos) → Review → Analysis (image documents)
4. Import (Files) → Analysis directly (PDF/XML — bypasses review; `GiniScreenAPICoordinator.swift:128`)
5. Open-URL from another app → Analysis directly (`isFromOtherApp` branch; `GiniScreenAPICoordinator.swift:118-120`)

**Flows/state NOT affected by this feature (documented for reviewer clarity):**

- `captureInvoice` education (max 2 displays, `EducationFlowController+QRCode.swift:14-25`) — no counter reset, no gating change.
- `qrCode` education on Camera QR overlay (max 4 displays) — untouched.
- `NoResultScreenViewController` — the "no results" screen after Analysis is out of scope for PP-2570 (only `"Analysis"` is currently supported by the backend flag per PP-2572).
- All non-Analysis screens (Camera, Review, Onboarding, Help, Error) — no badge.

**Reset semantics:** the feature has no local persistence. `GiniCaptureUserDefaultsStorage.ingredientBrandScreens` is overwritten on each `/configurations` fetch, so a backend flip from `["Analysis"]` → `[]` disables the badge on the next SDK session. There is nothing to reset for existing users; existing education-flow counters are untouched.

## Test plan

**GiniBankAPILibraryTests / `ClientConfigurationServiceTests.swift`** (extends existing XCTest suite — see `BankAPILibrary/GiniBankAPILibrary/Tests/GiniBankAPILibraryTests/ClientConfigurationServiceTests.swift`)

Add ~3 new XCTest methods:
1. `test_ingredientBrandScreens_decodesArrayFromJSON` — feed a fixture with `"ingredientBrandScreens": ["Analysis"]`, assert decoded value equals `["Analysis"]`. Fixture added to `Tests/GiniBankAPILibraryTests/Resources/` as `clientConfigurationWithIngredientBrand.json` (proves R9 given/when/then dependency).
2. `test_ingredientBrandScreens_decodesEmptyArray` — fixture with `"ingredientBrandScreens": []`, assert decoded value equals `[]` (R9).
3. `test_ingredientBrandScreens_missingFieldFailsDecoding` — fixture with the key omitted, assert `JSONDecoder().decode(...)` throws `DecodingError.keyNotFound` (R10).

**GiniUtilitesTests / `PoweredByGiniBadgeViewTests.swift`** (new file, Swift Testing — `@Suite`, `@Test`, `#expect`; no neighboring precedent in GiniUtilites, so the new file follows the platform default)

Rough test count: **4 tests** (focused component, no branches).
1. `intrinsicContentSize returns 90x23` (R11).
2. `accessibility container is the badge itself, not the inner image` — `#expect(view.isAccessibilityElement == true)`, `#expect(view.accessibilityLabel == "Powered by Gini")`, `#expect(imageView.isAccessibilityElement == false)` (R5).
3. `image is loaded from GiniUtilites .module bundle` — asserts `imageView.image != nil` (regression guard that resource bundle wiring works).
4. `accessibility traits include .image` (R5).

**GiniCaptureSDKTests / `AnalysisViewControllerTests.swift`** (extends existing XCTest file — `CaptureSDK/GiniCaptureSDK/Tests/GiniCaptureSDKTests/AnalysisViewControllerTests.swift`)

Add ~5 new XCTest methods (bringing the class to a multi-path component ~9–10 tests, justified by the R2/R3/R7/R8 branch matrix):
1. `test_analysis_showsPoweredByBadge_whenIngredientBrandScreensContainsAnalysis` — set storage to `["Analysis"]`, load view, assert a `PoweredByGiniBadgeView` is in the subview tree and pinned to safe area bottom (R2).
2. `test_analysis_showsBadge_whenScreenNameIsLowercase` — storage `["analysis"]`, badge present (case-insensitive R2).
3. `test_analysis_hidesBadge_whenIngredientBrandScreensIsEmpty` — storage `[]`, no `PoweredByGiniBadgeView` in view tree (R3).
4. `test_analysis_hidesBadge_whenIngredientBrandScreensIsNil` — storage nil (fresh install, no `/configurations` fetched yet), no badge (R3).
5. `test_analysis_badgeStaysWhenCaptureSuggestionsRemoved` — storage `["Analysis"]`, image doc → capture suggestions banner shown → `removeCaptureSuggestions()` → badge still present (R8 tail).

**No dedicated `GiniCaptureUserDefaultsStorageTests` for `ingredientBrandScreens`.** Every sibling `@GiniUserDefault` flag on `GiniCaptureUserDefaultsStorage` (`qrCodeEducationEnabled`, `unsupportedQRCodeWarningEnabled`, `eInvoiceEnabled`, `savePhotosLocallyEnabled`, `onboardingShowed`, `userSettingsSavePhotosSwitchOn`) is covered at its writer/reader, not by a per-flag wrapper-plumbing test — the `@GiniUserDefault` property wrapper itself has no test file either. Writer coverage for `ingredientBrandScreens` lives in `RemoteConfigPropagationTests` below; reader coverage (nil / empty / `"Analysis"` / `"analysis"`) lives in `AnalysisViewControllerTests` above.

**GiniBankSDKTests / `GiniBankNetworkingScreenApiCoordinatorTests.swift`** (extends existing XCTest file if present)

Add ~1 test:
1. `test_startSDK_propagatesIngredientBrandScreensToCaptureStorage` — inject a mock `ClientConfigurationServiceProtocol` returning a `ClientConfiguration` with `ingredientBrandScreens = ["Analysis"]`, run through the coordinator start path, assert `GiniCaptureUserDefaultsStorage.ingredientBrandScreens == ["Analysis"]` (R1).

### Not tested

- **PDF asset rendering fidelity** — not tested in unit tests. The PDF being valid + present is covered by the image-loads test (badge test #3); pixel-perfect rendering vs. Figma is left to manual QA on device (light and dark mode).
- **VoiceOver end-to-end announcement** — the `accessibilityLabel == "Powered by Gini"` assertion covers the API surface; actual VoiceOver output requires manual QA with VoiceOver enabled on-device.
- **Dynamic Type at accessibility sizes** — badge is a fixed-size image, not text. Manual QA at the two largest accessibility sizes confirms no layout collision with the loading spinner/text.
- **Landscape orientation on iPhone** — Figma includes landscape variants (`35002:12312`, etc.); the current `centerYConstraint` adjustment in `viewDidLayoutSubviews` handles the existing layout, and the badge pins to safe area bottom which handles rotation for free. Left to manual QA per existing Analysis screen conventions.
- **Backend contract violation cases** other than key-omitted (e.g., wrong JSON type like `"ingredientBrandScreens": "Analysis"` as a string) — caught by JSONDecoder default behavior; not covered by unit tests because it's framework behavior.
- **`GiniCaptureSDKExampleUITests` XCUITest** — no new UI test added; the existing screen-object pattern under `Screens/` would need a `PoweredByGiniBadgeElement`, but this ticket is scoped to unit coverage per the acceptance criteria ("Unit tests cover: empty, ['Analysis'], missing object from API response").

## Out of scope

- Rendering the badge on screens outside the analyze user journey (Review, Onboarding, Help, Error, NoResults, etc.). Per PO decision the string `"Analysis"` gates the whole analyze flow — currently covering `AnalysisViewController` (R2) and the valid-QR state of `QRCodeOverlay` (R12) — but not screens outside that journey.
- Any change to the `qrCodeEducationEnabled` or `captureInvoice`/`qrCode` education flows (behavior, counters, gating).
- Extracting `PoweredByGiniView` from `GiniInternalPaymentSDK` for reuse or unification with the new `PoweredByGiniBadgeView` — the two serve different design specs (composite badge vs. inline label+logo) and live on different dependency chains.
- Health SDK (`GiniHealthSDK`) integration — no Analysis screen equivalent; Health has its own `ingredientBrandType` mechanism in `GiniHealthAPILibrary` (out of PP-2570's scope).
- Localization of the "Powered by Gini" accessibility label — per user decision, no new string keys; the phrase is a brand mark.
- Snapshot testing infrastructure — none exists in the repo, not adding it for one component.
- Backend implementation (PP-2572) — blocking dependency, tracked separately.
- Design polish beyond the current Figma exports — visual details are locked to Figma component `35631:1805` (90×23 pt).

## Open questions

None. All decisions from the clarifying rounds are folded into the requirements and Technical conventions.

## Implementation plan
- [x] 1. Add `ingredientBrandScreens: [String]` to `ClientConfiguration` (property + `init` parameter, default `[]` for source-compat) and add Swift Testing cases + a `clientConfigurationWithIngredientBrand.json` fixture in `GiniBankAPILibraryTests`. Neighboring `ClientConfigurationTests.swift` already uses Swift Testing, so extend it there (deviation from spec's `ClientConfigurationServiceTests.swift`/XCTest wording — matches `platform.md` "match neighboring test file"). (R9, R10)
- [x] 2. Add `PoweredByGiniBadgeView` (public final `UIView`) in `GiniComponents/Utilities/GiniUtilites/Sources/GiniUtilites/Brand/`. Add `PoweredByGiniBadgeViewTests.swift` using Swift Testing. (R2, R4, R5, R11)
- [x] 3. Add `resources: [.process("Resources")]` to the `GiniUtilites` target in both `Package.swift` and `Package-release.swift` so the badge PDF ships in both manifests. (R2)
- [x] 4. Add `@GiniUserDefault("ginicapture.defaults.clientConfigurations.ingredientBrandScreens", defaultValue: nil) public static var ingredientBrandScreens: [String]?` in `GiniCaptureUserDefaultsStorage`. Add a new XCTest file `GiniCaptureUserDefaultsStorageTests.swift` covering persistence + nil-default. (R1)
- [x] 5. Extend `GiniBankNetworkingScreenApiCoordinator.startSDK` `/configurations` success block with the mirror line `GiniCaptureUserDefaultsStorage.ingredientBrandScreens = configuration.ingredientBrandScreens`. Extend `RemoteConfigPropagationTests` (Swift Testing) with a case asserting the value lands (deviation from spec's `GiniBankNetworkingScreenApiCoordinatorTests.swift` — `RemoteConfigPropagationTests.swift` is the propagation-mirror precedent). (R1)
- [x] 6. In `AnalysisViewController`: add a private `poweredByGiniBadgeView` subview created only when `GiniCaptureUserDefaultsStorage.ingredientBrandScreens` case-insensitively contains `"Analysis"`; pin centered X and bottom to safe-area with `Constants.badgeBottomInset`; adjust `showCaptureSuggestions` so the banner pins to `poweredByGiniBadgeView?.topAnchor ?? view.safeAreaLayoutGuide.bottomAnchor` minus `Constants.badgeSuggestionsGap`. Extend `AnalysisViewControllerTests` (XCTest) with the five cases from the test plan. (R2, R3, R6, R7, R8)
- [x] 7. Run `make lint scheme=GiniBankSDK` and `make lint scheme=GiniCaptureSDK`; run the affected module unit tests (BankAPI, Utilites, Capture, Bank). Fix any regressions.

