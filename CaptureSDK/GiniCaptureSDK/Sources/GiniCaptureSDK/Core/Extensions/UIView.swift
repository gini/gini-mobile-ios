//
//  UIView.swift
//  GiniCapture
//
//  Created by Nadya Karaban on 20.08.21.
//

import UIKit
extension UIView {
    /** Loads instance from nib with the same name. */
    func loadNib() -> UIView {
        let bundle = giniCaptureBundle()
        let nibName = type(of: self).description().components(separatedBy: ".").last!
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as! UIView
    }

    func viewFromNibForClass() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nibName = type(of: self).description().components(separatedBy: ".").last!
        let nib = UINib(nibName: nibName, bundle: bundle)
        guard let view = nib.instantiate(withOwner: self, options: nil).first, view is UIView else {
            fatalError("View initializing with nib failed while casting")
        }
        return view as? UIView ?? UIView()
    }

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
