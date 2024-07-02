//
//  GiniEntryPointAnalytics.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

public enum GiniEntryPointAnalytics: String {
    case button
    case field
    case openWith = "open_with"

   public static func makeFrom(entryPoint: GiniConfiguration.GiniEntryPoint) -> GiniEntryPointAnalytics {
        switch entryPoint {
        case .button:
            return .button
        case .field:
            return .field
        }
    }
}
