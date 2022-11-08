//
//  UIView.swift
//  GiniBankSDKExample
//
//  Created by Krzysztof Kryniecki on 27/10/2022.
//

import Foundation
import UIKit

extension UIView {
    /** Loads instance from nib with the same name. */
    func loadNib() -> UIView {
        let nibName = type(of: self).description().components(separatedBy: ".").last!
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! UIView
    }
}
