//
//  AccessibleView.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//


import UIKit

public class AccessibleView: UIView {

    public override var canBecomeFocused: Bool {
        true
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
