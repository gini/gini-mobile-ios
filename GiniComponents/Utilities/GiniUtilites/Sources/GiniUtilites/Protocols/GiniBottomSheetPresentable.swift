//
//  GiniBottomSheetPresentable.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

/**
 A type alias for view controllers that can be presented as bottom sheets.
 */
public typealias GiniBottomSheetViewController = UIViewController & GiniBottomSheetPresentable

/**
 A protocol that provides bottom sheet presentation functionality to UIViewController instances.
 
 Conforming view controllers can be presented using iOS 15+ sheet presentation controllers
 with configurable detents and drag indicators. For iOS versions prior to 15, the view controller
 will be presented as a standard modal sheet.
 
 - Note: This protocol leverages `UISheetPresentationController` which is available from iOS 15.0+
 
 ## Topics
 
 ### Configuring Bottom Sheet Behavior
 - ``shouldShowDragIndicator``
 
 ### Presentation Methods
 - ``configureBottomSheet(shouldIncludeLargeDetent:)``
 - ``updateBottomSheetHeight(_:)``
 */
public protocol GiniBottomSheetPresentable {
    
    /**
     Determines whether the drag indicator (grabber) should be visible on the bottom sheet.
     
     The drag indicator provides visual feedback to users that the sheet can be interacted with
     and repositioned through drag gestures.
     
     - Returns: `true` if the drag indicator should be shown, `false` otherwise.
     */
    var shouldShowDragIndicator: Bool { get }
    
    /**
     Determines whether the sheet should be visible on full screen in compact modes.
     
     - Returns: `true` if the sheet should be displayed in full screen when in landscape mode, `false` otherwise.
     */
    var shouldShowInFullScreenInLandscapeMode: Bool { get }
    
    /**
     Configures the bottom sheet presentation with the specified detent options.
     
     This method sets up the sheet presentation controller with appropriate detents and behavior.
     The drag indicator visibility is controlled by the `shouldShowDragIndicator` property.
     
     - Parameter shouldIncludeLargeDetent: Whether to include a large detent option.
     If `true`, uses `.large()` detent; if `false`, uses `.medium()` detent. Defaults to `false`.
     
     - Note: This functionality is only available on iOS 15.0 and later.
     On earlier versions, the view controller will be presented as a standard modal sheet.
     
     ## Example
     ```swift
     // Configure with medium detent
     viewController.configureBottomSheet()
     
     // Configure with large detent
     viewController.configureBottomSheet(shouldIncludeLargeDetent: true)
     ```
     */
    func configureBottomSheet(shouldIncludeLargeDetent: Bool)
    
    /**
     Updates the bottom sheet to use a custom height detent.
     
     This method creates a custom detent with the specified height and applies it to the
     sheet presentation controller. The custom detent becomes the selected detent.
     
     - Parameter height: The desired height for the bottom sheet in points.
     
     - Note: Custom detents are only available on iOS 16.0 and later.
     On earlier versions, this method will have no effect and the view controller
     will maintain its current presentation behavior.
     
     ## Example
     ```swift
     // Set custom height of 300 points
     viewController.updateBottomSheetHeight(300)
     ```
     */
    func updateBottomSheetHeight(_ height: CGFloat)
}

public extension GiniBottomSheetPresentable where Self: UIViewController {
    
    func configureBottomSheet(shouldIncludeLargeDetent: Bool = false) {
        /// For iOS versions prior to 15, the view controller will be presented as a standard modal sheet
        if #available(iOS 15, *),
           let presentationController = sheetPresentationController {
            presentationController.prefersGrabberVisible = shouldShowDragIndicator
            presentationController.prefersScrollingExpandsWhenScrolledToEdge = false
            presentationController.prefersEdgeAttachedInCompactHeight = !shouldShowInFullScreenInLandscapeMode
            
            if #available(iOS 16, *) {
                let halfScreenDetent = UISheetPresentationController.Detent.custom { context in
                    self.view.bounds.height / 2
                }
                
                presentationController.detents = [shouldIncludeLargeDetent ? .large() : halfScreenDetent]
            } else {
                presentationController.detents = [shouldIncludeLargeDetent ? .large() : .medium()]
            }
        }
    }
    
    func updateBottomSheetHeight(_ height: CGFloat) {
        /// For iOS versions prior to 15, the view controller will be presented as a standard modal sheet
        /// For iOS version prior to 16, this method will have no effect and the sheet will not be resized.
        if #available(iOS 16, *),
           let presentationController = sheetPresentationController {
            let identifier = UISheetPresentationController.Detent.Identifier("customHeight")
            
            let customDetent = UISheetPresentationController.Detent.custom(identifier: identifier) { context in
                return height
            }
            
            presentationController.prefersGrabberVisible = shouldShowDragIndicator
            presentationController.detents = [customDetent]
            presentationController.selectedDetentIdentifier = identifier
        }
    }
}
