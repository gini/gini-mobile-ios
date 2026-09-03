//
//  GiniLogger.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//
/**
 A protocol defining a basic logging interface used across Gini SDKs.

 Conforming types should implement logic to output log messages,
 potentially with symbols or context to identify the source or severity
 of the message.

 This allows for dependency injection and consistent logging behavior
 across different modules.
 */
public protocol GiniLogger: AnyObject {

    /**
     Logs a message.

     Implementations may format or prefix the message based on internal settings,
     such as the type of event, log level, or module identity.

     - parameter message: The message to be logged.
     */
    func log(message: String)
}
