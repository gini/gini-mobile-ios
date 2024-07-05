//
//  URL+Utils.swift
// GiniBank
//
//  Created by Nadya Karaban on 28.02.21.
//

import Foundation
extension URL {
    var queryParameters: [String: Any]? {
        return URLComponents(string: self.absoluteString)?
            .queryItems?
            .reduce(into: [String: Any]()) { (dict, queryItem) in
                dict[queryItem.name] = queryItem.value
        }
    }
}
