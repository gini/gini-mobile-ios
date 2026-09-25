//
//  AnalysisViewController.swift
//  GiniCapture
//
//  Created by Peter Pult on 21/06/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import UIKit
import Photos
import GiniUtilites

/**
 Delegate which can be used to communicate back to the analysis screen allowing to display custom messages on screen.
 */
@objc public protocol AnalysisDelegate {

    /**
     Will display an error screen with predefined type.

     - parameter message: The error type to be displayed.
     */
    func displayError(errorType: ErrorType, animated: Bool)

    /**
     In case that the `GiniCaptureDocument` analysed is an image it will display a no results screen
     with some capture suggestions.

     */
    func tryDisplayNoResultsScreen()
}

/**
 The `AnalysisViewController` provides a custom analysis screen which shows the upload and analysis activity.
 The user should have the option of canceling the process by navigating back to the review screen.
 */
@objcMembers public final class AnalysisViewController: UIViewController {

    var didShowAnalysis: (() -> Void)?
    var shouldSaveToGallery: Bool = false

    private let document: GiniCaptureDocument
    private let giniConfiguration: GiniConfiguration
    private let useCustomLoadingView: Bool = true
    private var loadingViewModel: QRCodeEducationLoadingViewModel?
    public weak var trackingDelegate: AnalysisScreenTrackingDelegate?

    private var animationCompletionContinuations: [CheckedContinuation<Void, Never>] = []
    private var educationFlowController: EducationFlowController?
    private var educationAnimationFinished: Bool = false
    private var shouldShowOriginalFlow: Bool {
        guard let state = educationFlowController?.nextState() else {
            return false
        }
        return state == .showOriginalFlow
    }

   internal var shouldDisplayEducationFlow: Bool {
        giniConfiguration.productTag != .cxExtractions
            && !document.isImported
            && giniConfiguration.fileImportSupportedTypes != .none
    }

