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
}
