//
//  GiniTextFieldState.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import SwiftUI

struct GiniInputFieldState {
    
    var text: String
    var hasError: Bool
    var errorMessage: String?
    
    init(text: String, hasError: Bool, errorMessage: String? = nil) {
        self.text = text
        self.hasError = hasError
        self.errorMessage = errorMessage
    }
}

