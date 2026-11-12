//
//  GiniIcons.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import UIKit

/**
 Semantic enum of every image shipped in `GiniIcons.xcassets`.

 Mirrors the `GiniImages` pattern in `GiniBankSDK` (and its per-SDK
 siblings): raw values are the asset-catalog names, `.image` resolves
 through the host-override chain via `preferredImage(named:)` so hosts
 can swap any icon by shipping a same-named asset in their main bundle.
 */
enum GiniIcons: String {
    case radioUnselected = "radio_unselected"
    case radioSelected = "radio_selected"
    case radioError = "radio_error"

    var image: UIImage? {
        preferredImage(named: rawValue)
    }
}
