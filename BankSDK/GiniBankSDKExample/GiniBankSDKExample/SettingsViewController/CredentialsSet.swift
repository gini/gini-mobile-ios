//
//  CredentialsSet.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation

struct CredentialsSet {
    static let setA = (clientId: "...", clientSecret: "...")
    static var setA: (clientId: String, clientSecret: String) {
        let client = CredentialsManager.fetchClientFromBundle()
        return (clientId: client.id, clientSecret: client.secret)
    }

    static func credentials(for index: Int) -> (clientId: String, clientSecret: String) {
        return index == 0 ? setA : setB
    }
}
