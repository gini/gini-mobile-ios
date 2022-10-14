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
        
    }
    
    func reviewDidTapAddImage(_ controller: ReviewViewController) {
        
    }
    
    var updatedDocuments: [GiniCapturePage] = []
    
    func review(_ controller: ReviewViewController, didDelete pages: GiniCapturePage) {
        
    }

    func reviewDidTapProcess(_ viewController: ReviewViewController) {

    }

    func review(_ viewController: ReviewViewController, didSelectPage page: GiniCapturePage) {

    }
}
