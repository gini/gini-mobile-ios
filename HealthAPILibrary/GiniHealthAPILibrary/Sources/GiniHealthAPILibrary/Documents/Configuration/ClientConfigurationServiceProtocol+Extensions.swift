//
//  ClientConfigurationServiceProtocol+Extensions.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import Foundation

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
