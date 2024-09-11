//
//  GiniHealthImage.swift
//  GiniHealthSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit

/**
 The GiniHealthImage enumeration provides a convenient way to manage image assets within the Gini SDK, supporting customization for both light and dark modes. Each case in the enumeration represents a specific image asset used by the SDK.

 - Note: The raw values for each case correspond to the image asset names in the asset catalog.
 */

public enum GiniHealthImage: String {
    case logo = "gh.giniLogo"
    case info = "gh.infoCircle"
    case close = "gh.close"
    case more = "gh.more"
    case plus = "gh.plus"
    case minus = "gh.minus"
    case appStore = "gh.appStoreIcon"
    case chevronDown = "gh.iconChevronDown"
    case selectionIndicator = "gh.selectionIndicator"
    case paymentReviewClose = "gh.paymentReviewClose"
    case lock = "gh.iconInputLock"

    /**
     Retrieves an image corresponding to the enumeration case, prioritizing the client's bundle. If the image is not found in the client's bundle, it attempts to load the image from the Gini Health SDK bundle.

     - Returns: An UIImage instance corresponding to the enumeration case. If the image cannot be found in either the client's bundle or the Gini Health SDK bundle, the method triggers a runtime error.
     */
    public func preferredUIImage() -> UIImage {
        return UIImage(named: self.rawValue) ?? defaultImage()
    }
}

//MARK: - Private
private extension GiniHealthImage {
    func defaultImage() -> UIImage {
        guard let image = UIImage(named: self.rawValue, in: giniHealthBundle(), compatibleWith: nil) else {
            fatalError("Health SDK: Image \(self.rawValue) not found")
        }
        return image
    }
}



