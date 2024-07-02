//
//  GiniErrorAnalytics.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

public struct GiniErrorAnalytics {
    let type: String
    let code: Int?
    let reason: String?

    init(type: String, code: Int? = nil, reason: String? = nil) {
        self.type = type
        self.code = code
        self.reason = reason
    }
}
