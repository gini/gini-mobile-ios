//
//  AccessToken.swift
//  GiniHealthAPI
//
//  Created by Enrique del Pozo Gómez on 1/20/18.
//

import Foundation

public final class Token: Decodable {

    var expiration: Date
    var scope: String?
    var type: String?
    public var accessToken: String
    
    public init(expiration: Date, scope: String?, type: String?, accessToken: String) {
        self.expiration = expiration
        self.scope = scope
        self.type = type
        self.accessToken = accessToken
    }
    
    enum Keys: String, CodingKey {
        case expiresIn = "expires_in"
        case scope
        case type = "token_type"
        case accessToken = "access_token"
    }

    convenience public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        let expiresIn = try container.decode(Double.self, forKey: .expiresIn) // seconds
        let expiration = Date(timeInterval: expiresIn, since: Date())
        let scope = try container.decodeIfPresent(String.self, forKey: .scope)
        let type = try container.decodeIfPresent(String.self, forKey: .type)
        let accessToken = try container.decode(String.self, forKey: .accessToken)

        self.init(expiration: expiration,
                  scope: scope,
                  type: type,
                  accessToken: accessToken)

    }
}

