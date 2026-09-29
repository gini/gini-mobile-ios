//
//  IngredientBrandFlowUITests.swift
//  GiniBankSDKExampleUITests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import XCTest

/**
 UI-automation for the Ingredient Brand feature on the Analysis screen.

 The backend's `ingredientBrandScreens` list toggles the "Powered by Gini"
 badge and the branded Gini loading indicator on `AnalysisViewController`.
 The mock backend (`UITestMockBackend`) serves the desired list without a
 real API call, and an analysis delay keeps the Analysis screen visible
 long enough for XCUITest to query the elements.

 Fixture: reuses `TestFixtures.Files.testImage` — the mock backend ignores
 the uploaded content and serves the `invoice` scenario payload regardless.
 */
final class IngredientBrandFlowUITests: GiniBankSDKExampleUITests {

    /// Seconds the mock backend delays analysis completion. Keeps the Analysis
    /// screen in the view hierarchy long enough for the assertions below;
    /// tightly bounded so the whole class stays fast on BrowserStack.
    private static let analysisDelaySeconds = "8.0"

    /**
     Runs the shared journey up to (and including) the Analysis screen.
     Mock backend delivers analysis after `analysisDelaySeconds`.
     */
    private func runFlowToAnalysis() {
        mainScreen.photoPaymentButton.tap()
        mainScreen.handleCameraPermission(answer: true)
        onboadingScreen.skipOnboardingScreens()
        captureScreen.filesButton.tap()
        captureScreen.uploadFilesButton.tap()
        mainScreen.tapFileFromBestAvailableSource(fileName: TestFixtures.Files.testImage)
        if captureScreen.openGalleryButton.waitForExistence(timeout: 3) {
            captureScreen.openGalleryButton.tap()
        }
    }

    // MARK: - Flag off — default loading, no brand

    override var additionalLaunchArguments: [String] {
        ["-UITestMockScenario", "invoice",
         "-UITestMockAnalysisDelaySeconds", Self.analysisDelaySeconds]
    }

    /**
     Empty `ingredientBrandScreens` (prod default): no badge, no branded indicator,
     the default `UIActivityIndicatorView` drives the loading state.
     */
    func testFlagOffShowsDefaultLoadingIndicator() throws {
        // Base additionalLaunchArguments already sets an empty ingredient-brand list.
        runFlowToAnalysis()

        XCTAssertTrue(ingredientBrandScreen.waitForDefaultLoadingIndicator(),
                      "Default loading indicator should appear when ingredientBrandScreens is empty")
        XCTAssertFalse(ingredientBrandScreen.poweredByGiniLoadingIndicator.exists,
                       "Branded loading indicator must NOT appear when the flag is off")
        XCTAssertFalse(ingredientBrandScreen.poweredByGiniBadge.exists,
                       "Powered-by-Gini badge must NOT appear when the flag is off")
    }

    // MARK: - Flag on — branded indicator + badge

    /**
     `ingredientBrandScreens = ["Analysis"]`: the branded Gini loading indicator
     replaces the default indicator, and the "Powered by Gini" badge is visible.
     */
    func testFlagOnShowsBrandedLoadingIndicatorAndBadge() throws {
        extraLaunchArguments = ["-UITestMockIngredientBrandScreens", "Analysis"]
        relaunch()
        runFlowToAnalysis()

        XCTAssertTrue(ingredientBrandScreen.waitForBrandedLoadingIndicator(),
                      "Branded Gini loading indicator should appear when ingredientBrandScreens contains Analysis")
        XCTAssertTrue(ingredientBrandScreen.waitForBadge(),
                      "Powered-by-Gini badge should appear when ingredientBrandScreens contains Analysis")
        XCTAssertFalse(ingredientBrandScreen.defaultLoadingIndicator.exists,
                       "Default loading indicator must NOT be visible when the branded one is active")
    }

    // MARK: - Unknown value — ignored, no brand, no error

    /**
     `ingredientBrandScreens = ["Unknown"]`: the SDK ignores unknown screen names
     and renders the Analysis screen without the brand — identical to flag-off.
     */
    func testUnknownScreenValueRendersWithoutBrand() throws {
        extraLaunchArguments = ["-UITestMockIngredientBrandScreens", "Unknown"]
        relaunch()
        runFlowToAnalysis()

        XCTAssertTrue(ingredientBrandScreen.waitForDefaultLoadingIndicator(),
                      "Default loading indicator should appear for an unknown ingredientBrandScreens value")
        XCTAssertFalse(ingredientBrandScreen.poweredByGiniLoadingIndicator.exists,
                       "Branded loading indicator must NOT appear for an unknown value")
        XCTAssertFalse(ingredientBrandScreen.poweredByGiniBadge.exists,
                       "Powered-by-Gini badge must NOT appear for an unknown value")
    }

