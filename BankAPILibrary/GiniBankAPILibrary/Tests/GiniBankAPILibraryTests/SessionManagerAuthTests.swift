//
//  SessionManagerAuthTests.swift
//  GiniBankAPI-Unit-Tests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import Foundation
@testable import GiniBankAPILibrary

@Suite("SessionManager.logIn — alternative token source")
struct SessionManagerAlternativeTokenTests {

    /// Manual `AlternativeTokenSource` conformance that returns a fixed result.
    private final class StubAlternativeTokenSource: AlternativeTokenSource {
        let result: Result<Token, GiniError>

        init(result: Result<Token, GiniError>) {
            self.result = result
        }

        func fetchToken(completion: @escaping (Result<Token, GiniError>) -> Void) {
            completion(result)
        }
    }

    @Test("Failure surfaces as .failure and clears userAccessToken")
    func failurePropagatesAndClearsToken() async {
        let stub = StubAlternativeTokenSource(result: .failure(.unauthorized()))
        let sut = SessionManager(keyStore: KeychainStoreMock(),
                                 alternativeTokenSource: stub)
        sut.userAccessToken = "stale-token"

        let result: Result<Token, GiniError> = await withCheckedContinuation { continuation in
            sut.logIn { continuation.resume(returning: $0) }
        }

        #expect(sut.userAccessToken == nil,
                "userAccessToken should be cleared on alt-token failure")
        switch result {
        case .success:
            Issue.record("Expected .failure, got .success")
        case .failure(let error):
            if case .unauthorized = error {
                break
            } else {
                Issue.record("Expected .unauthorized, got \(error)")
            }
        }
    }
}
