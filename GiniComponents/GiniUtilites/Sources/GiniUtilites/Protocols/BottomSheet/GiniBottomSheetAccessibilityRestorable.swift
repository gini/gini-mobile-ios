//
//  GiniBottomSheetAccessibilityRestorable.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import UIKit

/**
 A protocol for coordinators that present bottom sheets and need to restore
 VoiceOver accessibility after dismissal.
 */
public protocol GiniBottomSheetAccessibilityRestorable: AnyObject {
    /// The view controller used for presenting bottom sheets
    var presenterViewController: UIViewController { get }

    /// The view controller to focus on after bottom sheet dismissal
    var accessibilityFocusTargetViewController: UIViewController? { get }
}

extension GiniBottomSheetAccessibilityRestorable {

    /// Default implementation: focus on the presenter's visible content
    public var accessibilityFocusTargetViewController: UIViewController? {
        if let navigationController = presenterViewController as? UINavigationController {
            return navigationController.topViewController
        }
        return presenterViewController
    }
}

extension GiniBottomSheetAccessibilityRestorable {

    /**
     Restores VoiceOver accessibility after a bottom sheet is dismissed.

     When presenting a view controller using `presentAsBottomSheet(from:)`, the presenting
     view's accessibility is hidden to trap VoiceOver focus within the bottom sheet.
     This method restores accessibility to the navigation controller and posts a
     screen changed notification to refocus VoiceOver.

     Call this method in the bottom sheet's `onDismiss` callback:
     ```swift
     bottomSheetVC.onDismiss = { [weak self] in
     self?.restoreAccessibilityAfterBottomSheetDismissal()
     }
     ```

     - Note: A small delay is used to ensure the dismissal animation completes
     before VoiceOver attempts to refocus.
     */
    public func restoreAccessibilityAfterBottomSheetDismissal() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self else { return }

            // Reset accessibility on presenter's view
            self.presenterViewController.view.accessibilityElementsHidden = false

            // If presenter is a navigation controller, also reset the navigation bar
            if let navigationController = self.presenterViewController as? UINavigationController {
                navigationController.navigationBar.accessibilityElementsHidden = false
            }

            // Notify VoiceOver to refocus on the target view controller
            UIAccessibility.post(notification: .screenChanged,
                                 argument: self.accessibilityFocusTargetViewController?.view)
        }
    }
}