    // MARK: - Dark theme — brand still renders correctly

    /**
     Flag on + dark interface style: the branded indicator and badge stay in the
     view hierarchy. `-AppleInterfaceStyle Dark` is the launch-time system default
     that iOS reads before the app configures its window.
     */
    func testBrandedElementsAppearInDarkTheme() throws {
        extraLaunchArguments = [
            "-UITestMockIngredientBrandScreens", "Analysis",
            "-AppleInterfaceStyle", "Dark"
        ]
        relaunch()
        runFlowToAnalysis()

        XCTAssertTrue(ingredientBrandScreen.waitForBrandedLoadingIndicator(),
                      "Branded loading indicator should appear in dark mode when the flag is on")
        XCTAssertTrue(ingredientBrandScreen.waitForBadge(),
                      "Powered-by-Gini badge should appear in dark mode when the flag is on")
    }

    // MARK: - Light theme — brand renders correctly

    /**
     Flag on + light interface style: mirror of the dark-mode test. Made
     explicit so the light-theme path is a first-class assertion instead of
     an implicit default across the other flag-on cases. Verifies the SDK
     serves the light HEIC variant when the app is launched with
     `-AppleInterfaceStyle Light`.
     */
    func testBrandedElementsAppearInLightTheme() throws {
        extraLaunchArguments = [
            "-UITestMockIngredientBrandScreens", "Analysis",
            "-AppleInterfaceStyle", "Light"
        ]
        relaunch()
        runFlowToAnalysis()

        XCTAssertTrue(ingredientBrandScreen.waitForBrandedLoadingIndicator(),
                      "Branded loading indicator should appear in light mode when the flag is on")
        XCTAssertTrue(ingredientBrandScreen.waitForBadge(),
                      "Powered-by-Gini badge should appear in light mode when the flag is on")
    }

    // MARK: - Portrait ↔ landscape rotation — brand persists

    /**
     Flag on + orientation flip mid-flow: the branded loading indicator and
     the "Powered by Gini" badge must remain in the view hierarchy across
     portrait → landscape → portrait. `AnalysisViewController` swaps a
     size-class-scoped centerY constraint set in `traitCollectionDidChange`;
     this test guards against the rotation dropping the mark altogether.
     */
    func testBrandedElementsPersistAcrossOrientations() throws {
        extraLaunchArguments = ["-UITestMockIngredientBrandScreens", "Analysis"]
        relaunch()
        runFlowToAnalysis()

        XCTAssertTrue(ingredientBrandScreen.waitForBrandedLoadingIndicator(),
                      "Branded indicator should be visible in portrait before rotating")
        XCTAssertTrue(ingredientBrandScreen.waitForBadge(),
                      "Powered-by-Gini badge should be visible in portrait before rotating")

        XCUIDevice.shared.orientation = .landscapeLeft
        /// Guard against a silent no-op: if the example app's Info.plist or
        /// `AnalysisViewController.supportedInterfaceOrientations` force-locks
        /// portrait, the setter above is ignored and the rest of the assertions
        /// pass trivially. Fail loudly so the root cause is obvious.
        XCTAssertTrue(XCUIDevice.shared.orientation.isLandscape,
                      "Device did not rotate to landscape — check Info.plist UISupportedInterfaceOrientations and Analysis screen orientation policy")
        XCTAssertTrue(ingredientBrandScreen.poweredByGiniLoadingIndicator.waitForExistence(timeout: 3),
                      "Branded indicator should stay visible after rotating to landscape")
        XCTAssertTrue(ingredientBrandScreen.poweredByGiniBadge.waitForExistence(timeout: 3),
                      "Powered-by-Gini badge should stay visible after rotating to landscape")

        XCUIDevice.shared.orientation = .portrait
        XCTAssertTrue(XCUIDevice.shared.orientation.isPortrait,
                      "Device did not rotate back to portrait — same suspects as above")
        XCTAssertTrue(ingredientBrandScreen.poweredByGiniLoadingIndicator.waitForExistence(timeout: 3),
                      "Branded indicator should stay visible after rotating back to portrait")
        XCTAssertTrue(ingredientBrandScreen.poweredByGiniBadge.waitForExistence(timeout: 3),
                      "Powered-by-Gini badge should stay visible after rotating back to portrait")
    }

