//
//  EmptyView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit

class EmptyView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
