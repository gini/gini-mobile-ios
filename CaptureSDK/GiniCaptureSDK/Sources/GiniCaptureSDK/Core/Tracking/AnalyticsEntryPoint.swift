//
//  AnalyticsEntryPoint.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation

enum AnalyticsEntryPoint: String {
    case button
    case field
    case openWith = "open_with"
    
    static func makeFrom(entryPoint: GiniConfiguration.GiniEntryPoint) -> AnalyticsEntryPoint {
        switch entryPoint {
        case .button:
            return .button
        case .field:
            return .field
        }
    }
}
