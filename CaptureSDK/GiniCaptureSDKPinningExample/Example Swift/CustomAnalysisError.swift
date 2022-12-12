//
//  CustomAnalysisError.swift
//  GiniCaptureSDKPinningExample
//
//  Created by Krzysztof Kryniecki on 12/12/2022.
//  Copyright © 2022 Gini GmbH. All rights reserved.
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
