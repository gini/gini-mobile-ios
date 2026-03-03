//
//  CredentialsSet.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation

struct CredentialsSet {
    static let setB = (clientId: "...", clientSecret: "...")
    static let setA = (clientId: "...", clientSecret: "...")

    static func credentials(for index: Int) -> (clientId: String, clientSecret: String) {
        return index == 0 ? setA : setB
    }
}
