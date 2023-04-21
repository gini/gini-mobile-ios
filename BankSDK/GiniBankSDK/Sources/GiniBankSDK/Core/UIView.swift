//
//  UIView.swift
//  
//
//  Created by David Vizaknai on 22.02.2023.
//

import UIKit

// swiftlint:disable force_cast
extension UIView {
    /** Loads instance from nib with the same name. */
    func loadNib() -> UIView {
        let bundle = giniBankBundle()
        let nibName = type(of: self).description().components(separatedBy: ".").last!
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as! UIView
    }
}
