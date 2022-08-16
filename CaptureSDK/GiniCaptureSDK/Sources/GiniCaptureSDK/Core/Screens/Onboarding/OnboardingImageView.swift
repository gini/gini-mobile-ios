//
//  OnboardingImageView.swift
//  GiniCapture
//  Created by Nadya Karaban on 08.06.22.
//

import UIKit

class OnboardingImageView: UIView, OnboardingIllustrationAdapter {
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
    
        // Performs the initial setup.
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
        return nib.instantiate(withOwner: self, options: nil).first as! UIView
    }
}

extension UIView
{
    func fixInView(_ container: UIView!) -> Void{
        self.translatesAutoresizingMaskIntoConstraints = false
        self.frame = container.frame
        container.addSubview(self)
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
}
