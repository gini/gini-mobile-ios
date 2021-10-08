//
//  UserMethod.swift
//  GiniHealthAPILib
//
//  Created by Enrique del Pozo Gómez on 3/4/19.
//

import Foundation

enum UserMethod: ResourceMethod {
    
    enum AuthGrantType: String {
        case clientCredentials = "client_credentials"
        case password = "password"
    }
    
    case token(grantType: AuthGrantType)
    case users
    
    var path: String {
        switch self {
        case .token:
            return "/oauth/token"
        case .users:
            return "/api/users"
        }
    }
    
    var queryItems: [URLQueryItem?]? {
        switch self {
        case .token(let grantype):
            return [URLQueryItem(name: "grant_type", itemValue: grantype.rawValue)]
        default: return nil
        }
    }
    
}
