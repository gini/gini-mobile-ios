//
//  GiniZoomableImageViewCoordinator.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import UIKit

/**
 A coordinator object that manages the zooming behavior of a `GiniZoomableImageView`.
 
 This coordinator acts as the `UIScrollViewDelegate` for the scroll view contained within
 a `GiniZoomableImageView`. It handles zoom interactions and ensures the image view
 remains centered within the scroll view during zoom operations.
 
 The coordinator is responsible for:
 - Specifying which view should be zoomed within the scroll view
 - Centering the image view when the user zooms in or out
 - Calculating appropriate offsets to maintain visual balance
 
 - Note: This class is marked as `final` and cannot be subclassed.
 */
final class GiniZoomableImageViewCoordinator: NSObject, UIScrollViewDelegate {
    
    private let parent: GiniZoomableImageView
    
    init(_ parent: GiniZoomableImageView) {
        self.parent = parent
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        (scrollView as? GiniZoomableScrollView)?.imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        guard let zoomableScrollView = scrollView as? GiniZoomableScrollView,
              let imageView = zoomableScrollView.imageView else { return }
        
        /// Center imageView when zoomed
        let widthDifference = scrollView.bounds.width - scrollView.contentSize.width
        let heightDifference = scrollView.bounds.height - scrollView.contentSize.height
        
        let offsetX = max(widthDifference * Constants.valueToMultiplyWhenCentering, 0)
        let offsetY = max(heightDifference * Constants.valueToMultiplyWhenCentering, 0)
        
        imageView.center = CGPoint(x: scrollView.contentSize.width * Constants.valueToMultiplyWhenCentering + offsetX,
                                   y: scrollView.contentSize.height * Constants.valueToMultiplyWhenCentering + offsetY)
    }
    
    // MARK: - Constants
    private struct Constants {
        static let valueToMultiplyWhenCentering = 0.5
    }
}
