//
//  Client.swift
//  GiniBankAPI
//
//  Created by Enrique del Pozo Gómez on 1/21/18.
//

import Foundation

/// Client information needed to access the Gini Bank API
public struct Client {
    /// Client email domain. i.e: gini.net
    public var domain: String
    
    /// Client id
    public var id: String
    
    /// Client secret
    public var secret: String
    
    public init(id: String, secret: String, domain: String) {
        self.id = id
        self.secret = secret
        self.domain = domain
    }
}
