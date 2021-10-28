//
//  Request.swift
//  GiniBankAPI
//
//  Created by Enrique del Pozo Gómez on 1/20/18.
//

import Foundation

typealias HTTPHeaders = [String: String]
typealias HTTPHeader = (key: String, value: String)

enum HTTPHeaderKey: String {
    case contentType = "content-type"
}

enum HTTPContentType: String {
    case json = "application/json"
    case urlEncode = "application/x-www-form-urlencoded"
}

enum HTTPMethod: String {
    case get = "GET", post = "POST", put = "PUT", delete = "DELETE"
}

enum URLScheme: String {
    case https
}

struct RequestParameters {
    
    let body: Data?
    let method: HTTPMethod
    var headers: HTTPHeaders
    
    public init(method: HTTPMethod, headers: HTTPHeaders = [:], body: Data? = nil) {
        self.method = method
        self.headers = headers
        self.body = body
    }
    
}
