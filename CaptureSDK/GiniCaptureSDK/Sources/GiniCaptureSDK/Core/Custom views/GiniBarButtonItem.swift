//
//  GiniBarButtonItem.swift
//  GiniCapture
//
//  Created by Peter Pult on 13/07/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import UIKit

public final class GiniBarButtonItem: UIBarButtonItem {
    
    public init(image: UIImage?, title: String?, style: UIBarButtonItem.Style, target: AnyObject?, action: Selector) {
        super.init()
        
        let button = UIButton(type: .system)
        
        if let image = image {
            button.setImage(image, for: .normal)
        }
        
        if let title = title {
            let font = GiniConfiguration.shared.navigationBarItemFont
            let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font]
            button.setAttributedTitle(NSAttributedString(string: title, attributes: attributes), for: .normal)
        }
                
        button.sizeToFit()
        
        button.imageEdgeInsets = UIEdgeInsets(top: button.imageEdgeInsets.top,
                                              left: button.imageEdgeInsets.left - 10,
                                              bottom: button.imageEdgeInsets.bottom,
                                              right: button.imageEdgeInsets.right)
        
        button.addTarget(target, action: action, for: .touchUpInside)
        button.titleLabel?.textColor = GiniConfiguration.shared.navigationBarItemTintColor
        button.titleLabel?.tintColor = GiniConfiguration.shared.navigationBarItemTintColor
                      
        customView = button
        
        self.style = style
        
        // Set accessibility label on all elements
        self.accessibilityLabel = title
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
