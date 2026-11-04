//
//  CredentialsSmokeTests.swift
//  GiniHealthSDKExampleTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
@testable import GiniHealthSDKExample

/**
 Smoke tests that pin the mapping between the build-time-generated
 `Credentials` enum (produced by `scripts/generate_credentials.sh`) and
 the global constants exported by `CredentialsManager.swift`.

 These do not exercise the generator itself — that is covered by
 `scripts/test_generate_credentials.sh`. They prove that whatever the
 generator wrote is observable through the global call sites the Health
 example app uses.
 */
@Suite("CredentialsManager — generated enum re-export")
struct CredentialsSmokeTests {

    @Test("Generated Credentials enum exposes every expected key")
    func credentialsEnumExposesAllKeys() {
        /// Compile-time proof the generated enum has every expected field.
        /// If the generator shape drifts, this suite fails to build.
        #expect(!Credentials.clientID.isEmpty,
                "`.env.local` must populate GINI_CLIENT_ID before this suite runs.")
        _ = Credentials.clientPassword
        _ = Credentials.clientDomain
    }

    @Test("CredentialsManager globals mirror the generated Credentials enum")
    func globalsMatchGeneratedEnum() {
        #expect(clientID == Credentials.clientID)
        #expect(clientPassword == Credentials.clientPassword)
        #expect(clientDomain == Credentials.clientDomain)
    }
}
