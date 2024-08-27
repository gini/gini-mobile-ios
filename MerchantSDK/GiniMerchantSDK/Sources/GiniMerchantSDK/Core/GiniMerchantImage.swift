//
//  GiniImage.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit

/**
 The GiniMerchantImage enumeration provides a convenient way to manage image assets within the Gini SDK, supporting customization for both light and dark modes. Each case in the enumeration represents a specific image asset used by the SDK.

 - Note: The raw values for each case correspond to the image asset names in the asset catalog.
 */

public enum GiniMerchantImage: String {
    case logo = "gm.giniLogo"
    case info = "gm.infoCircle"
    case close = "gm.close"
    case more = "gm.more"
    case plus = "gm.plus"
    case minus = "gm.minus"
    case appStore = "gm.appStoreIcon"
    case chevronDown = "gm.iconChevronDown"
    case selectionIndicator = "gm.selectionIndicator"
    case paymentReviewClose = "gm.paymentReviewClose"
    case lock = "gm.iconInputLock"

    /**
     Retrieves an image corresponding to the enumeration case, prioritizing the client's bundle. If the image is not found in the client's bundle, it attempts to load the image from the Gini Merchant SDK bundle.
     
     - Returns: An UIImage instance corresponding to the enumeration case. If the image cannot be found in either the client's bundle or the Gini Merchant SDK bundle, the method triggers a runtime error.
     */
    public func preferredUIImage() -> UIImage {
        return UIImage(named: self.rawValue) ?? defaultImage()
    }
}

//MARK: - Private
private extension GiniMerchantImage {
    func defaultImage() -> UIImage {
        guard let image = UIImage(named: self.rawValue, in: giniMerchantBundle(), compatibleWith: nil) else {
            fatalError("Merchant SDK: Image \(self.rawValue) not found")
        }
        return image
    }
}



