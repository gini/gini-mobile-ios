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
     
     - returns: `true` if the screen was shown or `false` if it wasn't.
     */
    func tryDisplayNoResultsScreen() -> Bool
}

/**
 The `AnalysisViewController` provides a custom analysis screen which shows the upload and analysis activity.
 The user should have the option of canceling the process by navigating back to the review screen.
 
 - note: Component API only.
 */
@objcMembers public final class AnalysisViewController: UIViewController {
    
    var didShowAnalysis: (() -> Void)?
    fileprivate let document: GiniCaptureDocument
    fileprivate let giniConfiguration: GiniConfiguration
    fileprivate static let loadingIndicatorContainerHeight: CGFloat = 60
    
    public weak var trackingDelegate: AnalysisScreenTrackingDelegate?

    
    // User interface
    fileprivate var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    fileprivate var loadingIndicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView()
        indicatorView.hidesWhenStopped = true
        indicatorView.style = .whiteLarge
        indicatorView.startAnimating()
        return indicatorView
    }()
    
    fileprivate lazy var loadingIndicatorText: UILabel = {
        var loadingText = UILabel()
        loadingText.text = .localized(resource: AnalysisStrings.loadingText)
        loadingText.font = giniConfiguration.customFont.with(weight: .regular, size: 18, style: .body)
        loadingText.textAlignment = .center
        loadingText.textColor = .white
        return loadingText
    }()
    
    fileprivate lazy var loadingIndicatorContainer: UIView = {
        let size = CGSize(width: AnalysisViewController.loadingIndicatorContainerHeight,
                          height: AnalysisViewController.loadingIndicatorContainerHeight)
        let loadingIndicatorContainer = UIView(frame: CGRect(origin: .zero,
                                                             size: size))
        loadingIndicatorContainer.backgroundColor = .white
        loadingIndicatorContainer.layer.cornerRadius = AnalysisViewController.loadingIndicatorContainerHeight / 2
        return loadingIndicatorContainer
    }()
    
    fileprivate lazy var overlayView: UIView = {
        let overlayView = UIView()
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        return overlayView
    }()
    
    fileprivate lazy var errorView: NoticeView = {
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
    
    public override func loadView() {
        super.loadView()
        imageView.image = document.previewImage
        edgesForExtendedLayout = []
        view.backgroundColor = .black
        
        // Configure view hierachy
        addImageView()
        
        if let document = document as? GiniPDFDocument {
            addLoadingView(intoContainer: loadingIndicatorContainer)
            loadingIndicatorView.color = giniConfiguration.analysisLoadingIndicatorColor
            
            showPDFInformationView(withDocument: document,
                                   giniConfiguration: giniConfiguration)
        } else {
            addLoadingView()
            addLoadingText(below: loadingIndicatorView)
            addOverlay()
            
            if document.type == .image {
                showCaptureSuggestions(giniConfiguration: giniConfiguration)
            }
        }
        
        addErrorView()
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
        loadingIndicatorView.startAnimating()
    }
    
    /**
     Hides the loading activity indicator. Should be called when document analysis is finished.
     */
    public func hideAnimation() {
        loadingIndicatorView.stopAnimating()
    }
    
    /**
     Shows an error when there was an error with either the analysis or document upload
     */
    public func showError(with message: String, action: @escaping () -> Void ) {
        
        trackingDelegate?.onAnalysisScreenEvent(event: Event(type: .error, info: ["message" : message]))
        
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
    }
    
    fileprivate func addImageView() {
        self.view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        Constraints.active(item: imageView, attr: .top, relatedBy: .equal, to: view.safeAreaLayoutGuide, attr: .top,
                          priority: 999)
        Constraints.active(item: imageView, attr: .bottom, relatedBy: .equal, to: view.safeAreaLayoutGuide, attr: .bottom,
                          priority: 999)
        Constraints.active(item: imageView, attr: .trailing, relatedBy: .equal, to: self.view, attr: .trailing)
        Constraints.active(item: imageView, attr: .leading, relatedBy: .equal, to: self.view, attr: .leading)
    }
    
    fileprivate func addOverlay() {
        self.view.insertSubview(overlayView, aboveSubview: imageView)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        
        Constraints.active(item: overlayView, attr: .top, relatedBy: .equal, to: imageView, attr: .top)
        Constraints.active(item: overlayView, attr: .trailing, relatedBy: .equal, to: imageView, attr: .trailing)
        Constraints.active(item: overlayView, attr: .bottom, relatedBy: .equal, to: imageView, attr: .bottom)
        Constraints.active(item: overlayView, attr: .leading, relatedBy: .equal, to: imageView, attr: .leading)
    }
    
    fileprivate func addLoadingText(below: UIView) {
        self.view.addSubview(loadingIndicatorText)
        loadingIndicatorText.translatesAutoresizingMaskIntoConstraints = false
        
        Constraints.active(item: loadingIndicatorText, attr: .trailing, relatedBy: .equal, to: imageView,
                          attr: .trailing)
        Constraints.active(item: loadingIndicatorText, attr: .top, relatedBy: .equal, to: below, attr: .bottom,
                          constant: 16)
        Constraints.active(item: loadingIndicatorText, attr: .leading, relatedBy: .equal, to: imageView, attr: .leading)
    }
    
    fileprivate func addLoadingView(intoContainer container: UIView? = nil) {
        loadingIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        if let container = container {
            container.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(container)
            container.addSubview(loadingIndicatorView)
            
            Constraints.active(item: container, attr: .centerX, relatedBy: .equal, to: self.view, attr: .centerX)
            Constraints.active(item: container, attr: .centerY, relatedBy: .equal, to: self.view, attr: .centerY)
            Constraints.active(item: container, attr: .height, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                              constant: AnalysisViewController.loadingIndicatorContainerHeight)
            Constraints.active(item: container, attr: .width, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                              constant: AnalysisViewController.loadingIndicatorContainerHeight)
            Constraints.active(item: loadingIndicatorView, attr: .centerX, relatedBy: .equal, to: container,
                              attr: .centerX, constant: 1.5)
            Constraints.active(item: loadingIndicatorView, attr: .centerY, relatedBy: .equal, to: container,
                              attr: .centerY, constant: 1.5)
            
        } else {
            self.view.addSubview(loadingIndicatorView)
            Constraints.active(item: loadingIndicatorView, attr: .centerX, relatedBy: .equal, to: self.view,
                              attr: .centerX)
            Constraints.active(item: loadingIndicatorView, attr: .centerY, relatedBy: .equal, to: self.view,
                              attr: .centerY)
        }
    }
    
    fileprivate func addErrorView() {
        view.addSubview(errorView)
        
        Constraints.pin(view: errorView, toSuperView: view, positions: [.left, .right, .top])
    }
    
    fileprivate func showPDFInformationView(withDocument document: GiniPDFDocument,
                                            giniConfiguration: GiniConfiguration) {
        let title: String = document.pdfTitle ?? .localized(resource: AnalysisStrings.defaultPdfDokumentTitle)
        let pdfView = PDFInformationView(title: title,
                                         subtitle: .localized(resource: AnalysisStrings.pdfPages,
                                                              args: document.numberPages),
                                         textColor: giniConfiguration.analysisPDFInformationTextColor,
                                         textFont: giniConfiguration.customFont.with(weight: .regular,
                                                                                     size: 16,
                                                                                     style: .body),
                                         backgroundColor: giniConfiguration.analysisPDFInformationBackgroundColor,
                                         superView: self.view,
                                         viewBelow: self.imageView)
        
        pdfView.show()
    }
    
    fileprivate func showCaptureSuggestions(giniConfiguration: GiniConfiguration) {
        let captureSuggestions = CaptureSuggestionsView(superView: self.view,
                                                        bottomAnchor: view.safeAreaLayoutGuide.bottomAnchor,
                                                        font: giniConfiguration.customFont.with(weight: .regular,
                                                                                                size: 16,
                                                                                                style: .body))
        captureSuggestions.start()
    }
}
