//
//  PageControlWithTap.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//


import UIKit

class PageControlWithTap: UIPageControl {

    private(set) var tappedPage: Int = 0
    private let dotSize: CGFloat = 7.0
    private let dotSpacing: CGFloat = 8.0
    private var startX: CGFloat = 0

    override func layoutSubviews() {
        super.layoutSubviews()
        calculateStartX()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let centerY = bounds.height / 2.0
        
        var closestDotIndex: Int? = nil
        var closestDistance: CGFloat = .greatestFiniteMagnitude

        
        for i in 0..<numberOfPages {
            let x = startX + CGFloat(i) * (dotSize + dotSpacing)
            let dotFrame = CGRect(x: x, y: centerY - dotSize / 2, width: dotSize, height: dotSize)

            // Calculate the center of the dot
            let dotCenter = CGPoint(x: dotFrame.midX, y: dotFrame.midY)

            // Calculate the distance from the touch location to the dot's center
            let distance = sqrt(pow(location.x - dotCenter.x, 2) + pow(location.y - dotCenter.y, 2))

            // If this dot is closer than the previous closest dot, update closest dot info
            if distance < closestDistance {
                closestDistance = distance
                closestDotIndex = i
            }
        }
        
        if let closestDotIndex = closestDotIndex {
            tappedPage = closestDotIndex
            if currentPage != closestDotIndex {
                currentPage = closestDotIndex
                sendActions(for: .valueChanged)
            }
        }
    }
    
    private func calculateStartX() {
        let totalWidth = CGFloat(numberOfPages) * dotSize + CGFloat(numberOfPages - 1) * dotSpacing
        startX = (bounds.width - totalWidth) / 2.0
    }

}
