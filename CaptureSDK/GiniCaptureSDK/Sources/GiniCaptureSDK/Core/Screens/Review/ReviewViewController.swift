//
//  ReviewViewController.swift
//  GiniCapture
//
//  Created by Peter Pult on 20/06/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import UIKit

/**
 The ReviewViewControllerDelegate protocol defines methods that allow you to manage when a user rotates an image.
 
 - note: Component API only.
 */
@objc public protocol ReviewViewControllerDelegate: AnyObject {
    func review(_ viewController: ReviewViewController, didReview document: GiniCaptureDocument)
}

/**
 The `ReviewViewController` provides a custom review screen. The user has the option to check
 for blurriness and document orientation. If the result is not satisfying, the user can either
 return to the camera screen or rotate the photo by steps of 90 degrees. The photo should be
 uploaded to Gini’s backend immediately after having been taken as it is safe to assume that
 in most cases the photo is good enough to be processed further.
 
 - note: Component API only.
 */
@objcMembers public final class ReviewViewController: UIViewController {
    
    /**
     The object that acts as the delegate of the review view controller.
     */
    public weak var delegate: ReviewViewControllerDelegate?
    
    // User interface
    fileprivate lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTapGesture.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGesture)

        return scrollView
    }()
    
    fileprivate var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.accessibilityLabel = .localized(resource: ReviewStrings.documentImageTitle)
        return imageView
    }()
    
    fileprivate var topView: UIView = {
        let topView = NoticeView(text: .localized(resource: ReviewStrings.topText))
        topView.translatesAutoresizingMaskIntoConstraints = false
       return topView
    }()
    
    fileprivate var bottomView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = GiniConfiguration.shared
            .reviewBottomViewBackgroundColor
            .withAlphaComponent(0.8)
        return view
    }()
    
    lazy var rotateButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(rotate), for: .touchUpInside)
        button.accessibilityLabel = .localized(resource: ReviewStrings.rotateButton)

        return button
    }()
    
    fileprivate lazy var bottomLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = .localized(resource: ReviewStrings.bottomText)
        label.numberOfLines = 0
        label.textColor = giniConfiguration.reviewTextBottomColor
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.font = giniConfiguration.customFont.isEnabled ?
            giniConfiguration.customFont.with(weight: .thin, size: 12, style: .footnote) :
            giniConfiguration.reviewTextBottomFont
        return label
    }()
    
    // Properties
    fileprivate var imageViewBottomConstraint: NSLayoutConstraint!
    fileprivate var imageViewLeadingConstraint: NSLayoutConstraint!
    fileprivate var imageViewTopConstraint: NSLayoutConstraint!
    fileprivate var imageViewTrailingConstraint: NSLayoutConstraint!
    fileprivate var currentDocument: GiniCaptureDocument?
    fileprivate var giniConfiguration: GiniConfiguration
    
    // Images
    fileprivate var rotateButtonImage: UIImage? {
        return UIImageNamedPreferred(named: "reviewRotateButton")
    }
    
    /**
     Designated initializer for ReviewViewController
     
     - parameter document: Document to be reviewed
     - paramter giniConfiguration: `GiniConfiguration`
     
     - note: Component API only.
     */
    public init(document: GiniCaptureDocument, giniConfiguration: GiniConfiguration) {
        self.giniConfiguration = giniConfiguration
        self.currentDocument = document
        super.init(nibName: nil, bundle: nil)
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
        edgesForExtendedLayout = []
        view.backgroundColor = .black

        scrollView.delegate = self
        imageView.image = currentDocument?.previewImage
        rotateButton.setImage(rotateButtonImage, for: .normal)
        
        // Configure view hierachy
        view.addSubview(scrollView)
        view.addSubview(topView)
        view.addSubview(bottomView)
        scrollView.addSubview(imageView)
        bottomView.addSubview(rotateButton)
        bottomView.addSubview(bottomLabel)
        
        addConstraints()
        view.layoutIfNeeded()
    }
    
    /**
     Called to notify the view controller that its view has just laid out its subviews.
     */
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateMinZoomScaleForSize(scrollView.bounds.size)
        
        // On initialization imageView's frame is (0,0) so the image needs to be centered
        // inside the ScrollView when its size has changed
        self.updateConstraintsForSize(scrollView.bounds.size)
    }
        
    /**
     Notifies the view controller that its view was added to a view hierarchy.
     
     - parameter animated: If true, the view was added to the window using an animation.
     */
    public override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            (self.topView as? NoticeView)?.show()
        }
    }
    
    private func didReview(_ imageDocument: GiniImageDocument) {
        if let delegate = delegate {
            delegate.review(self, didReview: imageDocument)
        } else {
            assertionFailure("The ReviewViewControllerDelegate has not been assigned")
        }
    }
    
    // MARK: Rotation handling
    @objc fileprivate func rotate(_ sender: AnyObject) {
        guard let rotatedImage = imageView.image?.rotated90Degrees() else { return }
        guard let imageDocument = currentDocument as? GiniImageDocument else { return }
        
        imageView.image = rotatedImage
        imageDocument.rotatePreviewImage90Degrees()
        didReview(imageDocument)
    }
    
    // MARK: Zoom handling
    @objc fileprivate func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        if scrollView.zoomScale > scrollView.minimumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        }
    }
    
    fileprivate func updateMinZoomScaleForSize(_ size: CGSize) {
        guard let image = imageView.image else { return }
        let widthScale = size.width / image.size.width
        let heightScale = size.height / image.size.height
        let minScale = min(widthScale, heightScale)
        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale
    }
    
    fileprivate func updateConstraintsForSize(_ size: CGSize) {
        let yOffset = max(0, (size.height - imageView.frame.height) / 2)
        imageViewTopConstraint.constant = yOffset
        imageViewBottomConstraint.constant = yOffset
        let xOffset = max(0, (size.width - imageView.frame.width) / 2)
        imageViewLeadingConstraint.constant = xOffset
        imageViewTrailingConstraint.constant = xOffset
        
        view.layoutIfNeeded()
    }
    
    // MARK: Constraints
    fileprivate func addConstraints() {
        // Scroll view
        Constraints.active(item: scrollView, attr: .top, relatedBy: .equal, to: topLayoutGuide, attr: .bottom)
        Constraints.active(item: scrollView, attr: .trailing, relatedBy: .equal, to: view, attr: .trailing)
        Constraints.active(item: scrollView, attr: .bottom, relatedBy: .equal, to: bottomLayoutGuide, attr: .top)
        Constraints.active(item: scrollView, attr: .leading, relatedBy: .equal, to: view, attr: .leading)
        
        // Image view
        imageViewTopConstraint = NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal,
                                                    toItem: scrollView, attribute: .top, multiplier: 1, constant: 0)
        imageViewTrailingConstraint = NSLayoutConstraint(item: imageView, attribute: .trailing, relatedBy: .equal,
                                                         toItem: scrollView, attribute: .trailing, multiplier: 1,
                                                         constant: 0)
        imageViewBottomConstraint = NSLayoutConstraint(item: imageView, attribute: .bottom, relatedBy: .equal,
                                                       toItem: scrollView, attribute: .bottom, multiplier: 1,
                                                       constant: 0)
        imageViewLeadingConstraint = NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal,
                                                        toItem: scrollView, attribute: .leading, multiplier: 1,
                                                        constant: 0)
        Constraints.active(constraint: imageViewTopConstraint)
        Constraints.active(constraint: imageViewTrailingConstraint)
        Constraints.active(constraint: imageViewBottomConstraint)
        Constraints.active(constraint: imageViewLeadingConstraint)
        
        // Top view
        Constraints.pin(view: topView, toSuperView: view, positions: [.top, .left, .right])
        
        // Bottom view
        Constraints.active(item: bottomView, attr: .top, relatedBy: .equal, to: scrollView, attr: .bottom,
                           priority: 750)
        Constraints.active(item: bottomView, attr: .trailing, relatedBy: .equal, to: view, attr: .trailing)
        Constraints.active(item: bottomView, attr: .bottom, relatedBy: .equal, to: self.bottomLayoutGuide, attr: .top)
        Constraints.active(item: bottomView, attr: .leading, relatedBy: .equal, to: view, attr: .leading)
        
        // Rotate button
        Constraints.active(item: rotateButton, attr: .leading, relatedBy: .equal, to: bottomView, attr: .leading,
                          constant: 15)
        Constraints.active(item: rotateButton, attr: .width, relatedBy: .equal, to: nil, attr: .width, constant: 33)
        Constraints.active(item: rotateButton, attr: .height, relatedBy: .equal, to: nil, attr: .height, constant: 33)
        Constraints.active(item: rotateButton, attr: .centerY, relatedBy: .equal, to: bottomView, attr: .centerY)
        Constraints.active(item: rotateButton, attr: .top, relatedBy: .equal, to: bottomView, attr: .top, constant: 10)
        Constraints.active(item: rotateButton, attr: .bottom, relatedBy: .equal, to: bottomView, attr: .bottom,
                          constant: -10)

        // Bottom label
        Constraints.active(item: bottomLabel, attr: .trailing, relatedBy: .equal, to: bottomView, attr: .trailing,
                          constant: -20)
        Constraints.active(item: bottomLabel, attr: .leading, relatedBy: .equal, to: rotateButton, attr: .trailing,
                          constant: 30, priority: 999)
        Constraints.active(item: bottomLabel, attr: .height, relatedBy: .equal, to: nil, attr: .height, constant: 33)
        Constraints.active(item: bottomLabel, attr: .centerY, relatedBy: .equal, to: bottomView, attr: .centerY)
    }
    
}

extension ReviewViewController: UIScrollViewDelegate {
    
    /**
     Asks the delegate for the view to scale when zooming is about to occur in the scroll view.
     
     - parameter scrollView: The scroll view object displaying the content view.
     - returns: A `UIView` object that will be scaled as a result of the zooming gesture.
     */
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    /**
     Informs the delegate that the scroll view’s zoom factor has changed.
     
     - parameter scrollView: The scroll-view object whose zoom factor has changed.
     */
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        DispatchQueue.main.async {
            self.updateConstraintsForSize(scrollView.bounds.size)
        }
    }
    
}

