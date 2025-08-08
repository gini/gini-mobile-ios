//
//  InfoBottomSheetViewModel.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

public protocol InfoBottomSheetViewModel {
    var image: UIImage? { get }
    var imageTintColor: UIColor? { get }
    var title: String { get }
    var description: String { get }
}
