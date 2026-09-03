//
//  OnboardingImageView.swift
//  GiniCapture
//  Created by Nadya Karaban on 08.06.22.
//

import UIKit

/**
The ImageOnboardingIllustrationAdapter class implements the OnboardingIllustrationAdapter protocol to provide an image-based illustration for an onboarding view.
*/

public class ImageOnboardingIllustrationAdapter: OnboardingIllustrationAdapter {
    /**
     Called when the onboarding page appears.
     */
    public func pageDidAppear() {
        // This method will remain empty; no implementation is needed.
    }

    /**
     Called when the onboarding page disappears.
     */
    public func pageDidDisappear() {
        // This method will remain empty; no implementation is needed.
    }

    /**
     Returns a UIImageView instance to be used as the illustration for the onboarding view.

     - Returns: A UIImageView instance.
     */
    public func injectedView() -> UIView {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    /**
     Initializes and returns a newly allocated ImageOnboardingIllustrationAdapter object.
     */
    public init() {
        // This initializer is intentionally left empty because no custom setup is required at initialization.
    }

    /**
     Called when the ImageOnboardingIllustrationAdapter object is deallocated.
     */
    public func onDeinit() {
        // This method will remain empty; no implementation is needed.
    }
}

/**
The OnboardingImageView class represents a custom UIView used for displaying onboarding illustrations.
*/

public class OnboardingImageView: UIView {
    /** The object responsible for providing the illustration to be displayed in the view. */
    public var illustrationAdapter: OnboardingIllustrationAdapter?

    /** The icon to be displayed in the view.*/
    public var icon: UIImage? {
        didSet {
            let imageView = UIImageView()
            imageView.image = icon
            imageView.contentMode = .scaleAspectFit
            imageView.fixInView(self)
        }
    }

    private let injectedViewTag = 1010

// MARK: - Initializers

    /**
     Initializes and returns a newly allocated OnboardingImageView object with the specified frame rectangle.

     - Parameter frame: The frame rectangle for the view.
     */
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    /**
     Sets up the view by adding an imageView to the view hierarchy.
     */
    public func setupView() {
        // add injected view if it wasn't added before
        if viewWithTag(injectedViewTag) == nil, let containerView = illustrationAdapter?.injectedView() {
            containerView.tag = injectedViewTag
            containerView.fixInView(self)
        }
    }
}
