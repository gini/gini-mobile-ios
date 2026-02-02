//
//  UIViewController.swift
//  GiniCapture
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit
extension UIViewController {

    // MARK: - Generic Error Alert

    /**
     A generic UIViewController extension that shows an error alert with customizable title, message, and actions.

     - parameter message: The error message to display
     - parameter title: Optional title for the alert (default: nil)
     - parameter cancelButtonTitle: Title for the cancel button
     - parameter confirmButtonTitle: Optional title for the confirm button
     - parameter confirmAction: Optional closure to be executed when confirm button is tapped
     */
    func giniShowErrorAlert(message: String,
                            title: String? = nil,
                            cancelButtonTitle: String,
                            confirmButtonTitle: String? = nil,
                            confirmAction: (() -> Void)? = nil) {
        let alertViewController = UIAlertController(title: title,
                                                    message: message,
                                                    preferredStyle: .alert)

        alertViewController.view.tintColor = .GiniCapture.accent1

        // Cancel action
        let cancelAction = UIAlertAction(title: cancelButtonTitle,
                                         style: .cancel,
                                         handler: { _ in
            alertViewController.dismiss(animated: true)
        })
        alertViewController.addAction(cancelAction)

        // Confirm action (if provided)
        if let confirmButtonTitle = confirmButtonTitle, let confirmAction = confirmAction {
            let confirmationAction = UIAlertAction(title: confirmButtonTitle,
                                                   style: .default,
                                                   handler: { _ in
                confirmAction()
            })
            alertViewController.addAction(confirmationAction)
        }

        present(alertViewController, animated: true)
    }

    // MARK: - Camera-Specific Error Dialog

    /**
     Shows an alert based on the Error it gets as the parameter. It can also add an extra option as a closure to be executed.
     Use this when drag and dropping files into the SDK.

     - parameter error: The error to be shown
     - parameter positiveAction: The closure to be executed. If nil, the extra option won't be added.
     */
    public func showErrorDialog(for error: Error, positiveAction: (() -> Void)?) {
        let message: String
        var cancelActionTitle: String = .localized(resource: CameraStrings.errorPopupCancelButton)
        var confirmActionTitle: String? = .localized(resource: CameraStrings.errorPopupPickAnotherFileButton)

        switch error {
        case let validationError as DocumentValidationError:
            message = validationError.message
        case let customValidationError as CustomDocumentValidationError:
            message = customValidationError.message
        case let pickerError as FilePickerError:
            message = pickerError.message
            switch pickerError {
            case .maxFilesPickedCountExceeded:
                confirmActionTitle = .localized(resource: CameraStrings.errorPopupReviewPagesButton)
            case .photoLibraryAccessDenied:
                confirmActionTitle = .localized(resource: CameraStrings.errorPopupGrantAccessButton)
            case .mixedDocumentsUnsupported:
                cancelActionTitle = .localized(resource: CameraStrings.mixedArraysPopupCancelButton)
                confirmActionTitle = .localized(resource: CameraStrings.mixedArraysPopupUsePhotosButton)
            case .failedToOpenDocument:
                break
            case .multiplePdfsUnsupported:
                confirmActionTitle = .localized(resource: CameraStrings.errorConfirmButton)
            }
        default:
            message = DocumentValidationError.unknown.message
        }

        // Track analytics for camera errors
        GiniAnalyticsManager.track(event: .errorDialogShown,
                                   screenName: .camera,
                                   properties: [GiniAnalyticsProperty(key: .errorMessage, value: message)])

        // Show the generic error alert
        giniShowErrorAlert(message: message,
                           cancelButtonTitle: cancelActionTitle,
                           confirmButtonTitle: confirmActionTitle,
                           confirmAction: positiveAction)
    }
}

extension UIViewController {

    func add(asChildViewController viewController: UIViewController, sendToBackIfNeeded: Bool = false) {
        add(childViewController: viewController, to: view, sendToBackIfNeeded: sendToBackIfNeeded)
    }

    private func add(childViewController: UIViewController, to view: UIView, sendToBackIfNeeded: Bool) {
        // Add Child View Controller
        addChild(childViewController)
        // Add Child View as Subview
        view.addSubview(childViewController.view)
        // Notify Child View Controller
        childViewController.didMove(toParent: self)

        if sendToBackIfNeeded {
            view.sendSubviewToBack(childViewController.view)
        }
    }
}

extension UIViewController {
    var currentInterfaceOrientation: UIInterfaceOrientation { view.currentInterfaceOrientation }
}
