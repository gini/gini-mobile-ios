//
//  GiniError.swift
//  GiniCapture
//
//  Created by Peter Pult on 22/06/16.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit

public protocol GiniCaptureError: Error {
    var message: String { get }
}

/**
 Errors thrown on the camera screen or during camera initialization.
 */
@objc public enum CameraError: Int, GiniCaptureError {
    /// Unknown error during camera use.
    case unknown
    
    /// Camera can not be loaded because the user has denied authorization in the past.
    case notAuthorizedToUseDevice
    
    /// No valid input device could be found for capturing.
    case noInputDevice
    
    /// Capturing could not be completed.
    case captureFailed
    
    public var message: String {
        switch self {
        case .captureFailed:
            return .localized(resource: CameraStrings.captureFailedMessage)
        case .noInputDevice:
            return .localized(resource: CameraStrings.notAuthorizedMessage)
        case .notAuthorizedToUseDevice:
            return .localized(resource: CameraStrings.notAuthorizedMessage)
        case .unknown:
            return .localized(resource: CameraStrings.unknownErrorMessage)
        }
    }
}

/**
 Errors thrown on the review screen.
 */
@objc public enum ReviewError: Int, GiniCaptureError {
    
    /// Unknown error during review.
    case unknown
    
    public var message: String {
        switch self {
        case .unknown:
            return .localized(resource: ReviewStrings.unknownErrorMessage)
        }
    }
}

/**
 Errors thrown on the file picker
 */

@objc public enum FilePickerError: Int, GiniCaptureError {
    
    /// Camera roll can not be loaded because the user has denied authorization in the past.
    case photoLibraryAccessDenied
    
    /// Max number of files picked exceeded
    case maxFilesPickedCountExceeded
    
    /// Mixed documents unsupported
    case mixedDocumentsUnsupported
    
    /// Could not open the document (data could not be read or unsupported file type or some other issue)
    case failedToOpenDocument
    
    public var message: String {
        switch self {
        case .photoLibraryAccessDenied:
            return .localized(resource: CameraStrings.photoLibraryAccessDeniedMessage)
        case .maxFilesPickedCountExceeded:
            return .localized(resource: CameraStrings.tooManyPagesErrorMessage)
        case .mixedDocumentsUnsupported:
            return .localized(resource: CameraStrings.mixedDocumentsErrorMessage)
        case .failedToOpenDocument:
            return .localized(resource: CameraStrings.failedToOpenDocumentErrorMessage)
        }
    }
}

/**
 Errors thrown when dealing with document analysis (both getting extractions and uploading documents)
 */

@objc public enum AnalysisError: Int, GiniCaptureError {
    
    /// The analysis was cancelled
    case cancelled
    
    /// There was an error creating the document
    case documentCreation
    case unknown    
    
    public var message: String {
        switch self {
        case .documentCreation:
            return .localized(resource: AnalysisStrings.documentCreationErrorMessage)
        case .cancelled:
            return .localized(resource: AnalysisStrings.cancelledMessage)
        default:
            return .localized(resource: AnalysisStrings.analysisErrorMessage)
        }
    }
}

/**
 Errors thrown validating a document (image or pdf).
 */
@objc public enum DocumentValidationError: Int, GiniCaptureError, Equatable {
    
    /// Unknown error during review.
    case unknown
    
    /// Exceeded max file size
    case exceededMaxFileSize
    
    /// Image format not valid
    case imageFormatNotValid
    
    /// File format not valid
    case fileFormatNotValid
    
    /// PDF length exceeded
    case pdfPageLengthExceeded
    
    /// QR Code formar not valid
    case qrCodeFormatNotValid
    
    public var message: String {
        switch self {
        case .exceededMaxFileSize:
            return .localized(resource: CameraStrings.exceededFileSizeErrorMessage)
        case .imageFormatNotValid:
            return .localized(resource: CameraStrings.wrongFormatErrorMessage)
        case .fileFormatNotValid:
            return .localized(resource: CameraStrings.wrongFormatErrorMessage)
        case .pdfPageLengthExceeded:
            return .localized(resource: CameraStrings.tooManyPagesErrorMessage)
        case .qrCodeFormatNotValid:
            return .localized(resource: CameraStrings.wrongFormatErrorMessage)
        case .unknown:
            return .localized(resource: CameraStrings.documentValidationGeneralErrorMessage)
        }
    }
    
    public static func == (lhs: DocumentValidationError, rhs: DocumentValidationError) -> Bool {
        return lhs.message == rhs.message
    }
}

/**
 Errors thrown when running a custom validation.
 */
@objc public class CustomDocumentValidationError: NSError {
    
    public convenience init(message: String) {
        self.init(domain: "net.gini", code: 1, userInfo: ["message": message])
    }
    
    public var message: String {
        return userInfo["message"] as? String ?? ""
    }
}

public class CustomDocumentValidationResult: NSObject {
    private(set) var isSuccess: Bool
    private(set) var error: CustomDocumentValidationError?
    
    private init(withSuccess success: Bool, error: CustomDocumentValidationError? = nil) {
        self.isSuccess = success
        self.error = error
    }
    
    public class func success() -> CustomDocumentValidationResult {
        return CustomDocumentValidationResult(withSuccess: true)
    }
    
    public class func failure(withError error: CustomDocumentValidationError) -> CustomDocumentValidationResult {
        return CustomDocumentValidationResult(withSuccess: false, error: error)
    }
}
