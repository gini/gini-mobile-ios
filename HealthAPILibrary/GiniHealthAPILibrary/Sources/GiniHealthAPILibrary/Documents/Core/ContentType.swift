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
        case .content(let apiVersion, let subtype, let mimeSubtype):
            return "application/vnd.gini.v\(apiVersion)" + (subtype == nil ? "" : ".\(subtype!)") + "+\(mimeSubtype)"
        case .formUrlEncoded:
            return "application/x-www-form-urlencoded"
        }
    }
}
