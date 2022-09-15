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
        let containerView = UIView()
        return containerView
    }
    func onDeinit() {
    }
}

class OnboardingImageView: UIView {
var illustrationAdapter: OnboardingIllustrationAdapter?
    var icon: UIImage? {
        didSet {
            //Remove the previous container with an illustration because we dequeue reusable cells
            self.subviews.forEach({ $0.removeFromSuperview() })
            setupView()
        }
    }

// MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
// MARK: - Private Helper Methods
    private func setupView() {
        if let image = icon {
            let imageView = UIImageView()
            imageView.image = image
            imageView.center = CGPoint(x: self.frame.size.width / 2,
                                                   y: self.frame.size.height / 2)
            imageView.contentMode = .scaleAspectFit
            self.addSubview(imageView)
            imageView.fixInView(self)
        } else {
            if let containerView = illustrationAdapter?.injectedView() {
                self.addSubview(containerView)
            }
        }
    }
}


