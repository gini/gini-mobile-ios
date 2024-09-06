//
//  ClientConfigurationServiceProtocol.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
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
    
    /**
     The last successfully fetched client configuration, saved locally for persistence.
     This configuration is retrieved from `UserDefaults`, allowing the app to use the last known settings

     - returns: An optional `ClientConfiguration` object that may contain previously fetched configurations.
     */
    var savedConfiguration: ClientConfiguration? { get }
}

extension ClientConfigurationServiceProtocol {
    /**
     Fetches configurations using the provided resource handler.

     - parameter resourceHandler: The handler that processes the API resource data.
     - parameter completion: A closure that handles the result of the configuration fetch operation.
     */
    func fetchConfigurations(resourceHandler: ResourceDataHandler<APIResource<ClientConfiguration>>,
                             completion: @escaping CompletionResult<ClientConfiguration>) {
        // Default implementation is empty
    }
}

