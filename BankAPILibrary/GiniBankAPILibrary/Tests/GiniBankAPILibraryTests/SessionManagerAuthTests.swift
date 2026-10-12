//
//  SessionManagerAuthTests.swift
//  GiniBankAPI-Unit-Tests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import Foundation
@testable import GiniBankAPILibrary

// MARK: - Alternative token source

@Suite("SessionManager.logIn — alternative token source")
struct SessionManagerAlternativeTokenTests {

    /**
     Manual `AlternativeTokenSource` conformance that returns a fixed result.
     */
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

    @Test("Success stores the returned accessToken and completes with the token")
    func successStoresAccessToken() async {
        let token = Token(expiration: Date(timeIntervalSinceNow: 3600),
                          scope: "read",
                          type: "bearer",
                          accessToken: "alt-source-token")
        let stub = StubAlternativeTokenSource(result: .success(token))
        let sut = SessionManager(keyStore: KeychainStoreMock(),
                                 alternativeTokenSource: stub)

        let result: Result<Token, GiniError> = await withCheckedContinuation { continuation in
            sut.logIn { continuation.resume(returning: $0) }
        }

        #expect(sut.userAccessToken == "alt-source-token")
        switch result {
        case .success(let received):
            #expect(received.accessToken == "alt-source-token")
        case .failure(let error):
            Issue.record("Expected .success, got .failure(\(error))")
        }
    }
}

// MARK: - HTTP-driven paths (login + response handling)

/**
 Serialized because `URLProtocolMock.handler` is a shared static; every test in
 this suite mutates it and would otherwise clobber a sibling running in parallel.
 Both the login-flow tests and the response-shape tests live in the same suite
 for that reason — tests split across sibling `.serialized` suites are still
 eligible to run concurrently in Swift Testing.
 */
@Suite("SessionManager HTTP interactions", .serialized)
struct SessionManagerHTTPTests {

    /**
     Mutable call counter for tests that need to route responses by request order.
     */
    private final class CallCounter { var count = 0 }

    // MARK: Fixtures

    private static func tokenResponseData() -> Data {
        let url = Bundle.module.url(forResource: "tokenResponse", withExtension: "json")
        guard let url, let data = try? Data(contentsOf: url) else {
            fatalError("tokenResponse.json fixture missing")
        }
        return data
    }

    private static func okResponse(for request: URLRequest) -> HTTPURLResponse {
        URLProtocolMock.makeResponse(for: request, statusCode: 200)
    }

    private static func unauthorizedResponse(for request: URLRequest) -> HTTPURLResponse {
        URLProtocolMock.makeResponse(for: request, statusCode: 401)
    }

    // MARK: Doubles

