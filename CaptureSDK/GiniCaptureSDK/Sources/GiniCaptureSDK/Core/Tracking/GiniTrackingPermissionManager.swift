//
//  GiniTrackingPermissionManager.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import AppTrackingTransparency
import AdSupport

class GiniTrackingPermissionManager {

    static let shared = GiniTrackingPermissionManager()

    private let statusProvider: () -> ATTrackingManager.AuthorizationStatus

    init(statusProvider: @escaping () -> ATTrackingManager.AuthorizationStatus =
         { ATTrackingManager.trackingAuthorizationStatus }) {
        self.statusProvider = statusProvider
    }

    func trackingAuthorized() -> Bool {
        let status = statusProvider()
        return status == .authorized || status == .notDetermined
    }
}
