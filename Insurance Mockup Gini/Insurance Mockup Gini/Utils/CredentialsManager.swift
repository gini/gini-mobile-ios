//
//  CredentialsManager.swift
//  GiniCapture_Example
//
//  Created by Enrique del Pozo Gómez on 2/16/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import GiniHealthAPILibrary
import UIKit

final class CredentialsManager {
    class func fetchClientFromBundle() -> Client {
        let clientID = "client_id"
        let clientPassword = "client_password"
        let clientEmailDomain = "client_domain"
        let credentialsPlistPath = Bundle.main.path(forResource: "Credentials", ofType: "plist")

        if let path = credentialsPlistPath,
           let keys = NSDictionary(contentsOfFile: path),
           let clientID = keys[clientID] as? String,
           let clientPassword = keys[clientPassword] as? String,
           let clientEmailDomain = keys[clientEmailDomain] as? String,
           !clientID.isEmpty, !clientPassword.isEmpty, !clientEmailDomain.isEmpty {
            return Client(id: clientID,
                          secret: clientPassword,
                          domain: clientEmailDomain)
        }

        print("⚠️ No credentials were fetched from the Credentials.plist file")
        return Client(id: "",
                      secret: "",
                      domain: "")
    }
}
