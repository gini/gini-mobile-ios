//
//  Logger.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//



import Foundation
import os

/**
 Represents the type of event being logged.

 Used to categorize log messages with a symbolic prefix to visually distinguish
 between different types of events, such as errors, warnings, and successes.
 */
public enum LogEvent {
    /// Indicates an error event (❌).
    case error

    /// Indicates a success event (✅).
    case success

    /// Indicates a warning event (⚠️).
    case warning

    /**
     Represents a custom log event with a user-defined symbol or marker.

     - parameter symbol: A string used to prefix the log message, such as a character or icon.
     */
    case custom(String)

    /// The symbol associated with the log event.
    var value: String {
        switch self {
            case .error: return "❌"
            case .success: return "✅"
            case .warning: return "⚠️"
            case .custom(let symbol): return symbol
        }
    }
}

/**
 Represents the log level configuration.

 Can be used to enable or disable logging output globally.
 */
public enum LogLevel {
    /// Logging is completely disabled.
    case none

    /// Debug-level logging is enabled.
    case debug
}

/**
 Logs a message with an associated event type.

 This function outputs the message prefixed by a symbol that identifies
 the nature of the event. It uses `os_log` when available, and falls back
 to `print` when logging is disabled via `OS_ACTIVITY_MODE`.

 - Parameters:
 - message: The content to be logged.
 - event: The `LogEvent` indicating the type of event (e.g., error, success, custom).
 */
public func Log(_ message: String,
                event: LogEvent) {
    let prefix = event.value

    // When the `OS_ACTIVITY_MODE` is disabled, NSLog messages may not appear
    if ProcessInfo.processInfo.environment["OS_ACTIVITY_MODE"] == "disable" {
        print(prefix, message)
    }
    if #available(macOS 10.12, *) {
        os_log("%@ %@", prefix, message)
    } else {
        // Fallback on earlier versions
    }
}

