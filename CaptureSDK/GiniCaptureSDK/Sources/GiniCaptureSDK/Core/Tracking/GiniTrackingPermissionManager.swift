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

    // This function checks whether tracking is authorized.
    // - If the iOS version is 14 or later, it uses ATTrackingManager to determine the authorization status.
    // - If the iOS version is earlier than 14, it assumes tracking is enabled by default, because the
    //   concept of tracking authorization did not exist in those versions.
    func trackingAuthorized() -> Bool {
        if #available(iOS 14, *) {
            return ATTrackingManager.trackingAuthorizationStatus == .authorized
            || ATTrackingManager.trackingAuthorizationStatus == .notDetermined
        } else {
            return true // Tracking is enabled by default on earlier iOS versions
        }
    }
}
