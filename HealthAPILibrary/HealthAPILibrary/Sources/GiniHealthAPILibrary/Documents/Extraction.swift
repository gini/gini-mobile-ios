//
//  Extraction.swift
//  GiniPayApiLib
//
//  Created by Enrique del Pozo Gómez on 1/14/18.
//

import Foundation

/**
 * Data model for a document extraction.
 */
@objcMembers final public class Extraction: NSObject {

    /// The extraction's box. Only available for some extractions.
    public let box: Box?
    /// The available candidates for this extraction.
    public let candidates: String?
    /// The extraction's entity.
    public let entity: String
    /// The extraction's value
    public var value: String
    /// The extraction's name
    public var name: String?
    
    /// The extraction's box attributes.
    @objcMembers final public class Box: NSObject {
        public let height: Double
        public let left: Double
        public let page: Int
        public let top: Double
        public let width: Double
        
        public init(height: Double, left: Double, page: Int, top: Double, width: Double) {
            self.height = height
            self.left = left
            self.page = page
            self.top = top
            self.width = width
        }
    }
    
    /// A extraction candidate, containing a box, an entity and a its value.
    @objcMembers final public class Candidate: NSObject {
        public let box: Box?
        public let entity: String
        public let value: String
        
        public init(box: Box?, entity: String, value: String) {
            self.box = box
            self.entity = entity
            self.value = value
        }
    }
    
    public init(box: Box?, candidates: String?, entity: String, value: String, name: String?) {
        self.box = box
        self.candidates = candidates
        self.entity = entity
        self.value = value
        self.name = name
    }
    
}

// MARK: - Decodable

extension Extraction: Decodable {}
extension Extraction.Box: Decodable {}
extension Extraction.Candidate: Decodable {}

// MARK: - isEqual

extension Extraction {
    
    public override func isEqual(_ object: Any?) -> Bool {
        
        guard let other = object as? Extraction else { return false }
        
        return self.box == other.box &&
            self.candidates == other.candidates &&
            self.entity == other.entity &&
            self.name == other.name &&
            self.value == other.value
    }
}

extension Extraction {
    
    public override var debugDescription: String {
        return "(\(name ?? "<null>") : \(value))"
    }
}

extension Extraction.Box {
    
    public override func isEqual(_ object: Any?) -> Bool {

        guard let other = object as? Extraction.Box else { return false }
        
        return self.height == other.height &&
            self.left == other.left &&
            self.page == other.page &&
            self.top == other.top &&
            self.width == other.width
    }
}

extension Extraction.Candidate {
    
    public override func isEqual(_ object: Any?) -> Bool {

        guard let other = object as? Extraction.Candidate else { return false }
        
        return self.box == other.box &&
            self.entity == other.entity &&
            self.value == other.value
    }
}
