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
    var illustrationAdapter: OnboardingIllustrationAdapter? {
        didSet {
            setupView()
        }
    }
    var icon: UIImage? {
        didSet {
            // Remove the previous container with an illustration because we dequeue reusable cells
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
        self.subviews.forEach({ $0.removeFromSuperview() })
        if let image = icon {
            let imageView = UIImageView()
            imageView.image = image
            imageView.contentMode = .scaleAspectFit
            imageView.fixInView(self)
        } else {
            if let containerView = illustrationAdapter?.injectedView() {
                containerView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
                containerView.backgroundColor = .purple
                self.addSubview(containerView)
            }
        }
    }
}
