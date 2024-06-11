//
//  GiniTrackingPermissionManager.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import AppTrackingTransparency
import AdSupport

class GiniTrackingPermissionManager {

    static let shared = GiniTrackingPermissionManager()

    private init() {}

    func trackingAuthorized() -> Bool {
        if #available(iOS 14, *) {
            return ATTrackingManager.trackingAuthorizationStatus == .authorized
        } else {
            return true // Tracking is enabled by default on earlier iOS versions
        }
    }
}
