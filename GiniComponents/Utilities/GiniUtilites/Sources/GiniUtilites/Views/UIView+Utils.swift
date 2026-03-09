//
//  UIView+Utils.swift
//  GiniUtilites
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

// MARK: - Adds round corners to any UIView, configurable with UIRectCorner, radius

extension UIView {
    public func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        self.clipsToBounds = true
        self.layer.cornerRadius = radius
        var masked = CACornerMask()
        if corners.contains(.topLeft) {
            masked.insert(.layerMinXMinYCorner)
        }
        if corners.contains(.topRight) {
            masked.insert(.layerMaxXMinYCorner)
        }
        if corners.contains(.bottomLeft) {
            masked.insert(.layerMinXMaxYCorner)
        }
        if corners.contains(.bottomRight) {
            masked.insert(.layerMaxXMaxYCorner)
        }
        self.layer.maskedCorners = masked
    }
}

// MARK: - Adds loading indicator to any UIView, configurable with UIActivityIndicatorView.Style, color and scale

public extension UIView {
    func showLoading(style: UIActivityIndicatorView.Style = .large, color: UIColor? = .orange, scale: CGFloat? = 1.0) {
        let loading = UIActivityIndicatorView(style: style)
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
