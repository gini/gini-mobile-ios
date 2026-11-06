//
//  CredentialsSmokeTests.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
@testable import GiniBankSDKExample
@testable import GiniBankAPILibrary

/**
 Smoke tests that pin the mapping between the build-time-generated
 `Credentials` enum (produced by `scripts/generate_credentials.sh`) and
 the `CredentialsManager.fetch*ClientFromBundle()` factories.

 These do not exercise the generator itself — that is covered by
 `scripts/test_generate_credentials.sh`. They prove that whatever the
 generator wrote is observable through the public `CredentialsManager`
 call sites that the app uses.
 */
@Suite("Credentials smoke tests")
struct CredentialsSmokeTests {

    @Test("Generated Credentials enum exposes every expected key")
    func credentialsEnumExposesAllKeys() {
        // Compile-time proof the generated enum has every expected field.
        // If the generator shape drifts, this suite fails to build.
        #expect(!Credentials.clientID.isEmpty,
                "`.env.local` must populate GINI_CLIENT_ID before this suite runs.")
        _ = Credentials.clientPassword
        _ = Credentials.clientDomain
        _ = Credentials.cxClientID
        _ = Credentials.cxClientPassword
        _ = Credentials.stageClientID
        _ = Credentials.stageClientPassword
    }

    @Test("fetchClientFromBundle returns the generated clientID triple")
    func fetchClientFromBundleProducesClientID() {
        let client = CredentialsManager.fetchClientFromBundle()
        #expect(client.id == Credentials.clientID)
        #expect(client.secret == Credentials.clientPassword)
        #expect(client.domain == Credentials.clientDomain)
    }

    @Test("fetchCXClientFromBundle returns the generated CX ID triple")
    func fetchCXClientFromBundleProducesCXID() {
        let client = CredentialsManager.fetchCXClientFromBundle()
        #expect(client.id == Credentials.cxClientID)
        #expect(client.secret == Credentials.cxClientPassword)
        #expect(client.domain == Credentials.clientDomain)
    }
}
