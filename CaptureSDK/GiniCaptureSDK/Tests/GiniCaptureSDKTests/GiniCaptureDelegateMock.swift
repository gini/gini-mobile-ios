//
//  GiniCaptureDelegateMock.swift
//  GiniCapture_Example
//
//  Created by Enrique del Pozo Gómez on 3/8/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import Foundation
@testable import GiniCaptureSDK
final class GiniCaptureDelegateMock: GiniCaptureDelegate {
    func didCapture(document: GiniCaptureDocument, networkDelegate: GiniCaptureNetworkDelegate) {
        
    }
    
    func didReview(documents: [GiniCaptureDocument], networkDelegate: GiniCaptureNetworkDelegate) {
        
    }
    
    func didCancelCapturing() {
        
    }
    
    func didCancelReview(for document: GiniCaptureDocument) {
        
    }
    
    func didCancelAnalysis() {
        
    }
    
}
