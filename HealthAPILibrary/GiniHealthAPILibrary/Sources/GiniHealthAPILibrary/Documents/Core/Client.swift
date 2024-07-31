//
//  Client.swift
//  GiniHealthAPI
//
//  Created by Enrique del Pozo Gómez on 1/21/18.
//

import Foundation

/// Client information needed to access the Gini Health API
public struct Client {
    /// Client email domain. i.e: gini.net
    public var domain: String

    public var apiVersion: Int

    /// Client id
    public var id: String
    
    /// Client secret
    public var secret: String
    
    public init(id: String, secret: String, domain: String, apiVersion: Int = GiniHealthAPI.Constants.defaultVersionAPI) {
        self.id = id
        self.secret = secret
        self.domain = domain
        self.apiVersion = apiVersion
    }
}
