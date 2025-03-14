//
//  GiniCaptureImages.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//


import UIKit

enum GiniCaptureImages: String {
    case qrCodeEngagementStep0 = "qrCodeEngagementStep0"
    case qrCodeEngagementStep1 = "qrCodeEngagementStep1"
    case qrCodeEngagementStep2 = "qrCodeEngagementStep2"
    case poweredByGiniLogo = "poweredByGiniLogo"

    var image: UIImage? {
        return UIImageNamedPreferred(named: rawValue)
    }
}
