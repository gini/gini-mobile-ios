//
//  DocumentServiceProtocol + RA.swift
// GiniBank
//
//  Created by Nadya Karaban on 28.02.21.
//

import Foundation
import GiniBankAPILibrary
import GiniCaptureSDK

extension DocumentServiceProtocol {
    func sendFeedback(with updatedExtractions: [Extraction], and updatedCompoundExtractions: [String: [[Extraction]]]){}
}
