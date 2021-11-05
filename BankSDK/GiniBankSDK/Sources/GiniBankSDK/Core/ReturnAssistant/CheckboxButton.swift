//
//  CheckboxButton.swift
// GiniBank
//
//  Created by Maciej Trybilo on 19.12.19.
//

import UIKit

class CheckboxButton: UIButton {
    
    // The appearance of the button in the designs is only 24x24 points, but the
    // recommended hit target is at least 44x44 points, so the following set up
    // makes the button larger than it appears.
    
    private static let size: CGFloat = 44
    static let margin: CGFloat = 10
    
    private let backgroundView = UIView(frame: CGRect(x: margin,
                                                      y: margin,
                                                      width: size - margin * 2,
                                                      height: size - margin * 2))
    enum CheckedState {
        case checked
        case unchecked
    }
    
    var checkedState: CheckedState = .checked {
        
        didSet {
            update()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        widthAnchor.constraint(equalToConstant: CheckboxButton.size).isActive = true
        heightAnchor.constraint(equalToConstant: CheckboxButton.size).isActive = true
    }
    
    private func setup() {
        
        backgroundView.layer.cornerRadius = 3
        backgroundView.layer.borderWidth = 1
        
        backgroundView.isUserInteractionEnabled = false
        if let imageView = imageView {
            insertSubview(backgroundView, belowSubview: imageView)
        }
    }
    
    private func update() {
        
        switch checkedState {
        case .checked:
            
            backgroundView.backgroundColor = tintColor
            backgroundView.layer.borderColor = UIColor.clear.cgColor
            
            setImage(UIImage(named: "checkmark", in: giniBankBundle(), compatibleWith: nil),
                     for: .normal)
            
            accessibilityLabel = .ginibankLocalized(resource: DigitalInvoiceStrings.checkmarkButtonDeselectAccessibilityLabel)
            
        case .unchecked:
            backgroundView.backgroundColor = .clear
            
            setImage(nil, for: .normal)
            
            if #available(iOS 13.0, *) {
                backgroundView.layer.borderColor = UIColor.secondaryLabel.cgColor
            } else {
                backgroundView.layer.borderColor = UIColor.gray.cgColor
            }
            
            accessibilityLabel = .ginibankLocalized(resource: DigitalInvoiceStrings.checkmarkButtonSelectAccessibilityLabel)
        }
    }
}
