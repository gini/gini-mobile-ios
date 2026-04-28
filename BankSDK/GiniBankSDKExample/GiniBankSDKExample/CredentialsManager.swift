//
//  CredentialsManager.swift
//  Example Swift
//
//  Created by Nadya Karaban on 19.02.21.
//

import Foundation
import GiniBankAPILibrary
final class CredentialsManager {

    class func fetchClientFromBundle() -> Client {
        return fetchClient(idKey: "client_id", passwordKey: "client_password")
    }

    class func fetchCXClientFromBundle() -> Client {
        return fetchClient(idKey: "cx_client_id", passwordKey: "cx_client_password")
    }

    private class func fetchClient(idKey: String, passwordKey: String) -> Client {
        let clientEmailDomain = "client_domain"
        let credentialsPlistPath = Bundle.main.path(forResource: "Credentials", ofType: "plist")

        if let path = credentialsPlistPath,
            let keys = NSDictionary(contentsOfFile: path),
            let client_id = keys[idKey] as? String,
            let client_password = keys[passwordKey] as? String,
            let client_email_domain = keys[clientEmailDomain] as? String,
            !client_id.isEmpty, !client_password.isEmpty, !client_email_domain.isEmpty {

            return Client(id: client_id,
                          secret: client_password,
                          domain: client_email_domain)
        }

        return Client(id: "",
                      secret: "",
                      domain: "")
    }
}
