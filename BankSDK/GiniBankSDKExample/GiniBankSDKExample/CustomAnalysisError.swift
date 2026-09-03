//
//  CustomAnalysisError.swift
//  GiniBankSDKExample
//
//  Created by Krzysztof Kryniecki on 07/12/2022.
//

import Foundation
import GiniCaptureSDK
import GiniBankAPILibrary

enum CustomAnalysisError: GiniCaptureError {
    case analysisFailed
    var message: String {
        switch self {
        case .analysisFailed:
            return NSLocalizedString("analysisFailedErrorMessage", comment: "analysis failed error message")
        }
    }
}
