//
//  GiniBankError.swift
//  GiniBank
//
//  Created by Nadya Karaban on 29.04.21.
//

import Foundation
import GiniBankAPILibrary

/**
 Errors thrown with Gini Bank SDK.
 */
public enum GiniBankError: Error {
     /// Error thrown when there is no requestId in Url from business partner's app.
    case noRequestId
     /// Error thrown when api return failure.
    case apiError(GiniError)
}
