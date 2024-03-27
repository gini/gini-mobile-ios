//
//  UIView+Utils.swift
//  GiniHealth
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

// MARK: - Adds round corners to any UIView, configurable with UIRectCorner, radius

public extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        if #available(iOS 11, *) {
            self.clipsToBounds = true
            self.layer.cornerRadius = radius
            var masked = CACornerMask()
            if corners.contains(.topLeft) { masked.insert(.layerMinXMinYCorner) }
            if corners.contains(.topRight) { masked.insert(.layerMaxXMinYCorner) }
            if corners.contains(.bottomLeft) { masked.insert(.layerMinXMaxYCorner) }
            if corners.contains(.bottomRight) { masked.insert(.layerMaxXMaxYCorner) }
            self.layer.maskedCorners = masked
        } else {
            let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            layer.mask = mask
        }
    }
}

// MARK: - Adds loading indicator to any UIView, configurable with UIActivityIndicatorView.Style, color and scale

public extension UIView {
    func showLoading(style: UIActivityIndicatorView.Style? = .whiteLarge, color: UIColor? = .orange, scale: CGFloat? = 1.0) {
        let loading = UIActivityIndicatorView(style: style ?? .whiteLarge)
        if let color = color {
            loading.color = color
        }
        loading.contentScaleFactor = scale ?? 1.0
        loading.translatesAutoresizingMaskIntoConstraints = false
        loading.startAnimating()
        loading.hidesWhenStopped = true
        addSubview(loading)
        loading.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        loading.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }

    func stopLoading() {
        removeActivityIndicator()
    }
    
    func removeActivityIndicator() {
        let activityIndicators = subviews.filter { $0 is UIActivityIndicatorView } as? [UIActivityIndicatorView]
        
        activityIndicators?.forEach { activityIndicator in
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
        }
    }
}

// MARK: - Adds Blur effect to any UIView, configurable with UIBlurEffect.Style

public extension UIView {
    func applyBlurEffect(style: UIBlurEffect.Style? = .regular) {
        let blurEffect = UIBlurEffect(style: style ?? .regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurEffectView)
    }

    func removeBlurEffect() {
        let blurredEffectViews = subviews.filter { $0 is UIVisualEffectView }
        blurredEffectViews.forEach { blurView in
            blurView.removeFromSuperview()
        }
    }
}
