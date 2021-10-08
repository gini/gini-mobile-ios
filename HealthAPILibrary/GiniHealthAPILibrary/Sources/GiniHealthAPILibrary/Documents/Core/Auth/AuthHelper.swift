//
//  AuthHelper.swift
//  GiniHealthAPILib
//
//  Created by Enrique del Pozo Gómez on 3/4/19.
//

import Foundation

final class AuthHelper {
        
    static func authorizationHeader(for accessToken: String, headerType: AuthType) -> HTTPHeader {
        return ("Authorization", "\(headerType.rawValue) \(accessToken)")
    }
    
    static func generateUser(with domain: String) -> User {
        return User(email: "\(UUID().uuidString)@\(domain)",
                    password: UUID().uuidString)
    }
    
    static func encoded(_ client: Client) -> String {
        let credentials = "\(client.id):\(client.secret)"
        let credData = credentials.data(using: .utf8)
        return "\(credData?.base64EncodedString() ?? "")"
    }
}