    // User interface
    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private var loadingIndicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView()
        indicatorView.hidesWhenStopped = true
        indicatorView.style = .large
        indicatorView.startAnimating()
        return indicatorView
    }()

    private lazy var loadingIndicatorText: UILabel = {
        var loadingText = UILabel()
        loadingText.font = giniConfiguration.textStyleFonts[.bodyBold]
        loadingText.textAlignment = .center
        loadingText.adjustsFontForContentSizeCategory = true
        loadingText.textColor = GiniColor(light: .GiniCapture.dark1, dark: .GiniCapture.light1).uiColor()
        loadingText.isAccessibilityElement = true
        loadingText.numberOfLines = 0

        if document.type == .pdf,
           let documentTitle = (document as? GiniPDFDocument)?.pdfTitle {
            originalDocumentName = documentTitle
            loadingText.text = String(format: Strings.loadingPDFText, documentTitle)
        } else {
            if shouldSaveToGallery {
                loadingText.text = Strings.analysisLoadingTextWithPhotoLibrary
            } else {
                loadingText.text = Strings.loadingBaseText
            }
        }

        return loadingText
    }()

    private lazy var loadingIndicatorContainer: UIView = {
        let loadingIndicatorContainer = UIView(frame: CGRect.zero)
        return loadingIndicatorContainer
    }()

    private lazy var overlayView: UIView = {
        let overlayView = UIView()
        overlayView.backgroundColor = GiniColor(light: .GiniCapture.light1,
                                                dark: .GiniCapture.dark1).uiColor().withAlphaComponent(0.6)
        return overlayView
    }()

    private var captureSuggestions: CaptureSuggestionsView?
    private var centerYConstraint = NSLayoutConstraint()
    private var poweredByGiniBadgeView: PoweredByGiniBadgeView?

    private var giniIndicatorRegularVerticalConstraints: [NSLayoutConstraint] = []
    private var giniIndicatorCompactVerticalConstraints: [NSLayoutConstraint] = []

    /**
     `true` once the Gini indicator has been added as a persistent subview in
     `setupView`. Guarantees the mark stays anchored across the education →
     standard-loading transition — only text elements change position.
     */
    private var giniIndicatorAddedPersistently: Bool = false

    /**
     Animated Gini loading indicator shown when `ingredientBrandScreens` contains
     `"Analysis"`. Nil when the flag is off or the asset failed to decode — in
     both cases the SDK falls back to the default `UIActivityIndicatorView` (or
     the integrator's `CustomLoadingIndicatorAdapter`). Exposed as `internal`
     so tests can pre-empt the lazy value to exercise the fallback path.
     */
    lazy var poweredByGiniLoadingIndicatorView: PoweredByGiniLoadingIndicatorView? = {
        guard IngredientBrandScreen.isEnabled(IngredientBrandScreen.analysis,
                                              in: GiniCaptureUserDefaultsStorage.ingredientBrandScreens) else {
            return nil
        }
        let indicator = PoweredByGiniLoadingIndicatorView()
        return indicator.hasValidAsset ? indicator : nil
    }()

    var pages: [GiniCapturePage]?

    /**
     Designated intitializer for the `AnalysisViewController`.

     - parameter document: Reviewed document ready for analysis.
     - parameter giniConfiguration: `GiniConfiguration` instance.

     - returns: A view controller instance giving the user a nice user interface while waiting for the analysis results.
     */
    public init(document: GiniCaptureDocument,
                giniConfiguration: GiniConfiguration) {
        self.document = document
        self.giniConfiguration = giniConfiguration
        super.init(nibName: nil, bundle: nil)
    }

    /**
     Convenience intitializer for the `AnalysisViewController`.

     - parameter document: Reviewed document ready for analysis.

     - returns: A view controller instance giving the user a nice user interface while waiting for the analysis results.
     */
    public convenience init(document: GiniCaptureDocument) {
        self.init(document: document,
                  giniConfiguration: GiniConfiguration.shared)
    }

    /**
     Returns an object initialized from data in a given unarchiver.

     - warning: Not implemented.
     */
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        // Configure view hierachy
        setupView()

        if document is GiniImageDocument && shouldShowOriginalFlow {
            showCaptureSuggestions(giniConfiguration: giniConfiguration)
        }
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didShowAnalysis?()

        let documentTypeAnalytics = GiniAnalyticsMapper.documentTypeAnalytics(from: document.type)
        GiniAnalyticsManager.registerSuperProperties([.documentType: documentTypeAnalytics])
        GiniAnalyticsManager.trackScreenShown(screenName: .analysis)
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        /// Resume the Gini loading indicator when returning to foreground while
        /// analysis is still ongoing. `startAnimation()` is idempotent so this is
        /// safe even on first appearance (already started in `showOriginalLoadingMessage`).
        poweredByGiniLoadingIndicatorView?.startAnimation()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        removeCaptureSuggestions()

        /// Release the Gini indicator's animation loop while the screen is offscreen.
        poweredByGiniLoadingIndicatorView?.stopAnimation()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if UIDevice.current.isIphone, document is GiniImageDocument {
            let isLandscape = currentInterfaceOrientation.isLandscape
            centerYConstraint.constant = isLandscape ? -Constants.loadingIndicatorContainerHorizontalCenterYInset : 0
        }
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.verticalSizeClass != previousTraitCollection?.verticalSizeClass {
            applyGiniIndicatorConstraintsForCurrentTraits()
        }
    }

    // MARK: Toggle animation

    /// Displays a loading activity indicator. Should be called when document analysis is started.
    public func showAnimation() {
        if let giniIndicator = poweredByGiniLoadingIndicatorView {
            giniIndicator.startAnimation()
        } else if let loadingIndicator = giniConfiguration.customLoadingIndicator {
            loadingIndicator.startAnimation()
        } else {
            loadingIndicatorView.startAnimating()
        }
    }

    /// Hides the loading activity indicator. Should be called when document analysis is finished.
    public func hideAnimation() {
        if let giniIndicator = poweredByGiniLoadingIndicatorView {
            giniIndicator.stopAnimation()
        } else if let loadingIndicator = giniConfiguration.customLoadingIndicator {
            loadingIndicator.stopAnimation()
        } else {
            loadingIndicatorView.stopAnimating()
        }
    }

    /**
     Set up the view elements on the screen
     */

    private func setupView() {
        addImageView()
        edgesForExtendedLayout = []
        view.backgroundColor = GiniColor(light: .GiniCapture.light2,
                                         dark: .GiniCapture.dark2).uiColor()
        title = Strings.screenTitle

        if let document = document as? GiniPDFDocument {
            imageView.image = document.previewImage
        }

        addPersistentGiniIndicatorIfEnabled()
        configureLoadingIndicator()
        addOverlay()
        addPoweredByGiniBadgeIfEnabled()
    }

    /**
     Adds the Gini loading indicator as a persistent subview BEFORE the loading
     branch decides between education vs original flow. This guarantees the mark
     stays visually anchored across the education → standard transition — only
     text elements change, the g never jumps position.
     */
    private func addPersistentGiniIndicatorIfEnabled() {
        guard let giniIndicator = poweredByGiniLoadingIndicatorView else { return }
        addGiniLoadingIndicator(giniIndicator)
        giniIndicatorAddedPersistently = true
    }

    /// Adds the "Powered by Gini" badge if the Analysis screen is enabled. No-op otherwise.
    private func addPoweredByGiniBadgeIfEnabled() {
        guard IngredientBrandScreen.isEnabled(IngredientBrandScreen.analysis,
                                              in: GiniCaptureUserDefaultsStorage.ingredientBrandScreens) else { return }

        let badge = PoweredByGiniBadgeView()
        view.addSubview(badge)
        badge.giniMakeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeBottom).constant(-Constants.badgeBottomInset)
        }
        poweredByGiniBadgeView = badge
    }

    private func addImageView() {
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        Constraints.active(item: imageView, attr: .top, relatedBy: .equal, to: view.safeAreaLayoutGuide, attr: .top,
                          priority: 999)
        Constraints.active(item: imageView, attr: .bottom, relatedBy: .equal, to: view.safeAreaLayoutGuide,
                           attr: .bottom, priority: 999)
        Constraints.active(item: imageView, attr: .centerX, relatedBy: .equal, to: view, attr: .centerX)
        Constraints.active(item: imageView, attr: .width, relatedBy: .equal, to: view, attr: .width,
                           multiplier: Constants.widthMultiplier)
    }

    private func addOverlay() {
        view.insertSubview(overlayView, aboveSubview: imageView)
        overlayView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([overlayView.topAnchor.constraint(equalTo: view.topAnchor),
                                     overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                     overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                                     overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
    }

    private func configureLoadingIndicator() {
        // For cross border Extractions we don't want to show the education flow, so we can skip directly to showing the original loading message
        educationFlowController = EducationFlowController
            .captureInvoiceFlowController(displayIfNeeded: shouldDisplayEducationFlow)

        let nextState = educationFlowController?.nextState()
        switch nextState {
        case .showMessage:
            showEducationLoadingMessage()
        case .showOriginalFlow:
            showOriginalLoadingMessage()
        case .none:
            showOriginalLoadingMessage()
        }
    }

    private func showOriginalLoadingMessage() {
        loadingIndicatorView.color = GiniColor(light: .GiniCapture.dark1,
                                               dark: .GiniCapture.light1).uiColor()
        loadingIndicatorView.accessibilityValue = loadingIndicatorText.text

        if let giniIndicator = poweredByGiniLoadingIndicatorView {
            giniIndicator.accessibilityLabel = loadingIndicatorText.text
            if !giniIndicatorAddedPersistently {
                addGiniLoadingIndicator(giniIndicator)
            }
            addGiniLoadingText(below: giniIndicator)
            giniIndicator.startAnimation()
        } else {
            addLoadingContainer()
            addLoadingView(intoContainer: loadingIndicatorContainer)

            if let loadingIndicator = giniConfiguration.customLoadingIndicator {
                addLoadingText(below: loadingIndicator.injectedView())
                loadingIndicator.startAnimation()
            } else {
                addLoadingText(below: loadingIndicatorView)
                loadingIndicatorView.startAnimating()
            }
        }
        // immediately mark animation complete
        animationCompletionContinuations.forEach { $0.resume() }
        animationCompletionContinuations.removeAll()
    }

    /**
     Adds the Gini loading indicator to the root view. The g mark renders at its
     intrinsic Figma size (~135pt tall) in **both** orientations — only the vertical
     center changes:
     - **Regular vertical** (portrait iPhone, iPad): centerY at 40% of view height
       from the top, matching Figma `top: calc(50% - 80.5px)` on the reference frame.
     - **Compact vertical** (landscape iPhone): centerY at ~28% of view height from
       the top, so the g mark + the loading text below it stay above the
       capture-suggestions tip banner without shrinking the mark.

     The two constraint sets are swapped in `traitCollectionDidChange` when the
     vertical size class flips at runtime.
     */
    private func addGiniLoadingIndicator(_ indicator: PoweredByGiniLoadingIndicatorView) {
        view.addSubview(indicator)
        indicator.giniMakeConstraints { $0.centerX.equalTo(view.centerX) }

        giniIndicatorRegularVerticalConstraints = indicator.giniMakeConstraints {
            $0.centerY.equalTo(view.centerY)
                .multipliedBy(Constants.giniIndicatorRegularVerticalCenterYMultiplier)
        }
        giniIndicatorCompactVerticalConstraints = indicator.giniMakeConstraints {
            $0.centerY.equalTo(view.centerY)
                .multipliedBy(Constants.giniIndicatorCompactVerticalCenterYMultiplier)
        }
        /// Both size-class-specific centerY sets are activated on creation by the
        /// DSL; deactivate them up front so `applyGiniIndicatorConstraintsForCurrentTraits`
        /// installs only the one that matches the current vertical size class.
        NSLayoutConstraint.deactivate(giniIndicatorRegularVerticalConstraints
                                      + giniIndicatorCompactVerticalConstraints)

        applyGiniIndicatorConstraintsForCurrentTraits()
    }

    /**
     Activates the size-class-appropriate constraint set for the Gini indicator.
     No-op when the Gini path isn't active (arrays are empty), so this is safe to
     call from `traitCollectionDidChange` regardless of which loading path is running.
     */
    private func applyGiniIndicatorConstraintsForCurrentTraits() {
        guard !giniIndicatorRegularVerticalConstraints.isEmpty else { return }
        let isCompactVertical = traitCollection.verticalSizeClass == .compact
        let toActivate = isCompactVertical
            ? giniIndicatorCompactVerticalConstraints
            : giniIndicatorRegularVerticalConstraints
        let toDeactivate = isCompactVertical
            ? giniIndicatorRegularVerticalConstraints
            : giniIndicatorCompactVerticalConstraints
        NSLayoutConstraint.deactivate(toDeactivate)
        NSLayoutConstraint.activate(toActivate)
    }

    /**
     Pins `loadingIndicatorText` directly to the root view (not the spinner container),
     below the Gini indicator. Layout parallels `addLoadingText(below:)` but scopes the
     text into the root view since the Gini path bypasses `loadingIndicatorContainer`.
     */
    private func addGiniLoadingText(below giniIndicator: UIView) {
        view.addSubview(loadingIndicatorText)
        loadingIndicatorText.giniMakeConstraints {
            $0.top.equalTo(giniIndicator.bottom).constant(Constants.padding)
            $0.leading.equalTo(imageView.leading)
            $0.centerX.equalTo(imageView.centerX)
            $0.bottom.lessThanOrEqualTo(view.safeBottom).constant(-Constants.padding)
        }
    }

    private func showEducationLoadingMessage() {
        let loadingItems = EducationFlowContent.captureInvoice.items
        let viewModel = QRCodeEducationLoadingViewModel(items: loadingItems)
        loadingViewModel = viewModel
        let ingredientBrandEnabled = IngredientBrandScreen.isEnabled(IngredientBrandScreen.analysis,
                                                                     in: GiniCaptureUserDefaultsStorage.ingredientBrandScreens)
        /// When the persistent Gini indicator is active, tell the education view to
        /// skip its own internal `imageView` — the g mark is already anchored to
        /// the screen and the education carousel only needs to render text + suffix
        /// below it. This is what keeps the g visually static across the transition.
        let hideEducationImageView = giniIndicatorAddedPersistently
        let style = QRCodeEducationLoadingView.Style(useIngredientBrandIndicator: ingredientBrandEnabled,
                                                     hideImageView: hideEducationImageView)
        let customLoadingView = QRCodeEducationLoadingView(viewModel: viewModel, style: style)
        view.addSubview(customLoadingView)
        customLoadingView.giniMakeConstraints {
            $0.centerX.equalTo(view.centerX)
            $0.leading.greaterThanOrEqualTo(view.leading).constant(Constants.educationLoadingViewPadding)
            $0.trailing.lessThanOrEqualTo(view.trailing).constant(-Constants.educationLoadingViewPadding)
            if hideEducationImageView, let giniIndicator = poweredByGiniLoadingIndicatorView {
                /// Persistent-g layout: anchor the education carousel's text stack directly
                /// below the g mark's bottom. The g holds its position, only the text below it
                /// swaps content between education and standard.
                $0.top.equalTo(giniIndicator.bottom).constant(Constants.padding)
            } else {
                /// Fallback layout (non-ingredient-brand): center the whole educationView
                /// (with its own internal imageView) on the screen, as before.
                $0.centerY.equalTo(view.centerY)
            }
        }

        Task {
            await finalizeEducationAnimation(viewModel)

            ///  remove QRCodeEducationLoadingView once animation finished
            customLoadingView.removeFromSuperview()

            /// Keep the Analysis screen populated while extraction continues in
            /// the background — without this, removing the education view leaves
            /// a blank screen for the remainder of the extraction request.
            showOriginalLoadingMessage()
        }
    }

    /**
     Handles the finalization of the education animation sequence:
     - Starts the view model lifecycle.
     - Resumes all pending animation completion continuations.
     - Clears the continuation list to avoid memory leaks or duplicate calls.
     - Flags the animation as finished to update UI state.
     - Marks the educational message as shown to prevent it from appearing again.
     */
    private func finalizeEducationAnimation(_ viewModel: QRCodeEducationLoadingViewModel) async {
        await viewModel.start()
        animationCompletionContinuations.forEach { $0.resume() }
        animationCompletionContinuations.removeAll()
        educationAnimationFinished = true
        educationFlowController?.markMessageAsShown()
    }

    /**
     Suspends the current task until the animation inside the analysis screen has completed.

     If the animation is already completed, this method returns immediately.
     Otherwise, it suspends execution and resumes once the animation finishes.
     */
    public func waitUntilAnimationCompleted() async {
        await withCheckedContinuation { continuation in
            guard loadingViewModel != nil else {
                continuation.resume()
                return
            }

            if educationAnimationFinished {
                continuation.resume()
            } else {
                animationCompletionContinuations.append(continuation)
            }
        }
    }

    public func saveDocumentPhotoToGalleryIfNeeded() {
        guard let pages, !pages.isEmpty, shouldSaveToGallery  else { return  }
        let documentsToSave = pages.filter({ !$0.document.isImported }).compactMap({ $0.document.previewImage })

        PHPhotoLibrary.shared().performChanges({
            for documentToSave in documentsToSave {
                PHAssetChangeRequest.creationRequestForAsset(from: documentToSave)
            }
        }, completionHandler: { _, _ in
            // callback NOT guaranteed on the main thread
            // we don't handle errors or any success message here for now
        })
    }

    private func addLoadingText(below loadingIndicator: UIView) {
        loadingIndicatorContainer.addSubview(loadingIndicatorText)
        loadingIndicatorText.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            loadingIndicatorText.topAnchor.constraint(equalTo: loadingIndicator.bottomAnchor,
                                                      constant: Constants.padding),
            loadingIndicatorText.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            loadingIndicatorText.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            loadingIndicatorText.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                         constant: -Constants.padding)])
    }

    private func addLoadingView(intoContainer container: UIView? = nil) {
        let loadingIndicator: UIView

        if let customLoadingIndicator = giniConfiguration.customLoadingIndicator?.injectedView() {
            loadingIndicator = customLoadingIndicator
        } else {
            loadingIndicator = loadingIndicatorView
        }

        if let container = container {
            container.translatesAutoresizingMaskIntoConstraints = false
            loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(container)
            container.addSubview(loadingIndicator)
            centerYConstraint = container.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            NSLayoutConstraint.activate([
                container.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                centerYConstraint,
                container.heightAnchor.constraint(equalToConstant: Constants.loadingIndicatorContainerHeight),
                container.widthAnchor.constraint(equalTo: container.heightAnchor),
                loadingIndicator.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                loadingIndicator.centerYAnchor.constraint(equalTo: container.centerYAnchor)
            ])
        } else {
            view.addSubview(loadingIndicatorView)

            NSLayoutConstraint.activate([
                loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        }
    }

    private func addLoadingContainer() {
        loadingIndicatorContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicatorContainer)
        NSLayoutConstraint.activate([
            loadingIndicatorContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicatorContainer.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor),
            loadingIndicatorContainer.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor,
                                                               constant: Constants.padding)])
    }

    private func showCaptureSuggestions(giniConfiguration: GiniConfiguration) {
        let suggestions = CaptureSuggestionsView(superView: view,
                                                 bottomAnchor: view.safeAreaLayoutGuide.bottomAnchor)
        /// Hide the badge on the first banner appearance and keep it hidden — ignoring
        /// banner-hidden transitions avoids re-showing the badge between banner cycles.
        suggestions.onBannerVisibilityChange = { [weak self] isBannerVisible in
            guard isBannerVisible else { return }
            self?.poweredByGiniBadgeView?.isHidden = true
        }
        captureSuggestions = suggestions
        suggestions.start()
    }

    /**
     Remove any capture-suggestions banner currently attached to the
     Analysis screen. Coordinators that present a modal on top of the
     Analysis screen call this to cancel a still-pending 4-second banner.
     */
    public func removeCaptureSuggestions() {
        captureSuggestions?.removeFromSuperview()
        captureSuggestions = nil
        /// Restore visibility in case the badge was hidden by the banner-visibility callback.
        poweredByGiniBadgeView?.isHidden = false
    }

}

