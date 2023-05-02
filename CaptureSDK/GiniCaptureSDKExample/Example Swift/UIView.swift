//
//  UIView.swift
//  GiniCaptureSDKExample
//
//  Created by David Vizaknai on 06.02.2023.
//  Copyright © 2023 Gini GmbH. All rights reserved.
//

import UIKit

extension UIView {
    /** Loads instance from nib with the same name. */
    func loadNib() -> UIView {
        let nibName = type(of: self).description().components(separatedBy: ".").last!
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! UIView
    }
}
