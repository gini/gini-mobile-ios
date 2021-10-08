//
//  ReturnReason.swift
//  GiniHealthAPILib
//
//  Created by Alpár Szotyori on 15.09.20.
//

import Foundation

/**
* Data model for a return reason.
*/
@objcMembers final public class ReturnReason: NSObject {
    
    public let id: String
    public let localizedLabels: [String:String]
    
    public init(id: String, localizedLabels: [String:String]) {
        self.id = id
        self.localizedLabels = localizedLabels
    }
}

// MARK: - Decodable

extension ReturnReason: Decodable {

    private struct Key: CodingKey {
        var stringValue: String

        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        var intValue: Int?

        init?(intValue: Int) {
            self.intValue = intValue
            self.stringValue = "\(intValue)"
        }
    }

    public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        
        var id: String = ""
        var localizedLabels: [String:String] = [:]
        
        try container.allKeys.forEach { key in
            if key.stringValue == "id" {
                id = try container.decode(String.self, forKey: key)
            } else {
                localizedLabels[key.stringValue] = try container.decode(String.self, forKey: key)
            }
        }
        
        self.init(id: id, localizedLabels: localizedLabels)
    }
}

// MARK: - isEqual

extension ReturnReason {
    
    public override func isEqual(_ object: Any?) -> Bool {
        
        guard let other = object as? ReturnReason else { return false }
        
        return self.id == other.id &&
            self.localizedLabels == other.localizedLabels
    }
}

extension ReturnReason {
    
    public override var debugDescription: String {
        return "(\(id) : \(localizedLabels))"
    }
}
