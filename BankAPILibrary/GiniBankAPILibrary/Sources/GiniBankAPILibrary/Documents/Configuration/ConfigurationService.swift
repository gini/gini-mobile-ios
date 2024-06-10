//
//  ConfigurationService.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation

public final class ConfigurationService: ConfigurationServiceProtocol {
    public func fetchConfigurations(completion: @escaping CompletionResult<Configuration>) {
        self.fetchConfigurations(resourceHandler: sessionManager.data, completion: completion)
    }

    let sessionManager: SessionManagerProtocol
    public var apiDomain: APIDomain

    init(sessionManager: SessionManagerProtocol, apiDomain: APIDomain = .default) {
        self.sessionManager = sessionManager
        self.apiDomain = apiDomain
    }
}
