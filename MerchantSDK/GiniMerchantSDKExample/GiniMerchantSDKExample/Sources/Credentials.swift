//
//  Credentials.swift
//
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
import GiniHealthAPILibrary

/// The API client credentials.
///
/// - Note: Replace the placeholder strings with your actual API credentials. For development purposes, use the credentials provided by Gini that point to the test environment.

class Credentials {
    static let id = "YOUR_CLIENT_ID"
    static let secret = "YOUR_CLIENT_SECRET"
    static let domain = "YOUR_CLIENT_DOMAIN"
    
    static var exampleCredentials: Client {
        guard id != "YOUR_CLIENT_ID", secret != "YOUR_CLIENT_SECRET", domain != "YOUR_CLIENT_DOMAIN" else {
            fatalError("🔑 API credentials are missing. Please replace the placeholder strings with your actual API credentials.")
        }
        
        return Client(id: id,
                      secret: secret,
                      domain: domain)
    }
}
