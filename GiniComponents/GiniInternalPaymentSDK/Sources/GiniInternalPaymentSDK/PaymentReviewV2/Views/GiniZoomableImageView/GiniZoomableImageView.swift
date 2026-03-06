//
//  GiniZoomableImageView.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import SwiftUI

/**
 A SwiftUI view that displays a zoomable image using UIKit's scroll view capabilities.
 
 `GiniZoomableImageView` wraps a `GiniZoomableScrollView` to provide pinch-to-zoom
 functionality for images in SwiftUI. The image view automatically centers itself
 when zoomed and maintains aspect ratio scaling.
 
 ## Usage
 ```swift
 GiniZoomableImageView(image: myUIImage)
 ```
 
 The view handles:
 - Pinch-to-zoom gestures via the underlying scroll view
 - Automatic centering of the zoomed image
 - Layout updates when the image changes
 - Aspect-fit content mode for proper image display
 
 - Parameter image: The `UIImage` to display with zoom capabilities.
 
 - Note: This view uses `UIViewRepresentable` to bridge UIKit's `UIScrollView`
 zooming capabilities into SwiftUI.
 */
struct GiniZoomableImageView: UIViewRepresentable {
    
    let image: UIImage
    let size: CGSize
    
    func makeUIView(context: Context) -> GiniZoomableScrollView {
        let scrollView = GiniZoomableScrollView()
        scrollView.delegate = context.coordinator
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        
        scrollView.addSubview(imageView)
        scrollView.imageView = imageView
        
        return scrollView
    }
    
    func updateUIView(_ scrollView: GiniZoomableScrollView, context: Context) {
        if scrollView.imageView?.image != image {
            scrollView.imageView?.image = image
        }
        
        // Reset layout when image or size changes
        if context.coordinator.lastSize != size {
            context.coordinator.lastSize = size
            scrollView.resetLayout()
            scrollView.layoutIfNeeded()
        }
    }
    
    func makeCoordinator() -> GiniZoomableImageViewCoordinator {
        GiniZoomableImageViewCoordinator(self)
    }
}
