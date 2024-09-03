//
//  EmptyStackView.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit

public class EmptyStackView: UIStackView {
    public init() {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EmptyStackView {
    @discardableResult
    public func spacing(_ spacing: CGFloat) -> EmptyStackView {
        self.spacing = spacing
        return self
    }

    @discardableResult
    public func orientation(_ orientation: NSLayoutConstraint.Axis) -> EmptyStackView {
        self.axis = orientation
        return self
    }

    @discardableResult
    public func distribution(_ distribution: UIStackView.Distribution) -> EmptyStackView {
        self.distribution = distribution
        return self
    }
}

