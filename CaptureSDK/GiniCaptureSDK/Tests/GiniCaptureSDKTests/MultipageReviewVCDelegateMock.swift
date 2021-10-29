//
//  MultipageReviewViewControllerDelegateMock.swift
//  GiniCapture_Example
//
//  Created by Enrique del Pozo Gómez on 3/26/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import Foundation
@testable import GiniCaptureSDK
final class MultipageReviewVCDelegateMock: MultipageReviewViewControllerDelegate {
    func multipageReview(_ viewController: MultipageReviewViewController,
                         didTapRetryUploadFor page: GiniCapturePage) {
        
    }
    
    func multipageReviewDidTapAddImage(_ controller: MultipageReviewViewController) {
        
    }
    
    var updatedDocuments: [GiniCapturePage] = []

    func multipageReview(_ controller: MultipageReviewViewController, didReorder pages: [GiniCapturePage]) {
        updatedDocuments = pages
    }
    
    func multipageReview(_ controller: MultipageReviewViewController, didDelete pages: GiniCapturePage) {
        
    }
    
    func multipageReview(_ controller: MultipageReviewViewController, didRotate pages: GiniCapturePage) {
        
    }
}
