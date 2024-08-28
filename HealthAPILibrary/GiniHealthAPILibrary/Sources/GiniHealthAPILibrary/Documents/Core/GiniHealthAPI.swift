//
//  GiniHealthAPI.swift
//  GiniHealthAPI
//
//  Created by Enrique del Pozo Gómez on 4/3/19.
//

import Foundation

/// The Gini Health API Library
public final class GiniHealthAPI {
    
    private var docService: DocumentService!
    private var payService: PaymentService?
    static var logLevel: LogLevel = .none
    public var sessionDelegate: URLSessionDelegate? = nil

    init<T: DocumentService>(documentService: T, paymentService: PaymentService? )
    {
        self.docService = documentService
        self.payService = paymentService
    }
    
    /**
     * The instance of a `DocumentService` that is used by the Gini Health API Library. The `DocumentService` allows the interaction with
     * the Gini Health API.
     */
    public func documentService<T: DocumentService>() -> T {
        guard docService is T else {
            preconditionFailure("In order to use a \(T.self), you have to specify its corresponding api " +
                "domain when building the GiniHealthAPILib")
        }
        //swiftlint:disable force_cast
        return docService as! T
    }
    
    /**
     * The instance of a `PaymentService` that is used by the Gini Health API Library. The `PaymentService` allows the interaction with payment functionality ofthe Gini Health API
     *
     */
    public func paymentService(apiDomain: APIDomain = .default, apiVersion: Int = Constants.defaultVersionAPI) -> PaymentService {
        return payService ?? PaymentService(sessionManager: SessionManager(userDomain: .default), apiDomain: apiDomain, apiVersion: apiVersion)
    }
    
    /// Removes the user stored credentials. Recommended when logging a different user in your app.
    public func removeStoredCredentials() throws {
        let keychainStore: KeyStore = KeychainStore()
        try keychainStore.remove(service: .auth, key: .userAccessToken)
        try keychainStore.remove(service: .auth, key: .userEmail)
        try keychainStore.remove(service: .auth, key: .userPassword)
    }
}

// MARK: - Builder

extension GiniHealthAPI {
    /// Builds a Gini Health API Library
    public struct Builder {
        var client: Client
        var api: APIDomain = .default
        let apiVersion: Int
        var userApi: UserDomain = .default
        var logLevel: LogLevel
        public var sessionDelegate: URLSessionDelegate? = nil
        
        /**
         *  Creates a Gini Health API Library
         *
         * - Parameter client:            The Gini Health API client credentials
         * - Parameter api:               The Gini Health API that the library interacts with. `APIDomain.default` by default
         * - Parameter userApi:           The Gini User API that the library interacts with. `UserDomain.default` by default
         * - Parameter logLevel:          The log level. `LogLevel.none` by default.
         * - Parameter sessionDelegate:   The session delegate `URLSessionDelegate` will be set for Gini Health API Library with `Pinning`.
         */
        public init(client: Client,
                    api: APIDomain = .default,
                    userApi: UserDomain = .default,
                    logLevel: LogLevel = .none,
                    sessionDelegate: URLSessionDelegate? = nil) {
            self.client = client
            self.api = api
            self.userApi = userApi
            self.logLevel = logLevel
            self.sessionDelegate = sessionDelegate
            self.apiVersion = client.apiVersion
        }
        
        /**
         * Creates a Gini Health API Library to be used with a transparent proxy and a custom api access token source.
         */
        public init(customApiDomain: String,
                    alternativeTokenSource: AlternativeTokenSource,
                    apiVersion: Int,
                    logLevel: LogLevel = .none,
                    sessionDelegate: URLSessionDelegate? = nil) {
            self.client = Client(id: "", secret: "", domain: "")
            self.api = .custom(domain: customApiDomain, tokenSource: alternativeTokenSource)
            self.apiVersion = apiVersion
            self.logLevel = logLevel
            self.sessionDelegate = sessionDelegate
        }

        public func build() -> GiniHealthAPI {
            // Save client information
            save(client)

            // Initialize logger
            GiniHealthAPI.logLevel = logLevel

            // Initialize GiniHealthAPILib
            switch api {
            case .default, .merchant:
                return createHealthAPI()
            case let .custom(_, tokenSource):
                return createHealthAPI(tokenSource: tokenSource)
            }
        }

        private func createHealthAPI(tokenSource: AlternativeTokenSource? = nil) -> GiniHealthAPI {
            var sessionManager: SessionManager
            if let tokenSource = tokenSource {
                sessionManager = SessionManager(alternativeTokenSource: tokenSource,
                                                sessionDelegate: self.sessionDelegate)
            } else {
                sessionManager = SessionManager(userDomain: userApi,
                                                sessionDelegate: self.sessionDelegate)
            }
            return GiniHealthAPI(documentService: DefaultDocumentService(sessionManager: sessionManager,
                                                                         apiDomain: api,
                                                                         apiVersion: apiVersion),
                                 paymentService: PaymentService(sessionManager: sessionManager,
                                                                apiDomain: api,
                                                                apiVersion: apiVersion))
        }

        private func save(_ client: Client) {
            do {
                try KeychainStore().save(item: KeychainManagerItem(key: .clientId,
                                                                   value: client.id,
                                                                   service: .auth))
                try KeychainStore().save(item: KeychainManagerItem(key: .clientSecret,
                                                                   value: client.secret,
                                                                   service: .auth))
                try KeychainStore().save(item: KeychainManagerItem(key: .clientDomain,
                                                                   value: client.domain,
                                                                   service: .auth))
            } catch {
                assertionFailure("There was an error using the Keychain. " +
                    "Check that the Keychain capability is enabled in your project")
            }
        }
    }
}

extension GiniHealthAPI {
    public enum Constants {
        public static let defaultVersionAPI = 4
    }
}
