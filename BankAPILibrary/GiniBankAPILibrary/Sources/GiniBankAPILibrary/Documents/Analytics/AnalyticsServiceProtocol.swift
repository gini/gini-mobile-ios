//
//  AnalyticsServiceProtocol.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation


public protocol AnalyticsServiceProtocol: AnyObject {
    func sendEventsPayload(payload: AmplitudeEventsBatchPayload, completion: @escaping CompletionResult<String>)
}

extension AnalyticsServiceProtocol {
    func sendEventsPayload(payload: AmplitudeEventsBatchPayload,
                   resourceHandler: ResourceDataHandler<APIResource<String>>,
                             completion: @escaping CompletionResult<String>) {
        // Default implementation is empty
    }
}
