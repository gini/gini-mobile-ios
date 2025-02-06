//
//  ClientConfigurationServiceProtocol.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import Foundation

/**
 Protocol for client configuration service
 */
public protocol ClientConfigurationServiceProtocol: AnyObject {
    /**
     Fetches configurations from the server.

     - parameter completion: A closure that handles the result of the configuration fetch operation.
     */
    func fetchConfigurations(completion: @escaping CompletionResult<ClientConfiguration>)
}
