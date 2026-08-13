//
//  CredentialsSet.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation

struct CredentialsSet {
    static let setB: (clientId: String, clientSecret: String) = {
        let client = CredentialsManager.fetchCXClientFromBundle()
        return (clientId: client.id, clientSecret: client.secret)
    }()
    static var setA: (clientId: String, clientSecret: String) {
        let client = CredentialsManager.fetchClientFromBundle()
        return (clientId: client.id, clientSecret: client.secret)
    }

    /// Staging counterpart of set A; set B (CX) has no staging variant.
    static var stageSetA: (clientId: String, clientSecret: String) {
        let client = CredentialsManager.fetchStageClientFromBundle()
        return (clientId: client.id, clientSecret: client.secret)
    }

    static func credentials(for index: Int,
                            environment: APIEnvironment) -> (clientId: String, clientSecret: String) {
        guard index == 0 else { return setB }
        return environment == .stage ? stageSetA : setA
    }
}