private extension AnalysisViewController {
    enum Constants {
        static let padding: CGFloat = 16
        static let educationLoadingViewPadding: CGFloat = 28
        static let loadingIndicatorContainerHeight: CGFloat = 60
        static let loadingIndicatorContainerHorizontalCenterYInset: CGFloat = 96 / 2
        static let widthMultiplier: CGFloat = 0.9
        static let badgeBottomInset: CGFloat = 16
        /// Places the Gini ingredient-brand loading indicator's centerY at 40% of
        /// view height from the top — the fraction Figma's `top: calc(50% - 80.5px)`
        /// resolves to on the 812pt reference screen. Used in regular vertical size
        /// class (portrait iPhone, iPad).
        static let giniIndicatorRegularVerticalCenterYMultiplier: CGFloat = 0.80
        /// Places the Gini indicator at ~28% of view height from the top in compact
        /// vertical size class (landscape iPhone) so the loading text below it stays
        /// clear of the capture-suggestions tip banner. The indicator itself retains
        /// its intrinsic Figma height (~135pt) — only the centerY changes between
        /// orientations, not the mark's size.
        static let giniIndicatorCompactVerticalCenterYMultiplier: CGFloat = 0.55
    }

    struct Strings {
        static let screenTitle = NSLocalizedStringPreferredFormat("ginicapture.analysis.screenTitle",
                                                                  comment: "Analysis screen title")
        static let loadingPDFText = NSLocalizedStringPreferredFormat("ginicapture.analysis.loadingText.pdf",
                                                                     comment: "Analysis screen loading text for PDF")

        static let loadingBaseText = NSLocalizedStringPreferredFormat("ginicapture.analysis.loadingText",
                                                                      comment: "Analysis screen loading base text")

        static let analysisLoadingTextWithPhotoLibrary = NSLocalizedStringPreferredFormat(
            "ginicapture.analysis.loadingTextPhotoLibrary",
            comment: "loading base text with photo library"
        )
    }
}

