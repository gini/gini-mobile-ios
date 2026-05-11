//
//  View+Accessibility.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import SwiftUI

extension View {
    /**
     Applies `.accessibilityHint` only when a non-nil, non-empty message is provided,
     leaving the hint untouched otherwise.
     Use this to surface validation errors without displacing the SwiftUI `TextField`'s
     default accessibility value (the user-entered text).
     - Parameters:
       - message: The hint message to expose, or `nil` to leave the hint untouched.
     */
    @ViewBuilder
    func accessibilityHintIfPresent(_ message: String?) -> some View {
        if let message, !message.isEmpty {
            self.accessibilityHint(message)
        } else {
            self
        }
    }
}
