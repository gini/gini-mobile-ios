//
//  AnalysisViewController.swift
//  GiniCapture
//
//  Created by Peter Pult on 21/06/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import UIKit

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
            loadingText.text = String(format: LocalizedStrings.loadingPDFText, documentTitle)
        } else {
            loadingText.text = LocalizedStrings.loadingBaseText
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

    /**
     Designated intitializer for the `AnalysisViewController`.
     
     - parameter document: Reviewed document ready for analysis.
     - parameter giniConfiguration: `GiniConfiguration` instance.
     
     - returns: A view controller instance giving the user a nice user interface while waiting for the analysis results.
     */
    public init(document: GiniCaptureDocument, giniConfiguration: GiniConfiguration) {
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
        self.init(document: document, giniConfiguration: GiniConfiguration.shared)
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

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        removeCaptureSuggestions()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if UIDevice.current.isIphone, document is GiniImageDocument {
            let isLandscape = currentInterfaceOrientation.isLandscape
            centerYConstraint.constant = isLandscape ? -Constants.loadingIndicatorContainerHorizontalCenterYInset : 0
        }
    }

    // MARK: Toggle animation

    /// Displays a loading activity indicator. Should be called when document analysis is started.
    public func showAnimation() {
        if let loadingIndicator = giniConfiguration.customLoadingIndicator {
            loadingIndicator.startAnimation()
        } else {
            loadingIndicatorView.startAnimating()
        }
    }

    /// Hides the loading activity indicator. Should be called when document analysis is finished.
    public func hideAnimation() {
        if let loadingIndicator = giniConfiguration.customLoadingIndicator {
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
        view.backgroundColor = GiniColor(light: UIColor.GiniCapture.light2, dark: UIColor.GiniCapture.dark2).uiColor()
        title = NSLocalizedStringPreferredFormat("ginicapture.analysis.screenTitle", comment: "Analysis screen title")

        if let document = document as? GiniPDFDocument {
            imageView.image = document.previewImage
        }

        configureLoadingIndicator()
        addOverlay()
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
        let displayEducationFlow = !document.isImported && giniConfiguration.fileImportSupportedTypes != .none
        educationFlowController = EducationFlowController
            .captureInvoiceFlowController(displayIfNeeded: displayEducationFlow)

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
        loadingIndicatorView.color = GiniColor(light: .GiniCapture.dark1, dark: .GiniCapture.light1).uiColor()
        loadingIndicatorView.accessibilityValue = loadingIndicatorText.text

        addLoadingContainer()
        addLoadingView(intoContainer: loadingIndicatorContainer)

        if let loadingIndicator = giniConfiguration.customLoadingIndicator {
            addLoadingText(below: loadingIndicator.injectedView())
            loadingIndicator.startAnimation()
        } else {
            addLoadingText(below: loadingIndicatorView)
            loadingIndicatorView.startAnimating()
        }
        // immediately mark animation complete
        animationCompletionContinuations.forEach { $0.resume() }
        animationCompletionContinuations.removeAll()
    }

    private func showEducationLoadingMessage() {
        let loadingItems = EducationFlowContent.captureInvoice.items
        let viewModel = QRCodeEducationLoadingViewModel(items: loadingItems)
        loadingViewModel = viewModel
        let customLoadingView = QRCodeEducationLoadingView(viewModel: viewModel)
        customLoadingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(customLoadingView)

        NSLayoutConstraint.activate([
            customLoadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            customLoadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            customLoadingView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor,
                                                       constant: Constants.educationLoadingViewPadding),
            customLoadingView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor,
                                                        constant: -Constants.educationLoadingViewPadding)
        ])

        Task {
            await finalizeEducationAnimation(viewModel)
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
        captureSuggestions = CaptureSuggestionsView(superView: view,
                                                    bottomAnchor: view.safeAreaLayoutGuide.bottomAnchor)
        captureSuggestions?.start()
    }

    private func removeCaptureSuggestions() {
        captureSuggestions?.removeFromSuperview()
        captureSuggestions = nil
    }
}

private extension AnalysisViewController {
    enum Constants {
        static let padding: CGFloat = 16
        static let educationLoadingViewPadding: CGFloat = 28
        static let loadingIndicatorContainerHeight: CGFloat = 60
        static let loadingIndicatorContainerHorizontalCenterYInset: CGFloat = 96 / 2
        static let widthMultiplier: CGFloat = 0.9
    }

    enum LocalizedStrings {
        static let loadingPDFText = NSLocalizedStringPreferredFormat("ginicapture.analysis.loadingText.pdf",
                                                                     comment: "Analysis screen loading text for PDF")

        static let loadingBaseText = NSLocalizedStringPreferredFormat("ginicapture.analysis.loadingText",
                                                                      comment: "Analysis screen loading base text")

    }
}
