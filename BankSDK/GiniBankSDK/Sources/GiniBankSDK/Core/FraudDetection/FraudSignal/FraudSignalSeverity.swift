//
//  FraudSignalSeverity.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation

/**
 Severity levels for a fraud signal.

 Unknown values are silently dropped by `FraudSignalMapper` so a new severity
 never breaks the flow.
 */
internal enum FraudSignalSeverity: String {
    case stop = "STOP"
    case check = "CHECK"
    case escalator = "ESCALATOR"
    case silent = "SILENT"
}
