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
    }

    /**
     Called when the onboarding page disappears.
     */
    public func pageDidDisappear() {
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
    public init() {}

    /**
     Called when the ImageOnboardingIllustrationAdapter object is deallocated.
     */
    public func onDeinit() {}
}

/**
The OnboardingImageView class represents a custom UIView used for displaying onboarding illustrations.
*/

public class OnboardingImageView: UIView {
    /** The object responsible for providing the illustration to be displayed in the view. */
    public var illustrationAdapter: OnboardingIllustrationAdapter?

    /** The icon to be displayed in the view. Setting this property automatically calls the `setupView()` method to update the view. */
    public var icon: UIImage? {
        didSet {
            setupView()
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
     Sets up the view by adding the injected view to the view hierarchy if it is not already present.
     If an injected view is present, its image is updated to reflect the current `icon` value.
     */
    public func setupView() {
        // add injected view if it wasn't already there
        if viewWithTag(injectedViewTag) == nil, let containerView = illustrationAdapter?.injectedView() {
            if let imageView = containerView as? UIImageView {
                imageView.image = icon
            }
            containerView.tag = injectedViewTag
            containerView.fixInView(self)
        }
    }
}
