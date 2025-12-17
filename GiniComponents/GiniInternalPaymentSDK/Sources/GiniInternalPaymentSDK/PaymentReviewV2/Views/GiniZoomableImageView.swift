//
//  GiniZoomableImageView.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import SwiftUI

/// A SwiftUI view that displays a zoomable image using UIKit's scroll view capabilities.
///
/// `GiniZoomableImageView` wraps a `GiniZoomableScrollView` to provide pinch-to-zoom
/// functionality for images in SwiftUI. The image view automatically centers itself
/// when zoomed and maintains aspect ratio scaling.
///
/// ## Usage
///
/// ```swift
/// GiniZoomableImageView(image: myUIImage)
/// ```
///
/// The view handles:
/// - Pinch-to-zoom gestures via the underlying scroll view
/// - Automatic centering of the zoomed image
/// - Layout updates when the image changes
/// - Aspect-fit content mode for proper image display
///
/// - Note: This view uses `UIViewRepresentable` to bridge UIKit's `UIScrollView`
///   zooming capabilities into SwiftUI.
struct GiniZoomableImageView: UIViewRepresentable {
    
    let image: UIImage
    
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
            scrollView.resetLayout()
            scrollView.layoutIfNeeded()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        let parent: GiniZoomableImageView
        
        init(_ parent: GiniZoomableImageView) {
            self.parent = parent
        }
        
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return (scrollView as? GiniZoomableScrollView)?.imageView
        }
        
        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            guard let zoomableScrollView = scrollView as? GiniZoomableScrollView,
                  let imageView = zoomableScrollView.imageView else { return }
            
            // Center imageView when zoomed
            let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
            let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
            
            imageView.center = CGPoint(
                x: scrollView.contentSize.width * 0.5 + offsetX,
                y: scrollView.contentSize.height * 0.5 + offsetY
            )
        }
    }
}
