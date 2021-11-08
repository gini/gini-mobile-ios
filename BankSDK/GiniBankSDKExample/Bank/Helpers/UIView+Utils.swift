//
//  UIView+Utils.swift
//  Bank
//
//  Created by Nadya Karaban on 04.05.21.
//

import Foundation
import UIKit
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
