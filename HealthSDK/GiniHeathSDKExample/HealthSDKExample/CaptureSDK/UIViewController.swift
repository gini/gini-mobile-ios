//
//  UIViewController.swift
//  GiniCapture_Example
//
//  Created by Enrique del Pozo Gómez on 5/8/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import UIKit
import GiniCapture

extension UIViewController {
    func showErrorDialog(for error: Error, positiveAction: (() -> Void)?) {
        let message: String
        var cancelActionTitle: String = NSLocalizedString("ginicapture.camera.errorPopup.cancelButton",
                                                          bundle: Bundle(for: GiniCapture.self),
                                                          comment: "cancel button title")
        var confirmActionTitle: String? = NSLocalizedString("ginicapture.camera.errorPopup.pickanotherfileButton",
                                                            bundle: Bundle(for: GiniCapture.self),
                                                            comment: "pick another file button title")
        
        switch error {
        case let validationError as DocumentValidationError:
            message = validationError.message
        case let customValidationError as CustomDocumentValidationError:
            message = customValidationError.message
        case let pickerError as FilePickerError:
            message = pickerError.message
            switch pickerError {
            case .maxFilesPickedCountExceeded:
                confirmActionTitle = NSLocalizedString("ginicapture.camera.errorPopup.reviewPages",
                                                       bundle: Bundle(for: GiniCapture.self),
                                                       comment: "review pages button title")
            case .photoLibraryAccessDenied:
                cancelActionTitle = NSLocalizedString("ginicapture.camera.filepicker.errorPopup.cancelButton",
                                                      bundle: Bundle(for: GiniCapture.self),
                                                      comment: "cancel button title")
                confirmActionTitle = NSLocalizedString("ginicapture.camera.filepicker.errorPopup.grantAccessButton",
                                                       bundle: Bundle(for: GiniCapture.self),
                                                       comment: "cancel button title")
            case .mixedDocumentsUnsupported:
                cancelActionTitle = NSLocalizedString("ginicapture.camera.mixedarrayspopup.cancel",
                                                      bundle: Bundle(for: GiniCapture.self),
                                                      comment: "cancel button text for popup")
                confirmActionTitle = NSLocalizedString("ginicapture.camera.mixedarrayspopup.usePhotos",
                                                       bundle: Bundle(for: GiniCapture.self),
                                                       comment: "use photos button text in popup")
            case .failedToOpenDocument:
                break
            }
        case let visionError as CustomAnalysisError:
            message = visionError.message
            confirmActionTitle = nil
            cancelActionTitle = NSLocalizedString("ginicapture.analysis.error.actionTitle",
                                                   bundle: Bundle(for: GiniCapture.self),
                                                   comment: "Retry analysis")
        default:
            message = DocumentValidationError.unknown.message
        }
        
        let dialog = errorDialog(withMessage: message,
                                 cancelActionTitle: cancelActionTitle,
                                 confirmActionTitle: confirmActionTitle,
                                 confirmAction: positiveAction)
        
        present(dialog, animated: true, completion: nil)
    }
    
    fileprivate func errorDialog(withMessage message: String,
                                 title: String? = nil,
                                 cancelActionTitle: String,
                                 confirmActionTitle: String? = nil,
                                 confirmAction: (() -> Void)? = nil) -> UIAlertController {
        
        let alertViewController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
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
