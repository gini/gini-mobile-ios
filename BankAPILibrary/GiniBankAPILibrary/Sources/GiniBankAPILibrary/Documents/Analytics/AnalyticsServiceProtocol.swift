//
//  AnalyticsServiceProtocol.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation

/// A protocol defining the contract for an analytics service responsible for sending event payloads.
public protocol AnalyticsServiceProtocol: AnyObject {

    /**
     Sends a batch of analytics events payload to the server.

     - Parameters:
     - payload: An `AmplitudeEventsBatchPayload` object containing the events to be sent.
     - completion: A closure to be called with the result of the request.
     It provides a `Result<String, GiniError>` indicating success or failure.

     - Note: Conforming types are expected to provide their own implementation for this method.
     */
    func sendEventsPayload(payload: AmplitudeEventsBatchPayload,
                           completion: @escaping CompletionResult<String>)
}

extension AnalyticsServiceProtocol {

    /**
     A default implementation of `sendEventsPayload` for types conforming to `AnalyticsServiceProtocol`.

     - Parameters:
     - payload: An `AmplitudeEventsBatchPayload` object containing the events to be sent.
     - resourceHandler: A handler for performing network requests, usually provided by a session manager.
     - completion: A closure to be called with the result of the network operation.

     - Note:
     This default implementation is intentionally left **empty**. Conforming types
     can override this method to provide a specific implementation if needed.
     */
    func sendEventsPayload(payload: AmplitudeEventsBatchPayload,
                           resourceHandler: ResourceDataHandler<APIResource<String>>,
                           completion: @escaping CompletionResult<String>) {
        // Default implementation is empty
    }
}
