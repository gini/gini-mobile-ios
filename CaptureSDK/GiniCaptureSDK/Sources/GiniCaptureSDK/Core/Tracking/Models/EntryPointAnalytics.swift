//
//  EntryPointAnalytics.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

public enum EntryPointAnalytics: String {
    case button
    case field
    case openWith = "open_with"
    
   public static func makeFrom(entryPoint: GiniConfiguration.GiniEntryPoint) -> EntryPointAnalytics {
        switch entryPoint {
        case .button:
            return .button
        case .field:
            return .field
        }
    }
}
