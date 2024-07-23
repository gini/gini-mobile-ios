//
//  EmptyStackView.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit

class EmptyStackView: UIStackView {
    init(orientation: NSLayoutConstraint.Axis, distribution: UIStackView.Distribution? = nil, spacing: CGFloat? = nil) {
        super.init(frame: .zero)
        self.axis = orientation
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
        if let spacing = spacing {
            self.spacing = spacing
        }
        if let distribution = distribution {
            self.distribution = distribution
        }
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
