//
//  Event.swift
//  GiniCapture
//
//  Created by Maciej Trybilo on 03.03.20.
//

import Foundation

/**
Struct representing a tracking event. It contains the event type and an optional
dictionary for additional related data.
*/
public struct Event<T: RawRepresentable> where T.RawValue == String {
    
    /// Type of the event.
    public let type: T
    
    /// Additional information carried by the event.
    public let info: [String : String]?
    
    init(type: T, info: [String : String]? = nil) {
        self.type = type
        self.info = info
    }
}
