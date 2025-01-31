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

    func reset() {
        layer.mask = nil
        clipsToBounds = true
    }
}

public struct GiniMargins {
    public static let margin: CGFloat = 16
    public static let marginHorizontal: CGFloat = 56
    public static let iPadAspectScale: CGFloat = 0.7
}

extension UIButton {
    func addBlurEffect(cornerRadius: CGFloat) {
        backgroundColor = .clear
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurView.isUserInteractionEnabled = false
        blurView.backgroundColor = .clear
        if cornerRadius > 0 {
            blurView.layer.cornerRadius = cornerRadius
            blurView.layer.masksToBounds = true
        }
        insertSubview(blurView, at: 0)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        leadingAnchor.constraint(equalTo: blurView.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: blurView.trailingAnchor, constant: -0).isActive = true
        topAnchor.constraint(equalTo: blurView.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: blurView.bottomAnchor).isActive = true
        if let imageView = imageView {
            imageView.backgroundColor = .clear
            bringSubviewToFront(imageView)
        }
    }

    func removeBlurEffect() {
        let effectView = self.subviews.first(where: { $0 is UIVisualEffectView })
        effectView?.removeFromSuperview()
    }
}
