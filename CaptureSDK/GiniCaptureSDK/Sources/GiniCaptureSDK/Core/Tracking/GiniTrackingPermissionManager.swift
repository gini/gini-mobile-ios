//
//  GiniTrackingPermissionManager.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import AppTrackingTransparency
import AdSupport

class GiniTrackingPermissionManager {

    static let shared = GiniTrackingPermissionManager()

    // The private empty initializer ensures that no other instances of this class can be created.
    // By making the initializer private and providing a static shared instance, we enforce a singleton pattern.
    // This means there is only one instance of GiniTrackingPermissionManager throughout the app's lifecycle.
    private init() {
        // This initializer is intentionally left empty because no custom setup is required at initialization.
    }

    func trackingAuthorized() -> Bool {
        ATTrackingManager.trackingAuthorizationStatus == .authorized
        || ATTrackingManager.trackingAuthorizationStatus == .notDetermined
    }
}
