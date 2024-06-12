//
//  ConfigurationService.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation

/**
 Protocol for configuration service
 */
public protocol ConfigurationServiceProtocol: AnyObject {
    /**
     Fetches configurations from the server.

     - parameter completion: A closure that handles the result of the configuration fetch operation.
     */
    func fetchConfigurations(completion: @escaping CompletionResult<Configuration>)
}

extension ConfigurationServiceProtocol {
    /**
     Fetches configurations using the provided resource handler.

     - parameter resourceHandler: The handler that processes the API resource data.
     - parameter completion: A closure that handles the result of the configuration fetch operation.
     */
    func fetchConfigurations(resourceHandler: ResourceDataHandler<APIResource<Configuration>>,
                             completion: @escaping CompletionResult<Configuration>) {
        // Default implementation is empty
    }
}

