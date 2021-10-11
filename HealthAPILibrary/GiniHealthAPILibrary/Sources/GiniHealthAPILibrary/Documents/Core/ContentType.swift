//
//  ContentType.swift
//  GiniHealthAPI
//
//  Created by Enrique del Pozo Gómez on 3/5/19.
//

import Foundation

enum ContentType {
    case json
    case content(version: Int, subtype: String?, mimeSubtype: String)
    case formUrlEncoded

    var value: String {
        switch self {
        case .json:
            return "application/json"
        case .content( _, let subtype, let mimeSubtype):
            return "application/vnd.gini.v1" + (subtype == nil ? "" : ".\(subtype!)") + "+\(mimeSubtype)"
        case .formUrlEncoded:
            return "application/x-www-form-urlencoded"
        }
    }
}
