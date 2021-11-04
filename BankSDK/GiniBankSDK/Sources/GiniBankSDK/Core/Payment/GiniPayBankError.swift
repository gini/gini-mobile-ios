//
//  GiniPayBankError.swift
//  GiniPayBank
//
//  Created by Nadya Karaban on 29.04.21.
//

import Foundation
import GiniPayApiLib

/**
 Errors thrown with GiniPayBank SDK.
 */
public enum GiniPayBankError: Error {
     /// Error thrown when there is no requestId in Url from business partner's app.
    case noRequestId
     /// Error thrown when api return failure.
    case apiError(GiniError)
}
