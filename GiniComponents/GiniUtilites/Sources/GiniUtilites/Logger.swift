//
//  Logger.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//



import Foundation
import os

public enum LogEvent {
    case error
    case success
    case warning
    case custom(String)

    var value: String {
        switch self {
        case .error: return "❌"
        case .success: return "✅"
        case .warning: return "⚠️"
        case .custom(let emoji): return emoji
        }
    }
}

public enum LogLevel {
    case none
    case debug
}

public func Log(_ message: String,
         event: LogEvent) {
    let prefix = event.value

    // When having the `OS_ACTIVITY_MODE` disabled, NSLog messages are not printed
    if ProcessInfo.processInfo.environment["OS_ACTIVITY_MODE"] == "disable" {
        print(prefix, message)
    }
    if #available(macOS 10.12, *) {
        os_log("%@ %@", prefix, message)
    } else {
        // Fallback on earlier versions
    }
}
