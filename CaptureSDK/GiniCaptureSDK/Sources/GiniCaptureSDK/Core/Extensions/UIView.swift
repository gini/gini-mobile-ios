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
}
