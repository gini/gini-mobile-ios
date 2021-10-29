//
//  CameraStrings.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 7/31/18.
//

import Foundation

enum CameraStrings: LocalizableStringResource {
    
    case captureButton, captureFailedMessage, capturedImagesStackSubtitleLabel, errorPopupCancelButton,
    errorPopupGrantAccessButton, errorPopupPickAnotherFileButton, errorPopupReviewPagesButton,
    exceededFileSizeErrorMessage, documentValidationGeneralErrorMessage, fileImportTipLabel, importFileButtonLabel,qrCodeTipLabel,
    mixedArraysPopupCancelButton, mixedArraysPopupUsePhotosButton, mixedDocumentsErrorMessage, notAuthorizedButton,
    notAuthorizedMessage, photoLibraryAccessDeniedMessage, qrCodeDetectedPopupMessage, qrCodeDetectedPopupButton,
    tooManyPagesErrorMessage, unknownErrorMessage, wrongFormatErrorMessage, popupTitleImportPDF, popupOptionPhotos,
    popupOptionFiles, popupTitleImportPDForPhotos, popupCancel, unsupportedQrCodeDetectedPopupMessage,
    failedToOpenDocumentErrorMessage
    
    var tableName: String {
        return "camera"
    }
    
    var tableEntry: LocalizationEntry {
        switch self {
        case .captureButton:
            return ("captureButton",
                    "Title for capture button in camera screen will be used exclusively for accessibility label")
        case .captureFailedMessage:
            return ("captureFailed", "This message is shown when the camera access was denied")
        case .capturedImagesStackSubtitleLabel:
            return ("capturedImagesStackLabel", "label shown below images stack")
        case .errorPopupCancelButton:
            return ("errorPopup.cancelButton", "cancel button title")
        case .errorPopupGrantAccessButton:
            return ("filepicker.errorPopup.grantAccessButton", "grant access button title")
        case .errorPopupPickAnotherFileButton:
            return ("errorPopup.pickAnotherFileButton", "pick another file button title")
        case .errorPopupReviewPagesButton:
            return ("errorPopup.reviewPages", "review pages button title")
        case .exceededFileSizeErrorMessage:
            return ("documentValidationError.excedeedFileSize",
                    "Message text error shown in camera screen when a file size is higher than 10MB")
        case .documentValidationGeneralErrorMessage:
            return ("documentValidationError.general",
                    "Message text of a general document validation error shown in camera screen")
        case .fileImportTipLabel:
            return ("fileImportTip", "tooltip text indicating new file import feature")
        case .mixedArraysPopupCancelButton:
            return ("mixedarrayspopup.cancel", "cancel button text for popup")
        case .mixedArraysPopupUsePhotosButton:
            return ("mixedarrayspopup.usePhotos", "use photos button text in popup")
        case .mixedDocumentsErrorMessage:
            return ("filepicker.mixedDocumentsUnsupported",
                    "Message text error when a more than one file type is selected")
        case .importFileButtonLabel:
            return ("fileImportButtonLabel", "label shown below import button")
        case .notAuthorizedButton:
            return ("notAuthorizedButton", "Button title to open the settings app")
        case .notAuthorizedMessage:
            return ("notAuthorized", "This message is shown when the camera access was denied")
        case .photoLibraryAccessDeniedMessage:
            return ("filepicker.photoLibraryAccessDenied",
                    "This message is shown when Photo library permission is denied")
        case .qrCodeDetectedPopupMessage:
            return ("qrCodeDetectedPopup.message", "Proceed button message")
        case .qrCodeDetectedPopupButton:
            return ("qrCodeDetectedPopup.buttonTitle", "Proceed button title")
        case .tooManyPagesErrorMessage:
            return ("documentValidationError.tooManyPages",
                    "Message text error shown in camera screen when a pdf length is higher than 10 pages" )
        case .unknownErrorMessage:
            return ("unknownError", "This message is shown when" +
                "there is an unknown error in the camera")
        case .wrongFormatErrorMessage:
            return ("documentValidationError.wrongFormat",
                "Message text error shown in camera screen when a file " +
                "has a wrong format (neither PDF, JPEG, GIF, TIFF or PNG)")
        case .popupTitleImportPDF:
            return ("popupTitleImportPDF", "File picker popup title for only PDFs")
        case .popupTitleImportPDForPhotos:
            return ("popupTitleImportPDForPhotos", "File picker popup title for photos and PDFs")
        case .popupOptionFiles:
            return ("popupOptionFiles", "File picker popup file option")
        case .popupOptionPhotos:
            return ("popupOptionPhotos", "File picker popup photos option")
        case .popupCancel:
            return ("popupCancel", "File picker popup cancel option")
        case .unsupportedQrCodeDetectedPopupMessage:
            return ("unsupportedQrCodeDetectedPopup.message", "Popup message")
        case .qrCodeTipLabel:
            return ("qrCodeTip", "tooltip text indicating new qr code feature")
        case .failedToOpenDocumentErrorMessage:
            return ("filepicker.failedToOpenDocument",
                    "Error message when the the picked document couldn't be opened")
        }
    }
    
    var isCustomizable: Bool {
        switch self {
        case .captureButton, .captureFailedMessage, .errorPopupCancelButton,
             .errorPopupGrantAccessButton, .errorPopupPickAnotherFileButton, .errorPopupReviewPagesButton,
             .exceededFileSizeErrorMessage, .documentValidationGeneralErrorMessage,
             .mixedArraysPopupCancelButton, .mixedArraysPopupUsePhotosButton, .mixedDocumentsErrorMessage,
             .notAuthorizedButton, .notAuthorizedMessage, .photoLibraryAccessDeniedMessage, .qrCodeDetectedPopupMessage,
             .qrCodeDetectedPopupButton, .tooManyPagesErrorMessage, .unknownErrorMessage, .wrongFormatErrorMessage, .unsupportedQrCodeDetectedPopupMessage, .fileImportTipLabel, .qrCodeTipLabel, .importFileButtonLabel, .failedToOpenDocumentErrorMessage:
            return true
        case .capturedImagesStackSubtitleLabel, .popupTitleImportPDF,
             .popupTitleImportPDForPhotos, .popupOptionPhotos, .popupOptionFiles, .popupCancel:
            return false
        }
    }
    
    var fallbackTableEntry: String {
        switch self {
        case .errorPopupPickAnotherFileButton:
            return "errorPopup.pickanotherfileButton"
        default:
            return ""
        }
    }
}
