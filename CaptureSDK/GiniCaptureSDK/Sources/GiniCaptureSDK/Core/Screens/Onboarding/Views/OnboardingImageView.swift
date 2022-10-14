//
//  OnboardingImageView.swift
//  GiniCapture
//  Created by Nadya Karaban on 08.06.22.
//

import UIKit

class ImageOnboardingIllustrationAdapter: OnboardingIllustrationAdapter {
    func pageDidAppear() {
    }

    func pageDidDisappear() {
    }

    func injectedView() -> UIView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    func onDeinit() {
    }
}

class OnboardingImageView: UIView {
    var illustrationAdapter: OnboardingIllustrationAdapter?
    var icon: UIImage? {
        didSet {
            // Remove the previous container with an illustration because we dequeue reusable cells
            setupView()
        }
    }
    private let injectedViewTag = 1010

// MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setupView() {
        if viewWithTag(injectedViewTag) == nil, let containerView = illustrationAdapter?.injectedView() {
            if let imageView = containerView as? UIImageView {
                imageView.image = icon
            }
            containerView.tag = injectedViewTag
            containerView.fixInView(self)
        }
    }
}
