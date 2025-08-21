//
//  GiniBottomSheetViewController.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//
import UIKit

/**
 A convenience typealias combining `UIViewController` with `GiniBottomSheetPresentable`,
 allowing any conforming controller to present itself as a configurable bottom sheet.
 */
public typealias GiniBottomSheetViewController = UIViewController & GiniBottomSheetPresentable

/**
 A protocol defining the interface for view controllers that can be presented as bottom sheets.
 */
public protocol GiniBottomSheetPresentable {

    /// A Boolean value indicating whether a drag indicator (grabber) should be shown at the top of the sheet.
    var shouldShowDragIndicator: Bool { get }

    /**
     Determines whether the sheet should be visible on full screen in compact modes.

     - Returns: `true` if the sheet should be displayed in full screen when in landscape mode, `false` otherwise.
     */
    var shouldShowInFullScreenInLandscapeMode: Bool { get }

    /**
     Configures the bottom sheet presentation for the view controller.

     - Parameters:
     - shouldIncludeLargeDetent: A Boolean that determines whether a `.large()` detent should be included.
     If false, a `.medium()` detent will be used instead. Defaults to `false`.
     */
    func configureBottomSheet(shouldIncludeLargeDetent: Bool)

    /**
     Updates the bottom sheet's height using a custom detent.

     - Parameters:
     - height: The desired height for the bottom sheet.
     */
    func updateBottomSheetHeight(to height: CGFloat)
}

public extension GiniBottomSheetPresentable where Self: UIViewController {

    /**
     Configures the view controller to be presented as a bottom sheet.

     - Parameters:
     - shouldIncludeLargeDetent: If `true`, the sheet will use a `.large()` detent.
     Otherwise, a `.medium()` detent is used. On iOS 13–14, this falls back to `.pageSheet`.
     */
    func configureBottomSheet(shouldIncludeLargeDetent: Bool = false) {
        if #available(iOS 15, *),
           let presentationController = sheetPresentationController {

            presentationController.detents = [shouldIncludeLargeDetent ? .large() : .medium()]
            presentationController.prefersGrabberVisible = shouldShowDragIndicator
            presentationController.prefersScrollingExpandsWhenScrolledToEdge = false
            // It determines whether a sheet-style presentation should appear edge-attached (i.e., pinned to the bottom of the screen)
            // when the height class is compact — such as in landscape mode on an iPhone.
            presentationController.prefersEdgeAttachedInCompactHeight = !shouldShowInFullScreenInLandscapeMode
        } else {
            // Fallback for iOS 13–14
            modalPresentationStyle = .pageSheet
        }
    }

    /**
     Dynamically updates the bottom sheet height using a custom detent.

     On iOS 16+, it defines and applies a custom detent with the given height.

     - Parameters:
     - height: The target height for the bottom sheet.
     */
    func updateBottomSheetHeight(to height: CGFloat) {

        if #available(iOS 16.0, *),
           let presentationController = sheetPresentationController {

            let identifier = UISheetPresentationController.Detent.Identifier("customHeight")

            let customDetent = UISheetPresentationController.Detent.custom(identifier: identifier) { _ in
                return height
            }

            presentationController.detents = [customDetent]
            presentationController.selectedDetentIdentifier = identifier
        }
    }
}
