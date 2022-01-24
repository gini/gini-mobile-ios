//
//  GiniHealthTrackingDelegate.swift
//
//
//  Created by Nadya Karaban on 05.01.22.
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
    public let info: [String : String]?
    
    init(type: T, info: [String : String]? = nil) {
        self.type = type
        self.info = info
    }
}
