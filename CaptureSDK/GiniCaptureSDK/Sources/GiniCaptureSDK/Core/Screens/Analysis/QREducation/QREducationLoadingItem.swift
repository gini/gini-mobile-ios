//
//  QREducationLoadingItem.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

struct QREducationLoadingItem {
    let image: UIImage?
    let text: String
    let duration: TimeInterval

    var durationInNanoseconds: UInt64 {
        UInt64(duration * 1_000_000_000)
    }
}
