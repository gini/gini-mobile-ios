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
            roundedRect: self.bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius))
        let shape = CAShapeLayer()
        shape.frame = self.bounds
        shape.path = mask.cgPath
        self.layer.mask = shape
        self.clipsToBounds = true
    }
}

public struct GiniMargins {
    public static let iPadHorizontalMargin: CGFloat = 126
    public static let margin: CGFloat = 16
    public static var horizontalMargin: CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return Self.iPadHorizontalMargin
        }
        return Self.margin
    }
    public static let fixediPadWidth: CGFloat = 559
}

extension UIButton {
    func addBlurEffect(cornerRadius: CGFloat) {
        backgroundColor = .clear
        let effect: UIBlurEffect
        effect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: effect)
        blurView.isUserInteractionEnabled = false
        blurView.backgroundColor = .clear
        if cornerRadius > 0 {
            blurView.layer.cornerRadius = cornerRadius
            blurView.layer.masksToBounds = true
        }
        insertSubview(blurView, at: 0)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        leadingAnchor.constraint(equalTo: blurView.leadingAnchor, constant: 0).isActive = true
        trailingAnchor.constraint(equalTo: blurView.trailingAnchor, constant: -0).isActive = true
        topAnchor.constraint(equalTo: blurView.topAnchor, constant: 0).isActive = true
        bottomAnchor.constraint(equalTo: blurView.bottomAnchor, constant: -0).isActive = true
        if let imageView = self.imageView {
            imageView.backgroundColor = .clear
            bringSubviewToFront(imageView)
        }
    }
}
