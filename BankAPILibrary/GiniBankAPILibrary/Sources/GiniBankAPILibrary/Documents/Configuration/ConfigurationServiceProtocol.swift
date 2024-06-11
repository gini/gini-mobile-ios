//
//  ConfigurationService.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation

public protocol ConfigurationServiceProtocol: AnyObject {
    func fetchConfigurations(completion: @escaping CompletionResult<Configuration>)
}

extension ConfigurationServiceProtocol {
    func fetchConfigurations(resourceHandler: ResourceDataHandler<APIResource<Configuration>>,
                            completion: @escaping CompletionResult<Configuration>) {
    }
}