    // MARK: - Case-insensitive membership check

    /**
     Lowercase `"analysis"` must still enable the branded UI — the SDK's
     ingredient-brand membership check is case-insensitive.
     */
    func testCaseInsensitiveAnalysisEnablesBrand() throws {
        extraLaunchArguments = ["-UITestMockIngredientBrandScreens", "analysis"]
        relaunch()
        runFlowToAnalysis()

        XCTAssertTrue(ingredientBrandScreen.waitForBrandedLoadingIndicator(),
                      "Branded indicator should activate for a case-insensitive 'analysis' match")
        XCTAssertTrue(ingredientBrandScreen.waitForBadge(),
                      "Powered-by-Gini badge should activate for a case-insensitive 'analysis' match")
    }

    // MARK: - Non-Analysis screen name

    /**
     `ingredientBrandScreens = ["Camera"]` is a valid non-Analysis value: the
     Analysis screen must render as flag-off — no badge, no branded indicator.
     */
    func testNonAnalysisScreenValueDoesNotEnableAnalysisBrand() throws {
        extraLaunchArguments = ["-UITestMockIngredientBrandScreens", "Camera"]
        relaunch()
        runFlowToAnalysis()

        XCTAssertTrue(ingredientBrandScreen.waitForDefaultLoadingIndicator(),
                      "Default loading indicator should appear when only non-Analysis screens are enabled")
        XCTAssertFalse(ingredientBrandScreen.poweredByGiniLoadingIndicator.exists,
                       "Branded loading indicator must NOT appear when 'Analysis' is not listed")
        XCTAssertFalse(ingredientBrandScreen.poweredByGiniBadge.exists,
                       "Powered-by-Gini badge must NOT appear when 'Analysis' is not listed")
    }

    // MARK: - VoiceOver label on the branded indicator

    /**
     `AnalysisViewController.showBrandedLoadingIndicator(_:)` assigns
     `indicator.accessibilityLabel = loadingIndicatorText.text`, so XCUITest's
     `.label` on the branded indicator equals the localized analysis loading
     text — verifies the VoiceOver announcement carries the same message as the
     visible loading text.
     */
    func testBrandedLoadingIndicatorAccessibilityLabelMatchesLoadingText() throws {
        extraLaunchArguments = ["-UITestMockIngredientBrandScreens", "Analysis"]
        relaunch()
        runFlowToAnalysis()

        XCTAssertTrue(ingredientBrandScreen.waitForBrandedLoadingIndicator(),
                      "Branded indicator should be present before asserting its label")
        /// `AnalysisViewController.showBrandedLoadingIndicator(_:)` sets the
        /// label from `loadingIndicatorText.text`, which appends the current
        /// document's filename on a new line (e.g. `"Analyzing\n<file>.pdf"`).
        /// Assert the leading token instead of the full text so the check is
        /// robust across fixture names and locales.
        let leadingToken = analysisLoadingText.components(separatedBy: " ").first ?? analysisLoadingText
        let actualLabel = ingredientBrandScreen.poweredByGiniLoadingIndicator.label
        XCTAssertTrue(actualLabel.hasPrefix(leadingToken),
                      "Branded indicator's accessibility label should begin with the analysis loading token — got: \(actualLabel)")
        /// iOS surfaces the document filename on a new line after the loading
        /// token (e.g. `"Analyzing\ntest_image_….pdf"`). Asserting `.pdf` is
        /// present proves the filename made it into the a11y label without
        /// hard-coding the fixture's timestamped basename.
        XCTAssertTrue(actualLabel.lowercased().contains(".pdf"),
                      "Branded indicator's accessibility label should include the analyzed PDF filename — got: \(actualLabel)")
    }

    // MARK: - Custom loading indicator precedence

    /**
     Flag on + integrator-injected custom loading indicator: the branded Gini
     indicator wins, the custom one is not in the tree.
     */
    func testFlagOnBeatsCustomLoadingIndicator() throws {
        extraLaunchArguments = [
            "-UITestMockIngredientBrandScreens", "Analysis",
            "-UITestInjectCustomLoadingIndicator"
        ]
        relaunch()
        runFlowToAnalysis()

        XCTAssertTrue(ingredientBrandScreen.waitForBrandedLoadingIndicator(),
                      "Branded Gini indicator should win over the injected custom indicator")
        XCTAssertFalse(ingredientBrandScreen.customLoadingIndicator.exists,
                       "Custom loading indicator must NOT appear when the branded one is active")
    }

