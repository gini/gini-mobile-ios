//
//  PageControlWithTap.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//


import UIKit

class PageControlWithTap: UIPageControl {

    private(set) var tappedPage: Int = 0

    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let centerY = bounds.height / 2.0
        
        for i in 0..<numberOfPages {
        }


    }

}
