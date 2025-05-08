//
//  UIView+LoadNib.swift
//  GiniBankSDKExample
//
//  Created by Valentina Iancu on 23.06.23.
//

import UIKit

extension UIView {
	/** Loads instance from nib with the same name. */
	func loadNib() -> UIView {
		let nibName = type(of: self).description().components(separatedBy: ".").last!
		let nib = UINib(nibName: nibName, bundle: nil)
		return nib.instantiate(withOwner: self, options: nil).first as! UIView
	}
    
    var currentInterfaceOrientation: UIInterfaceOrientation {
        if #available(iOS 13, *) {
            return window?.windowScene?.interfaceOrientation ?? UIApplication.shared.statusBarOrientation
        } else {
            return UIApplication.shared.statusBarOrientation
        }
    }
}
