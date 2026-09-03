//
//  GiniHealthTrackingDelegate.swift
//
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

/**
Struct representing a tracking event. It contains the event type and an optional
dictionary for additional related data.
*/
public struct TrackingEvent<T: RawRepresentable> where T.RawValue == String {
    
    /// Type of the event.
    public let type: T
    
    /// Additional information carried by the event.
    public var info: [String : String]?
    
    init(type: T, info: [String : String]? = nil) {
        self.type = type
        self.info = info
    }
}
