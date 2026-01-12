//
//  GiniZoomableScrollView.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

/**
 A specialized scroll view that provides zooming and panning capabilities for displaying images.
 
 `GiniZoomableScrollView` extends `UIScrollView` to handle image display with automatic scaling,
 centering, and zoom functionality. It manages the layout and positioning of an embedded
 image view, ensuring the image fits properly within the scroll view's bounds while maintaining
 aspect ratio.
 
 ## Usage
 
 Create an instance and assign an `UIImageView` to the `imageView` property:
 ```swift
 let scrollView = GiniZoomableScrollView()
 let imageView = UIImageView(image: myImage)
 scrollView.imageView = imageView
 scrollView.addSubview(imageView)
 ```
 
 The scroll view automatically calculates the appropriate initial scale and positioning
 to fit the entire image within its bounds while maintaining the image's aspect ratio.
 
 ## Layout Behavior
 
 The scroll view performs initial layout calculations only once when:
 - The bounds size is non-zero
 - An image view has been assigned
 
 Call `resetLayout()` to force a recalculation of the image view's frame, which is useful
 when the image or scroll view's bounds change significantly.
 
 - Note: The image view must have a valid `image` property set for proper layout calculations.
 */
final class GiniZoomableScrollView: UIScrollView {
    
    var imageView: UIImageView?
    private var hasPerformedInitialLayout = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        minimumZoomScale = 1.0
        maximumZoomScale = 4.0
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        bouncesZoom = true
        contentInsetAdjustmentBehavior = .never
        backgroundColor = .clear
        
        /// Add double tap gesture
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        /// Only update frame on initial layout or when image changes
        if !hasPerformedInitialLayout && bounds.size != .zero, imageView != nil {
            updateImageViewFrame()
            hasPerformedInitialLayout = true
        }
    }
    
    func resetLayout() {
        hasPerformedInitialLayout = false
        setNeedsLayout()
    }
    
    private func updateImageViewFrame() {
        guard let imageView = imageView,
              let image = imageView.image,
              bounds.size != .zero else { return }
        
        let scrollViewSize = bounds.size
        let imageSize = image.size
        
        /// Calculate scale to fit the entire image
        let widthScale = scrollViewSize.width / imageSize.width
        let heightScale = scrollViewSize.height / imageSize.height
        let minScale = min(widthScale, heightScale)
        
        /// Calculate the frame to fit the image
        let scaledWidth = imageSize.width * minScale
        let scaledHeight = imageSize.height * minScale
        
        /// Center the image
        let x = (scrollViewSize.width - scaledWidth) / 2
        let y = (scrollViewSize.height - scaledHeight) / 2
        
        imageView.frame = CGRect(
            x: max(0, x),
            y: max(0, y),
            width: scaledWidth,
            height: scaledHeight
        )
        
        /// Update content size
        contentSize = scrollViewSize
        
        /// Set initial zoom scale
        zoomScale = minimumZoomScale
    }
    
    @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        guard let scrollView = gesture.view as? UIScrollView else { return }
        
        if scrollView.zoomScale > scrollView.minimumZoomScale {
            /// Zoom out to minimum
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            /// Zoom in to 2x at tap location
            let location = gesture.location(in: scrollView)
            let zoomRect = zoomRect(for: 2.0, center: location, in: scrollView)
            scrollView.zoom(to: zoomRect, animated: true)
        }
    }
    
    private func zoomRect(for scale: CGFloat, center: CGPoint, in scrollView: UIScrollView) -> CGRect {
        let width = scrollView.bounds.width / scale
        let height = scrollView.bounds.height / scale
        let x = center.x - (width / 2.0)
        let y = center.y - (height / 2.0)
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
}
