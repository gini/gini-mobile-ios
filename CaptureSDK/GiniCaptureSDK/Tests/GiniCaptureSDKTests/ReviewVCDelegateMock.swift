//
//  ReviewViewControllerDelegateMock.swift
//  GiniCapture_Example
//
//  Created by Enrique del Pozo Gómez on 3/26/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import Foundation
@testable import GiniCaptureSDK
final class ReviewVCDelegateMock: ReviewViewControllerDelegate {
    func review(_ viewController: ReviewViewController,
                didTapRetryUploadFor page: GiniCapturePage) {
        // This method will remain empty; mock implementation does not perform login
        
    }
    
    func reviewDidTapAddImage(_ controller: ReviewViewController) {
        // This method will remain empty; mock implementation does not perform login
    }
    
    var updatedDocuments: [GiniCapturePage] = []
    
    func review(_ controller: ReviewViewController, didDelete pages: GiniCapturePage) {
        // This method will remain empty; mock implementation does not perform login
    }

    func reviewDidTapProcess(_ viewController: ReviewViewController) {
        // This method will remain empty; mock implementation does not perform login
    }

    func review(_ viewController: ReviewViewController, didSelectPage page: GiniCapturePage) {
        // This method will remain empty; mock implementation does not perform login
    }
}
