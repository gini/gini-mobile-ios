//
//  EmptyStackView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit

class EmptyStackView: UIStackView {
    init(orientation: NSLayoutConstraint.Axis) {
        super.init(frame: .zero)
        self.axis = orientation
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
