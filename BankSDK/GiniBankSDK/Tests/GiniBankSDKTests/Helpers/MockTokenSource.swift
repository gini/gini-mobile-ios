//
//  MockTokenSource.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

@testable import GiniBankAPILibrary

class MockTokenSource: AlternativeTokenSource {
    var token: Token?

    init(token: Token? = nil) {
        self.token = token
    }

    func fetchToken(completion: @escaping (Result<Token, GiniError>) -> Void) {
        if let token {
            completion(.success(token))
        } else {
            completion(.failure(.requestCancelled))
        }
    }
}