    /**
     Flag off + integrator-injected custom loading indicator: the custom
     indicator is used, no branded indicator, and the default
     `UIActivityIndicatorView` is bypassed.
     */
    func testFlagOffKeepsCustomLoadingIndicator() throws {
        extraLaunchArguments = ["-UITestInjectCustomLoadingIndicator"]
        relaunch()
        runFlowToAnalysis()

        XCTAssertTrue(ingredientBrandScreen.waitForCustomLoadingIndicator(),
                      "Injected custom loading indicator should appear when the flag is off")
        XCTAssertFalse(ingredientBrandScreen.poweredByGiniLoadingIndicator.exists,
                       "Branded loading indicator must NOT appear when the flag is off")
        XCTAssertFalse(ingredientBrandScreen.defaultLoadingIndicator.exists,
                       "Default UIActivityIndicatorView must NOT appear when a custom indicator is injected")
    }

    // MARK: - Education flow interop

    /**
     Flag on + fresh education counter (< maxTotalDisplays == 2 for the
     captureInvoice flow): the education view renders and the badge stays
     visible alongside it.
     */
    func testFlagOnDuringEducationFlowKeepsBadgeVisible() throws {
        /// `AnalysisViewController.shouldDisplayEducationFlow` requires
        /// `!document.isImported`, so the files-import path used by
        /// `runFlowToAnalysis` can never trigger the education flow. Skipping
        /// until a camera-injection helper (mirror of
        /// `GiniCaptureFlowUITestsUsingBS.injectImage`) exists.
        throw XCTSkip("Education flow requires camera path; iOS files-import fixture cannot trigger it")
    }

    /**
     Flag off + fresh education counter: the education view renders WITHOUT the
     branded indicator or badge.
     */
    func testFlagOffDuringEducationFlowShowsNoBrand() throws {
        /// See `testFlagOnDuringEducationFlowKeepsBadgeVisible` — same
        /// constraint: education flow needs the camera path.
        throw XCTSkip("Education flow requires camera path; iOS files-import fixture cannot trigger it")
    }

    // MARK: - Capture-suggestions banner interop (image path — skips on PDF fixture)

    /**
     Flag on + capture-suggestions banner visible: the banner hides the badge
     on its first appearance while the branded indicator remains. The current
     PDF fixture does not trigger the banner (banner is image-path only); the
     test skips cleanly in that case rather than false-fail.
     */
    func testCaptureSuggestionsBannerHidesBadgeButKeepsBrandedIndicator() throws {
        extraLaunchArguments = ["-UITestMockIngredientBrandScreens", "Analysis"]
        relaunch()
        runFlowToAnalysis()

        let locale = Locale.current.languageCode ?? "en"
        XCTAssertTrue(ingredientBrandScreen.waitForBrandedLoadingIndicator(),
                      "Branded indicator should render before the banner appears")
        guard ingredientBrandScreen.waitForCaptureSuggestionsBanner(locale: locale) else {
            throw XCTSkip("Capture-suggestions banner did not appear within timeout — fixture is PDF-only")
        }
        XCTAssertTrue(ingredientBrandScreen.poweredByGiniLoadingIndicator.exists,
                      "Branded indicator must remain visible while the banner is shown")
        XCTAssertFalse(ingredientBrandScreen.poweredByGiniBadge.exists,
                       "Powered-by-Gini badge should be hidden while the banner is visible")
    }

    // MARK: - Delegate callback observers

