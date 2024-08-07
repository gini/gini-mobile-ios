//
//  Document+Layout.swift
//  GiniBankAPI
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

extension Document.Layout {
    /// A document's page layout, indicating its size, textZones, regions and its page number
    public struct Page: Decodable {
        /// Page number
        public let number: Int
        /// Page width
        public let sizeX: Double
        /// Page height
        public let sizeY: Double
        /// Page textZones
        public let textZones: [TextZone]
        /// Page regions
        public let regions: [Region]?
    }
    
    /// A document's page layout region, indicating its origin, size, type, lines and words
    public struct Region: Decodable {
        /// Top-Left X origin
        public let l: Double
        /// Top-Left Y origin
        public let t: Double
        /// Region width
        public let w: Double
        /// Region height
        public let h: Double
        /// Region type
        public let type: String?
        /// (Optional) Amount of lines in that region
        public let lines: [Region]?
        /// (Optional) Amount of words in that region
        public let wds: [Word]?
    }
    
    /// A document's page text zone, containing an array of regions
    public struct TextZone: Decodable {
        public let paragraphs: [Region]
    }
    
    /// Word contained within a text region
    public struct Word: Decodable {
        /// Top-Left X origin
        public let l: Double
        /// Top-Left Y origin
        public let t: Double
        /// Word width
        public let w: Double
        /// Word height
        public let h: Double
        /// Word font size
        public let fontSize: Double
        /// Word font family
        public let fontFamily: String
        /// Indicates if the font style is bold
        public let bold: Bool
        /// Text contained in the word
        public let text: String
    }
}
