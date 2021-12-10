//
//  UserResource.swift
//  GiniHealthAPI
//
//  Created by Enrique del Pozo Gómez on 1/20/18.
//

import Foundation

public enum UserDomain {
    /// The default one, which points to https://user.gini.net
    case `default`
    /// A custom domain
    case custom(domain: String)
    
    var domainString: String {
        
        switch self {
        case .default: return "user.gini.net"
        case .custom(let domain): return domain
        }
    }
}

struct UserResource<T: Decodable>: Resource {
    var fullUrlString: String?
    typealias ResourceMethodType = UserMethod
    typealias ResponseType = T
    
    var domain: UserDomain
    
    var host: String {
        return "\(domain.domainString)"
    }
    
    var scheme: URLScheme {
        return .https
    }
    
    var path: String {
        switch method {
        case .token:
            return "/oauth/token"
        case .users:
            return "/api/users"
        }
    }
    
    var queryItems: [URLQueryItem?]? {
        switch method {
        case .token(let grantype):
            return [URLQueryItem(name: "grant_type", itemValue: grantype.rawValue)]
        default: return nil
        }
    }
    
    var params: RequestParameters
    var method: UserMethod
    var authServiceType: AuthServiceType? {
        switch method {
        case .users:
            return .userService(.bearer)
        case .token:
            return .userService(.basic)
        }
    }
    
    var defaultHeaders: HTTPHeaders {
        switch method {
        case .token:
            return ["Accept": ContentType.json.value,
                    "Content-Type": ContentType.formUrlEncoded.value
            ]
        case .users:
            return ["Accept": ContentType.json.value,
                    "Content-Type": ContentType.json.value
            ]
        }
    }

    init(method: UserMethod,
         userDomain: UserDomain,
         httpMethod: HTTPMethod,
         additionalHeaders: HTTPHeaders = [:],
         body: Data? = nil) {
        self.method = method
        self.domain = userDomain
        self.params = RequestParameters(method: httpMethod,
                                        body: body)
        self.params.headers = defaultHeaders.merging(additionalHeaders) { (current, _ ) in current }
    }
    
    func parsed(response: HTTPURLResponse, data: Data) throws -> ResponseType {
        guard ResponseType.self != String.self else {
            // swiftlint:disable:next force_cast
            return String(data: data, encoding: .utf8) as! ResponseType
        }
        
        return try JSONDecoder().decode(ResponseType.self, from: data)
    }
}

