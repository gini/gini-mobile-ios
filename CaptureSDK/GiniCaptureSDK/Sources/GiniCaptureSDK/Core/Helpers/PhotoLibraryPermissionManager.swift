//
//  PhotoLibraryPermissionManager.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//
//

import Photos
import UIKit

/**
 Represents the various authorization states for photo library access.

 This enum provides a simplified representation of the system's photo library authorization status,
 making it easier to handle permission states in a consistent manner.
 */

enum PhotoLibraryPermissionStatus {
    case authorized
    case limited
    case denied
    case notDetermined
    case restricted
}

/**
 Defines the level of access requested for the photo library.

 This enum allows you to specify whether you need read-write access or just add-only access
 when requesting photo library permissions.
 */

enum PhotoLibraryAccessLevel {
    case addOnly
    case readWrite

    /**
     Converts the access level to the system's PHAccessLevel type.

     - Returns: The corresponding PHAccessLevel value
     */
    @available(iOS 14, *)
    var phAccessLevel: PHAccessLevel {
        switch self {
        case .addOnly:
            return .addOnly
        case .readWrite:
            return .readWrite
        }
    }
}

/**
 Manages photo library permission requests and status checks.

 This singleton class provides a centralized interface for checking and requesting
 photo library permissions with support for different access levels. It handles both
 iOS 14+ access levels and iOS 13 fallback behavior.
 */
class PhotoLibraryPermissionManager {

    static let shared = PhotoLibraryPermissionManager()

    private init() {
        // This initializer is intentionally left empty because no custom setup is required at initialization.
    }

    // MARK: - Check Current Status
    /**
     Returns the current authorization status for the specified access level.

     This method checks the current permission state without prompting the user.
     On iOS 14 and later, it supports checking for specific access levels. On iOS 13,
     it falls back to the basic authorization status.

     - Parameter accessLevel: The level of access to check (defaults to `.readWrite`)
     - Returns: The current permission status as a `PhotoLibraryPermissionStatus`
     */
    func currentStatus(for accessLevel: PhotoLibraryAccessLevel = .readWrite) -> PhotoLibraryPermissionStatus {
        if #available(iOS 14, *) {
            let status = PHPhotoLibrary.authorizationStatus(for: accessLevel.phAccessLevel)
            return mapStatus(status)
        } else {
            // iOS 13 fallback - only has basic authorization
            let status = PHPhotoLibrary.authorizationStatus()
            return mapStatus(status)
        }
    }

    // MARK: - Request Permission (Async/Await)
    /**
     Requests photo library permission for the specified access level.

     This method prompts the user for photo library access if permission has not yet been determined.
     If permission was previously granted or denied, it returns the current status without showing a prompt.

     The method uses async/await for modern Swift concurrency and automatically handles iOS version differences,
     falling back to the basic authorization request on iOS 13.

     - Parameter accessLevel: The level of access to request (defaults to `.readWrite`)
     - Returns: The resulting permission status after the request

     - Important: This method must be called from an async context. Ensure all UI updates
     are performed on the main actor after receiving the result.

     */
    func requestPermission(for accessLevel: PhotoLibraryAccessLevel = .readWrite) async -> PhotoLibraryPermissionStatus {
        if #available(iOS 14, *) {
            let status = await PHPhotoLibrary.requestAuthorization(for: accessLevel.phAccessLevel)
            return mapStatus(status)
        } else {
            // iOS 13 fallback
            return await withCheckedContinuation { continuation in
                PHPhotoLibrary.requestAuthorization { status in
                    continuation.resume(returning: self.mapStatus(status))
                }
            }
        }
    }

    // MARK: - Private Helpers

    /**
     Maps the system's PHAuthorizationStatus to the app's PhotoLibraryPermissionStatus.

     - Parameter status: The system authorization status
     - Returns: The corresponding PhotoLibraryPermissionStatus value
     */
    private func mapStatus(_ status: PHAuthorizationStatus) -> PhotoLibraryPermissionStatus {
        switch status {
        case .authorized:
            return .authorized
        case .limited:
            return .limited
        case .denied:
            return .denied
        case .notDetermined:
            return .notDetermined
        case .restricted:
            return .restricted
        @unknown default:
            return .denied
        }
    }
}
