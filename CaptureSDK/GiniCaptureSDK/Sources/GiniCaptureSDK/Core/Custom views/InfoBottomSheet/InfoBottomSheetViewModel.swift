//
//  InfoBottomSheetViewModel.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

/// Protocol defining the content requirements for an info bottom sheet
public protocol InfoBottomSheetViewModel {
    /// Optional image to display in the bottom sheet
    var image: UIImage? { get }
    /// Optional tint color for the image
    var imageTintColor: UIColor? { get }
    /// Title text for the bottom sheet
    var title: String { get }
    /// Description text for the bottom sheet
    var description: String { get }
    /// Optional background color to image
    var imageBackgroundColor: UIColor? { get }

    /// Optional accessibility identifier applied to the sheet's container view.
    var containerAccessibilityID: String? { get }
    /// Optional accessibility identifier applied to the sheet's title label.
    var titleAccessibilityID: String? { get }
    /// Optional accessibility identifier applied to the sheet's description label.
    var descriptionAccessibilityID: String? { get }
    /// Optional accessibility identifier applied to the sheet's primary button.
    var primaryButtonAccessibilityID: String? { get }
    /// Optional accessibility identifier applied to the sheet's secondary button.
    var secondaryButtonAccessibilityID: String? { get }
}

/**
 Default identifier values are `nil` so existing implementations don't
 have to opt in; only conformers that need UI-automation hooks provide
 concrete strings.
 */
public extension InfoBottomSheetViewModel {
    var containerAccessibilityID: String? { nil }
    var titleAccessibilityID: String? { nil }
    var descriptionAccessibilityID: String? { nil }
    var primaryButtonAccessibilityID: String? { nil }
    var secondaryButtonAccessibilityID: String? { nil }
}