    private static func makeConfiguration() -> URLSessionConfiguration {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolMock.self]
        return config
    }

    private static func seededKeychain(withUser: Bool) -> KeychainStoreMock {
        let store = KeychainStoreMock()
        try? store.save(item: KeychainManagerItem(key: .clientId, value: "id", service: .auth))
        try? store.save(item: KeychainManagerItem(key: .clientSecret, value: "secret", service: .auth))
        try? store.save(item: KeychainManagerItem(key: .clientDomain, value: "gini.net", service: .auth))
        if withUser {
            try? store.save(item: KeychainManagerItem(key: .userEmail, value: "old@user.gini", service: .auth))
            try? store.save(item: KeychainManagerItem(key: .userPassword, value: "old-password", service: .auth))
        }
        return store
    }

    // MARK: Tests

    @Test("Existing user with valid credentials receives access token")
    func existingUserSuccess() async {
        defer { URLProtocolMock.handler = nil }
        URLProtocolMock.handler = { request in
            (Self.okResponse(for: request), Self.tokenResponseData())
        }

        let sut = SessionManager(keyStore: Self.seededKeychain(withUser: true),
                                 urlSessionConfiguration: Self.makeConfiguration())

        let result: Result<Token, GiniError> = await withCheckedContinuation { continuation in
            sut.logIn { continuation.resume(returning: $0) }
        }

        #expect(sut.userAccessToken == "test-access-token")
        switch result {
        case .success(let token):
            #expect(token.accessToken == "test-access-token")
        case .failure(let error):
            Issue.record("Expected .success, got .failure(\(error))")
        }
    }

    @Test("Existing user rejected as unauthorized triggers user recreation")
    func existingUserUnauthorizedRecreates() async {
        defer { URLProtocolMock.handler = nil }
        let counter = CallCounter()
        let keychain = Self.seededKeychain(withUser: true)

        URLProtocolMock.handler = { request in
            counter.count += 1
            let query = request.url?.query ?? ""
            let path = request.url?.path ?? ""

            /// Call 1: fetch token for the old user → unauthorized, triggers recreation
            if query.contains("grant_type=password") && counter.count == 1 {
                return (Self.unauthorizedResponse(for: request), nil)
            }
            /// Client credentials fetch during user recreation
            if query.contains("grant_type=client_credentials") {
                return (Self.okResponse(for: request), Self.tokenResponseData())
            }
            /// User creation call — response body is a String; the SDK only checks status
            if path == "/api/users" {
                return (Self.okResponse(for: request), "user-created".data(using: .utf8))
            }
            /// Subsequent password token call for the freshly-created user → success
            if query.contains("grant_type=password") {
                return (Self.okResponse(for: request), Self.tokenResponseData())
            }
            fatalError("Unexpected request: \(request.url?.absoluteString ?? "nil")")
        }

        let sut = SessionManager(keyStore: keychain,
                                 urlSessionConfiguration: Self.makeConfiguration())

        let result: Result<Token, GiniError> = await withCheckedContinuation { continuation in
            sut.logIn { continuation.resume(returning: $0) }
        }

        #expect(sut.userAccessToken == "test-access-token")
        #expect(keychain.fetch(service: .auth, key: .userEmail) != "old@user.gini",
                "user credentials should have been rotated during recreation")
        switch result {
        case .success:
            break
        case .failure(let error):
            Issue.record("Expected .success after recreation, got .failure(\(error))")
        }
    }

    @Test("No stored user credentials triggers new-user creation and returns token")
    func newUserCreation() async {
        defer { URLProtocolMock.handler = nil }
        let keychain = Self.seededKeychain(withUser: false)

        URLProtocolMock.handler = { request in
            let query = request.url?.query ?? ""
            let path = request.url?.path ?? ""

            if query.contains("grant_type=client_credentials") {
                return (Self.okResponse(for: request), Self.tokenResponseData())
            }
            if path == "/api/users" {
                return (Self.okResponse(for: request), "user-created".data(using: .utf8))
            }
            if query.contains("grant_type=password") {
                return (Self.okResponse(for: request), Self.tokenResponseData())
            }
            fatalError("Unexpected request: \(request.url?.absoluteString ?? "nil")")
        }

        let sut = SessionManager(keyStore: keychain,
                                 urlSessionConfiguration: Self.makeConfiguration())

        let result: Result<Token, GiniError> = await withCheckedContinuation { continuation in
            sut.logIn { continuation.resume(returning: $0) }
        }

        #expect(sut.userAccessToken == "test-access-token")
        #expect(keychain.fetch(service: .auth, key: .userEmail) != nil,
                "new user credentials should be persisted after creation")
        #expect(keychain.fetch(service: .auth, key: .userPassword) != nil,
                "new user password should be persisted after creation")
        switch result {
        case .success:
            break
        case .failure(let error):
            Issue.record("Expected .success after new-user creation, got .failure(\(error))")
        }
    }

    // MARK: - Response-handling shape tests
    //
    // These drive `SessionManager.data(resource:)` directly (bypassing login) to
    // exercise the response classification in `handleResponse` / `handleSuccess`.

    private static func makeResponseSut() -> SessionManager {
        let sut = SessionManager(keyStore: Self.seededKeychain(withUser: false),
                                 urlSessionConfiguration: Self.makeConfiguration())
        /// Bypass login for these tests — they only care about response shape.
        sut.clientAccessToken = "dummy-client-token"
        sut.userAccessToken = "dummy-user-token"
        return sut
    }

    private static func tokenResource() -> UserResource<Token> {
        UserResource<Token>(method: .token(grantType: .clientCredentials),
                            userDomain: .default,
                            httpMethod: .get)
    }

    @Test("2xx with a decodable body returns .success")
    func success2xxReturnsDecodedValue() async {
        defer { URLProtocolMock.handler = nil }
        URLProtocolMock.handler = { request in
            (Self.okResponse(for: request), Self.tokenResponseData())
        }

        let sut = Self.makeResponseSut()
        let result: Result<Token, GiniError> = await withCheckedContinuation { continuation in
            sut.data(resource: Self.tokenResource()) { continuation.resume(returning: $0) }
        }

        switch result {
        case .success(let token):
            #expect(token.accessToken == "test-access-token")
        case .failure(let error):
            Issue.record("Expected .success, got .failure(\(error))")
        }
    }

    @Test("401 with empty body maps to .unauthorized")
    func unauthorized401MapsToGiniError() async {
        defer { URLProtocolMock.handler = nil }
        URLProtocolMock.handler = { request in
            (Self.unauthorizedResponse(for: request), Data())
        }

        let sut = Self.makeResponseSut()
        let result: Result<Token, GiniError> = await withCheckedContinuation { continuation in
            sut.data(resource: Self.tokenResource()) { continuation.resume(returning: $0) }
        }

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

    @Test("2xx with an undecodable body surfaces as .parseError")
    func success2xxWithEmptyBodyReturnsParseError() async {
        defer { URLProtocolMock.handler = nil }
        URLProtocolMock.handler = { request in
            /// Empty Data — URLSession delivers it as empty, not nil; JSONDecoder rejects it.
            (Self.okResponse(for: request), Data())
        }

        let sut = Self.makeResponseSut()
        let result: Result<Token, GiniError> = await withCheckedContinuation { continuation in
            sut.data(resource: Self.tokenResource()) { continuation.resume(returning: $0) }
        }

        switch result {
        case .success:
            Issue.record("Expected .failure, got .success")
        case .failure(let error):
            if case .parseError = error {
                break
            } else {
                Issue.record("Expected .parseError, got \(error)")
            }
        }
    }

    @Test("URLSession no-internet error maps to .noInternetConnection")
    func noInternetErrorMapsToGiniError() async {
        defer {
            URLProtocolMock.handler = nil
            URLProtocolMock.errorHandler = nil
        }
        URLProtocolMock.errorHandler = { _ in
            URLError(.notConnectedToInternet)
        }

        let sut = Self.makeResponseSut()
        let result: Result<Token, GiniError> = await withCheckedContinuation { continuation in
            sut.data(resource: Self.tokenResource()) { continuation.resume(returning: $0) }
        }

        switch result {
        case .success:
            Issue.record("Expected .failure, got .success")
        case .failure(let error):
            if case .noInternetConnection = error {
                break
            } else {
                Issue.record("Expected .noInternetConnection, got \(error)")
            }
        }
    }

    @Test("Status code outside 200–599 maps to .unknown")
    func outOfRangeStatusCodeMapsToUnknown() async {
        defer { URLProtocolMock.handler = nil }
        URLProtocolMock.handler = { request in
            /// 100 falls through both `200..<400` and `400...599`, hitting `handleResponse`'s default arm.
            (URLProtocolMock.makeResponse(for: request, statusCode: 100), Data())
        }

        let sut = Self.makeResponseSut()
        let result: Result<Token, GiniError> = await withCheckedContinuation { continuation in
            sut.data(resource: Self.tokenResource()) { continuation.resume(returning: $0) }
        }

        switch result {
        case .success:
            Issue.record("Expected .failure, got .success")
        case .failure(let error):
            if case .unknown = error {
                break
            } else {
                Issue.record("Expected .unknown, got \(error)")
            }
        }
    }

    @Test("Existing user rejected as non-.unauthorized error propagates without recreation")
    func existingUserNonUnauthorizedErrorPropagates() async {
        defer { URLProtocolMock.handler = nil }
        let keychain = Self.seededKeychain(withUser: true)

        URLProtocolMock.handler = { request in
            /// 500 → GiniError.outage — `handleExistingUser`'s `if case .unauthorized` misses,
            /// so the else-branch calls `completion(.failure(error))` without recreating the user.
            (URLProtocolMock.makeResponse(for: request, statusCode: 500), Data())
        }

        let sut = SessionManager(keyStore: keychain,
                                 urlSessionConfiguration: Self.makeConfiguration())

        let result: Result<Token, GiniError> = await withCheckedContinuation { continuation in
            sut.logIn { continuation.resume(returning: $0) }
        }

        #expect(keychain.fetch(service: .auth, key: .userEmail) == "old@user.gini",
                "user credentials should NOT have been rotated when the error is not .unauthorized")
        switch result {
        case .success:
            Issue.record("Expected .failure, got .success")
        case .failure(let error):
            if case .outage = error {
                break
            } else {
                Issue.record("Expected .outage from a 500 response, got \(error)")
            }
        }
    }

    @Test("Cancelled token surfaces .requestCancelled instead of the response")
    func cancelledTokenSurfacesRequestCancelled() async {
        defer { URLProtocolMock.handler = nil }
        URLProtocolMock.handler = { request in
            (Self.okResponse(for: request), Self.tokenResponseData())
        }

        let token = CancellationToken()
        token.cancel()

        let sut = Self.makeResponseSut()
        let result: Result<Token, GiniError> = await withCheckedContinuation { continuation in
            sut.data(resource: Self.tokenResource(),
                     cancellationToken: token) { continuation.resume(returning: $0) }
        }

        switch result {
        case .success:
            Issue.record("Expected .failure, got .success — cancelled token should short-circuit")
        case .failure(let error):
            if case .requestCancelled = error {
                break
            } else {
                Issue.record("Expected .requestCancelled, got \(error)")
            }
        }
    }

    @Test("URLError other than notConnectedToInternet maps to .noResponse")
    func nonNoInternetURLErrorMapsToNoResponse() async {
        defer {
            URLProtocolMock.handler = nil
            URLProtocolMock.errorHandler = nil
        }
        /// Any URLError code that isn't `.notConnectedToInternet` — falls through
        /// `handleNetworkError`'s guard (covers the else branch), then URLSession
        /// delivers a nil response so the `httpResponse as? HTTPURLResponse` guard
        /// completes with `.noResponse`.
        URLProtocolMock.errorHandler = { _ in
            URLError(.timedOut)
        }

        let sut = Self.makeResponseSut()
        let result: Result<Token, GiniError> = await withCheckedContinuation { continuation in
            sut.data(resource: Self.tokenResource()) { continuation.resume(returning: $0) }
        }

        switch result {
        case .success:
            Issue.record("Expected .failure, got .success")
        case .failure(let error):
            if case .noResponse = error {
                break
            } else {
                Issue.record("Expected .noResponse, got \(error)")
            }
        }
    }

    // MARK: - MockHTTPClient-driven tests
    //
    // Routes SessionManager through a custom `GiniHTTPClient` (bypassing URLSession
    // entirely) to hit branches URLProtocolMock cannot reach — specifically the
    // `guard let jsonData = data else` arm in `handleResponse`, which needs a nil
    // data payload URLSession never actually delivers.

    private static func makeSutWithMockClient(_ mock: MockHTTPClient) -> SessionManager {
        let sut = SessionManager(keyStore: Self.seededKeychain(withUser: false),
                                 customHTTPClient: mock)
        /// Bypass login for these response-shape tests.
        sut.clientAccessToken = "dummy-client-token"
        sut.userAccessToken = "dummy-user-token"
        return sut
    }

    private static func httpResponse(statusCode: Int) -> HTTPURLResponse {
        URLProtocolMock.makeResponse(for: URLRequest(url: URLProtocolMock.fallbackURL),
                                     statusCode: statusCode)
    }

    @Test("2xx response with nil data body maps to .unknown")
    func success2xxWithNilDataMapsToUnknown() async {
        let mock = MockHTTPClient()
        mock.dataResponse = (nil, Self.httpResponse(statusCode: 200), nil)

        let sut = Self.makeSutWithMockClient(mock)
        let result: Result<Token, GiniError> = await withCheckedContinuation { continuation in
            sut.data(resource: Self.tokenResource()) { continuation.resume(returning: $0) }
        }

        switch result {
        case .success:
            Issue.record("Expected .failure, got .success")
        case .failure(let error):
            if case .unknown = error {
                break
            } else {
                Issue.record("Expected .unknown from 2xx + nil data, got \(error)")
            }
        }
    }

    @Test("Non-cancelled token passes through and delivers the response")
    func nonCancelledTokenPassesThrough() async {
        let mock = MockHTTPClient()
        mock.dataResponse = (Self.tokenResponseData(),
                             Self.httpResponse(statusCode: 200),
                             nil)

        /// Fresh token, never cancelled — covers the branch where
        /// `cancellationToken != nil AND isCancelled == false` (the existing
        /// cancellation test only hits `isCancelled == true`, and all other
        /// tests pass `nil` for the token).
        let token = CancellationToken()

        let sut = Self.makeSutWithMockClient(mock)
        let result: Result<Token, GiniError> = await withCheckedContinuation { continuation in
            sut.data(resource: Self.tokenResource(),
                     cancellationToken: token) { continuation.resume(returning: $0) }
        }

        switch result {
        case .success(let received):
            #expect(received.accessToken == "test-access-token")
        case .failure(let error):
            Issue.record("Expected .success with a live token, got .failure(\(error))")
        }
    }
}
