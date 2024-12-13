//
//  AmplitudeEventsBatchPayload.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
/**
 A struct representing the payload for batching events to be sent to the server.

 This struct conforms to the `Encodable` protocol to facilitate easy encoding
 to JSON format. It includes the API key and an array of events to be uploaded.

 - Parameters:
 - events: An array of `AmplitudeBaseEvent` objects to be included in the batch upload.
 */
public struct AmplitudeEventsBatchPayload: Encodable {
    let events: [AmplitudeBaseEvent]

    /**
     Customizes the coding keys for the `AmplitudeEventsBatchPayload` struct to match the expected JSON format.

     - events: Encoded as "events" in the JSON payload.
     */
    enum CodingKeys: String, CodingKey {
        case events
    }
    
    public init(events: [AmplitudeBaseEvent]) {
        self.events = events
    }
}
