//
//  OnboardingImageView.swift
//  GiniCapture
//  Created by Nadya Karaban on 08.06.22.
//

import UIKit

class OnboardingImageView: UIView, OnboardingIllustrationAdapter {
    func onDeinit() {
    }
    func pageDidAppear() {
    }
    func pageDidDisappear() {
    }
    func injectedView() -> UIView {
        self
    }
    var icon: UIImage? {
        didSet {
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

                imageView.contentMode = .scaleAspectFit

                imageView.center = CGPoint(x: self.frame.size.width / 2,

                                           y: self.frame.size.height / 2)
                imageView.fixInView(self)

            }

        }
}

extension UIView {
    func viewFromNibForClass() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nibName = type(of: self).description().components(separatedBy: ".").last!
        let nib = UINib(nibName: nibName, bundle: bundle)
        guard let view = nib.instantiate(withOwner: self, options: nil).first, view is UIView else {
            fatalError("View initializing with nib failed while casting")
        }
        return view as? UIView ?? UIView()
    }
}

extension UIView {
    func fixInView(_ container: UIView!) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.frame = container.frame
        container.addSubview(self)
        let leadingConstraint = self.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 0)
        let trailingConstraint = self.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: 0)
        let topConstraint = self.topAnchor.constraint(equalTo: container.topAnchor, constant: 0)
        let bottomConstraint = self.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 0)
        NSLayoutConstraint.activate([leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
    }
}
