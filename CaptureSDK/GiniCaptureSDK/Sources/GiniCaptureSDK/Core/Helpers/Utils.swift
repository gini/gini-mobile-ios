//
//  Utils.swift
//  
//
//  Created by Krzysztof Kryniecki on 01/08/2022.
//

import UIKit

extension UITableViewCell {
    func round(corners: UIRectCorner, withRadius radius: CGFloat) {
        let mask = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius))
        let shape = CAShapeLayer()
        shape.frame = bounds
        shape.path = mask.cgPath
        layer.mask = shape
        clipsToBounds = true
    }
}

public struct GiniMargins {
    public static let margin: CGFloat = 16
    public static let iPadAspectScale: CGFloat = 0.7
}
