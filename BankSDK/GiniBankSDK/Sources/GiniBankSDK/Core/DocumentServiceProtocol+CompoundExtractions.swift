//
//  DocumentServiceProtocol + RA.swift
//  GiniPayBank
//
//  Created by Nadya Karaban on 28.02.21.
//

import Foundation
import GiniPayApiLib
import GiniCapture

extension DocumentServiceProtocol {
    func sendFeedback(with updatedExtractions: [Extraction], and updatedCompoundExtractions: [String: [[Extraction]]]){}
}
