//
//  UIViewController.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 2/20/18.
//

import UIKit

extension UIViewController {
    /**
     A UIViewcontroller extension that shows an alert based on the Error it gets as the parameter. It can also add an extra option as a closure to be executed.
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

        let dialog = errorDialog(withMessage: message,
                                 cancelActionTitle: cancelActionTitle,
                                 confirmActionTitle: confirmActionTitle,
                                 confirmAction: positiveAction)
        GiniAnalyticsManager.track(event: .errorDialogShown,
                                   screenName: .camera,
                                   properties: [GiniAnalyticsProperty(key: .errorMessage, value: message)])
        present(dialog, animated: true, completion: nil)
    }

    fileprivate func errorDialog(withMessage message: String,
                                 title: String? = nil,
                                 cancelActionTitle: String,
                                 confirmActionTitle: String? = nil,
                                 confirmAction: (() -> Void)? = nil) -> UIAlertController {

        let alertViewController = UIAlertController(title: nil, message: message, preferredStyle: .alert)

        alertViewController.view.tintColor = .GiniCapture.accent1

        alertViewController.addAction(UIAlertAction(title: cancelActionTitle,
                                                    style: .cancel,
                                                    handler: { _ in
                                                        alertViewController.dismiss(animated: true, completion: nil)
        }))

        if let confirmActionTitle = confirmActionTitle, let confirmAction = confirmAction {
            alertViewController.addAction(UIAlertAction(title: confirmActionTitle,
                                                        style: .default,
                                                        handler: { _ in
                                                            confirmAction()
            }))
        }

        return alertViewController
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
