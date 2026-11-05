//
//  FraudSignalSeverity.swift
//  GiniBank
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation

/**
 Severity levels for a fraud signal.

 An unknown value returns `nil` from `from(apiValue:)` so a new severity never
 breaks the flow — it is silently dropped by `FraudSignalMapper`.
 */
internal enum FraudSignalSeverity: String {
    case stop = "STOP"
    case check = "CHECK"
    case escalator = "ESCALATOR"
    case silent = "SILENT"

    /**
     Resolves a backend wire value to a known severity, or `nil` if the SDK does not know it.
     */
    static func from(apiValue: String?) -> FraudSignalSeverity? {
        guard let apiValue else { return nil }
        return FraudSignalSeverity(rawValue: apiValue)
    }
}
