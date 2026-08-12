//
//  DefaultLogger.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

/**
 A default implementation of the `GiniLogger` protocol that logs messages
 with a customizable prefix. The prefix is used to help identify which SDK or
 module the log messages originate from.
 */
public final class DefaultLogger: GiniLogger {

    /// The prefix used to identify the source of the log message.
    private let prefix: String

    /**
     Initializes a new instance of `DefaultLogger` with a custom prefix.

     - Parameters:
     -  prefix: A string that will be prefixed to every log message.
     */
    public init(prefix: String) {
        self.prefix = prefix
    }

    /**
     Logs a message with the configured prefix.

     - Parameters:
     -  message: The message to log.
     */
    public func log(message: String) {
        Log(message, event: .custom(prefix))
    }
}