    /**
     Cancelling from the Analysis screen fires `didCancelCapturing` on the
     `GiniCaptureDelegate`. The marker view (installed via
     `-UITestInstallDelegateObservers`) flips visible when it does.
     */
    func testCancelFromAnalysisFiresDidCancelCapturingCallback() throws {
        extraLaunchArguments = [
            "-UITestMockIngredientBrandScreens", "Analysis",
            "-UITestInstallDelegateObservers"
        ]
        relaunch()
        runFlowToAnalysis()

        XCTAssertTrue(ingredientBrandScreen.waitForBrandedLoadingIndicator(),
                      "Analysis screen should be visible before cancelling")

        let cancelTitles = ["Cancel", "Abbrechen"]
        let cancelButton = app.navigationBars
            .buttons
            .matching(NSPredicate(format: "label IN %@", cancelTitles))
            .firstMatch
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 5),
                      "Cancel button should be reachable on the Analysis screen")
        cancelButton.tap()

        XCTAssertTrue(ingredientBrandScreen.didCancelCapturingMarker.waitForExistence(timeout: 10),
                      "didCancelCapturing should fire after tapping cancel on the Analysis screen")
    }

    /**
     After the mock backend's analysis delay elapses, the SDK fires
     `giniCaptureAnalysisDidFinishWith(result:)` on the results delegate — the
     marker view flips visible when it does.
     */
    func testAnalysisCompletionFiresDidFinishCallback() throws {
        extraLaunchArguments = [
            "-UITestMockIngredientBrandScreens", "Analysis",
            "-UITestInstallDelegateObservers"
        ]
        relaunch()
        runFlowToAnalysis()

        XCTAssertTrue(ingredientBrandScreen.waitForBrandedLoadingIndicator(),
                      "Branded indicator should be visible while analysis is in progress")

        /// analysisDelaySeconds is 8s; give the callback observer a generous buffer.
        XCTAssertTrue(
            ingredientBrandScreen.giniCaptureAnalysisDidFinishMarker.waitForExistence(timeout: 30),
            "giniCaptureAnalysisDidFinishWith(result:) should fire when the mock backend returns"
        )
    }

    // MARK: - Cancellation squelches in-flight completion (Android test10 parity)

    /**
     Cancel mid-analysis: after tapping Cancel while the mock backend's delayed
     analysis is still in flight, `didCancelCapturing` must fire immediately and
     `giniCaptureAnalysisDidFinishWith(result:)` must NEVER fire — the SDK is
     expected to squelch the pending completion so the integrator never receives
     a spurious success for an abandoned flow.

     Ports Android `IngredientBrandTests.test10_closeDuringDelayedAnalysis_callbackNeverArrives`.
     */
    func testCancelDuringDelayedAnalysisSquelchesCompletionCallback() throws {
        extraLaunchArguments = [
            "-UITestMockIngredientBrandScreens", "Analysis",
            "-UITestInstallDelegateObservers"
        ]
        relaunch()
        runFlowToAnalysis()

        XCTAssertTrue(ingredientBrandScreen.waitForBrandedLoadingIndicator(),
                      "Analysis screen should be visible before cancelling")

        /// Tap Cancel while the 8s mock delay is still running.
        let cancelTitles = ["Cancel", "Abbrechen"]
        let cancelButton = app.navigationBars
            .buttons
            .matching(NSPredicate(format: "label IN %@", cancelTitles))
            .firstMatch
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 5),
                      "Cancel button should be reachable on the Analysis screen")
        cancelButton.tap()

        /// Positive: cancel observer fires within a few seconds.
        XCTAssertTrue(ingredientBrandScreen.didCancelCapturingMarker.waitForExistence(timeout: 5),
                      "didCancelCapturing should fire on cancel")

        /// Negative: wait past the 8s mock delay + a 4s buffer. The finish
        /// marker must NEVER appear — if it does, the SDK failed to squelch
        /// the in-flight completion after cancellation.
        XCTAssertFalse(
            ingredientBrandScreen.giniCaptureAnalysisDidFinishMarker.waitForExistence(timeout: 12),
            "giniCaptureAnalysisDidFinishWith(result:) must NOT fire after cancellation"
        )
    }

    // MARK: - Flag scope: per-launch only

    /**
     Flag on for one session, then off in the next — verifies the branded UI is
     not sticky across relaunches (guards against a UserDefaults value leaking
     between runs).
     */
    func testFlagValuePersistsPerLaunchOnly() throws {
        extraLaunchArguments = ["-UITestMockIngredientBrandScreens", "Analysis"]
        relaunch()
        runFlowToAnalysis()
        XCTAssertTrue(ingredientBrandScreen.waitForBrandedLoadingIndicator(),
                      "Branded indicator should render on first launch with the flag on")

        extraLaunchArguments = []
        relaunch()
        runFlowToAnalysis()
        XCTAssertTrue(ingredientBrandScreen.waitForDefaultLoadingIndicator(),
                      "Default indicator should render after relaunch without the flag")
        XCTAssertFalse(ingredientBrandScreen.poweredByGiniLoadingIndicator.exists,
                       "Branded indicator must NOT persist across relaunch when the flag is removed")
    }
}
