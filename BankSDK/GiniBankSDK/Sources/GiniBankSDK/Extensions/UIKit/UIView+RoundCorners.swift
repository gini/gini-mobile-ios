//
//  UIView+RoundCorners.swift
//  
//
//  Created by Valentina Iancu on 30.06.23.
//

import UIKit

extension UIView {
	func round(corners: UIRectCorner = [UIRectCorner.allCorners], radius: CGFloat) {
		layer.maskedCorners = CACornerMask(rawValue: corners.rawValue)
		layer.cornerRadius = radius
		layer.masksToBounds = radius != 0
		clipsToBounds = radius != 0
	}
}
