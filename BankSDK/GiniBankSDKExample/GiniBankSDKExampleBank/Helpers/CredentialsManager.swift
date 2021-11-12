//
//  CredentialsManager.swift
//  Bank
//
//  Created by Nadya Karaban on 04.05.21.
//

import Foundation
import GiniBankAPILibrary
final class CredentialsManager {

    class func fetchClientFromBundle() -> Client {
        let clientID = "client_id"
        let clientPassword = "client_password"
        let clientEmailDomain = "client_domain"
        let credentialsPlistPath = Bundle.main.path(forResource: "Credentials", ofType: "plist")
        
        if let path = credentialsPlistPath,
            let keys = NSDictionary(contentsOfFile: path),
            let client_id = keys[clientID] as? String,
            let client_password = keys[clientPassword] as? String,
            let client_email_domain = keys[clientEmailDomain] as? String,
            !client_id.isEmpty, !client_password.isEmpty, !client_email_domain.isEmpty {
            
            return Client(id: client_id,
                          secret: client_password,
                          domain: client_email_domain)
        }
        
        print("⚠️ No credentials were fetched from the Credentials.plist file")
        return Client(id: "",
                      secret: "",
                      domain: "")
    }
}
