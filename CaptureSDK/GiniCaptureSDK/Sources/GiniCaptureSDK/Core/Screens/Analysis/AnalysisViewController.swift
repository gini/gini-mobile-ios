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
 
 - note: Screen API only.
 */
@objc public protocol AnalysisDelegate {

    /**
     Will display an error view on the analysis screen with a custom message.
     The provided action will be called, when the user taps on the error view.
     
     - parameter message: The error message to be displayed.
     - parameter action:  The action to be performed after the user tapped the error view.
     */
    func displayError(withMessage message: String?, andAction action: (() -> Void)?)

    /**
     In case that the `GiniCaptureDocument` analysed is an image it will display a no results screen
     with some capture suggestions. It won't show any screen if it is not an image, return `false` in that case.
     
     - parameter resultDelegate: The result delegate to handle manually pressed action
     - returns: `true` if the screen was shown or `false` if it wasn't.
     */
    func tryDisplayNoResultsScreen(
        resultDelegate: GiniCaptureResultsDelegate?
    ) -> Bool
}

/**
 The `AnalysisViewController` provides a custom analysis screen which shows the upload and analysis activity.
 The user should have the option of canceling the process by navigating back to the review screen.
 
 - note: Component API only.
 */
@objcMembers public final class AnalysisViewController: UIViewController {

    var didShowAnalysis: (() -> Void)?
    private let document: GiniCaptureDocument
    private let giniConfiguration: GiniConfiguration
    private static let loadingIndicatorContainerHeight: CGFloat = 60

    public weak var trackingDelegate: AnalysisScreenTrackingDelegate?

    // User interface
    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private var loadingIndicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView()
        indicatorView.hidesWhenStopped = true
        indicatorView.style = .whiteLarge
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

        if document.type == .pdf {
            if let documentTitle = (document as? GiniPDFDocument)?.pdfTitle {
                let titleString = NSLocalizedStringPreferredFormat("ginicapture.analysis.loadingText.pdf",
                                                                   comment: "Analysis screen loading text for PDF")

                loadingText.text = String(format: titleString, documentTitle)
            } else {
                loadingText.text = NSLocalizedStringPreferredFormat("ginicapture.analysis.loadingText",
                                                                    comment: "Analysis screen loading text for images")
            }
        } else {
            loadingText.text = NSLocalizedStringPreferredFormat("ginicapture.analysis.loadingText",
                                                                comment: "Analysis screen loading text for images")
        }

        return loadingText
    }()

    private lazy var loadingIndicatorContainer: UIView = {
        let loadingIndicatorContainer = UIView(frame: CGRect(origin: .zero,
                                                             size: .zero))
        return loadingIndicatorContainer
    }()

    private lazy var overlayView: UIView = {
        let overlayView = UIView()
        overlayView.backgroundColor = GiniColor(light: .GiniCapture.light1,
                                                dark: .GiniCapture.dark1).uiColor().withAlphaComponent(0.6)
        return overlayView
    }()

    private lazy var errorView: NoticeView = {
        let errorView = NoticeView(text: "",
                                   type: .error,
                                   noticeAction: NoticeAction(title: "", action: {}))
        errorView.translatesAutoresizingMaskIntoConstraints = false
        return errorView
    }()

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
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didShowAnalysis?()
    }

    // MARK: Toggle animation
    /**
     Displays a loading activity indicator. Should be called when document analysis is started.
     */
    public func showAnimation() {
        if let loadingIndicator = giniConfiguration.analysisScreenLoadingIndicator {
            loadingIndicator.startAnimation()
        } else {
            loadingIndicatorView.startAnimating()
        }
    }

    /**
     Hides the loading activity indicator. Should be called when document analysis is finished.
     */
    public func hideAnimation() {
        if let loadingIndicator = giniConfiguration.analysisScreenLoadingIndicator {
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

        if document is GiniImageDocument {
            showCaptureSuggestions(giniConfiguration: giniConfiguration)
        }

        addErrorView()
    }

    /**
     Shows an error when there was an error with either the analysis or document upload
     */
    public func showError(with message: String, action: @escaping () -> Void ) {
        trackingDelegate?.onAnalysisScreenEvent(event: Event(type: .error, info: ["message": message]))

        errorView.isHidden = false
        errorView.textLabel.text = message
        errorView.userAction = NoticeAction(title: NoticeActionType.retry.title, action: { [weak self] in
            guard let self = self else { return }
            self.trackingDelegate?.onAnalysisScreenEvent(event: Event(type: .retry))
            self.errorView.hide(true, completion: action)
        })
        errorView.show()
    }

    /**
     Hide the error view
     */
    public func hideError(animated: Bool = false) {
        errorView.hide(animated, completion: nil)
        errorView.isHidden = true
    }

    private func addImageView() {
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        Constraints.active(item: imageView, attr: .top, relatedBy: .equal, to: view.safeAreaLayoutGuide, attr: .top,
                          priority: 999)
        Constraints.active(item: imageView, attr: .bottom, relatedBy: .equal, to: view.safeAreaLayoutGuide,
                           attr: .bottom, priority: 999)
        Constraints.active(item: imageView, attr: .centerX, relatedBy: .equal, to: view, attr: .centerX)
        Constraints.active(item: imageView, attr: .width, relatedBy: .equal, to: view, attr: .width, multiplier: 0.9)
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
        loadingIndicatorView.color = GiniColor(light: .GiniCapture.dark1, dark: .GiniCapture.light1).uiColor()

        addLoadingContainer()
        addLoadingView(intoContainer: loadingIndicatorContainer)

        if let loadingIndicator = giniConfiguration.analysisScreenLoadingIndicator {
            addLoadingText(below: loadingIndicator.injectedView())
            loadingIndicator.startAnimation()
        } else {
            addLoadingText(below: loadingIndicatorView)
            loadingIndicatorView.startAnimating()
        }
    }

    private func addLoadingText(below loadingIndicator: UIView) {
        loadingIndicatorContainer.addSubview(loadingIndicatorText)
        loadingIndicatorText.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            loadingIndicatorText.topAnchor.constraint(equalTo: loadingIndicator.bottomAnchor, constant: 16),
            loadingIndicatorText.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            loadingIndicatorText.centerXAnchor.constraint(equalTo: imageView.centerXAnchor)])
    }

    private func addLoadingView(intoContainer container: UIView? = nil) {
        let loadingIndicator: UIView

        if let customLoadingIndicator = giniConfiguration.analysisScreenLoadingIndicator?.injectedView() {
            loadingIndicator = customLoadingIndicator
        } else {
            loadingIndicator = loadingIndicatorView
        }

        if let container = container {
            container.translatesAutoresizingMaskIntoConstraints = false
            loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(container)
            container.addSubview(loadingIndicator)

            NSLayoutConstraint.activate([
                container.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                container.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                container.heightAnchor.constraint(equalToConstant:
                                                    AnalysisViewController.loadingIndicatorContainerHeight),
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
            loadingIndicatorContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingIndicatorContainer.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor),
            loadingIndicatorContainer.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor,
                                                               constant: 16)])
    }

    private func addErrorView() {
        view.addSubview(errorView)
        errorView.isHidden = true

        Constraints.pin(view: errorView, toSuperView: view, positions: [.left, .right, .top])
    }

    private func showCaptureSuggestions(giniConfiguration: GiniConfiguration) {
        let captureSuggestions = CaptureSuggestionsView(superView: view,
                                                        bottomAnchor: view.safeAreaLayoutGuide.bottomAnchor)
        captureSuggestions.start()
    }
}
