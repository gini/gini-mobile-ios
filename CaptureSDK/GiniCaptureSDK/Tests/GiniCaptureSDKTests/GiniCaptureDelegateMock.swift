//
//  GiniCaptureDelegateMock.swift
//  GiniCapture_Example
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import Foundation
@testable import GiniCaptureSDK

final class GiniCaptureDelegateMock: GiniCaptureDelegate {
    func didPressEnterManually() {
        // This method will remain empty; mock implementation does not perform login
    }
    
    func didCapture(document: GiniCaptureDocument, networkDelegate: GiniCaptureNetworkDelegate) {
        // This method will remain empty; mock implementation does not perform login
    }
    
    func didReview(documents: [GiniCaptureDocument], networkDelegate: GiniCaptureNetworkDelegate) {
        // This method will remain empty; mock implementation does not perform login
    }
    
    func didCancelCapturing() {
        // This method will remain empty; mock implementation does not perform login
    }
    
    func didCancelReview(for document: GiniCaptureDocument) {
        // This method will remain empty; mock implementation does not perform login
    }

    func didCancelAnalysis() {
        // This method will remain empty; mock implementation does not perform login
    }
}
