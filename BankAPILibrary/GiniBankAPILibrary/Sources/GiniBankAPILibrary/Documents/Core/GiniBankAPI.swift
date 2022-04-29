//
//  GiniBankAPI.swift
//  GiniBankAPI
//
//  Created by Enrique del Pozo Gómez on 4/3/19.
//

import Foundation

/// The Gini Bank API Library
public final class GiniBankAPI {
    
    private let docService: DocumentService!
    private let payService: PaymentService?
    static var logLevel: LogLevel = .none

    init<T: DocumentService>(documentService: T, paymentService: PaymentService? )
    {
        self.docService = documentService
        self.payService = paymentService
    }
    
    /**
     * The instance of a `DocumentService` that is used by the Gini Bank API Library. The `DocumentService` allows the interaction with
     * the Gini Bank API.
     */
    public func documentService<T: DocumentService>() -> T {
        guard docService is T else {
            preconditionFailure("In order to use a \(T.self), you have to specify its corresponding api " +
                "domain when building the GiniBankAPILib")
        }
        //swiftlint:disable force_cast
        return docService as! T
    }
    
    /**
     * The instance of a `PaymentService` that is used by the Gini Bank API Library. The `PaymentService` allows the interaction with payment functionality of the Gini Bank API.
     *
     */
    public func paymentService() -> PaymentService {
        return payService ?? PaymentService(sessionManager: SessionManager(userDomain: .default), apiDomain: .default)
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

extension GiniBankAPI {
    /// Builds a Gini Bank API Library
    public struct Builder {
        var client: Client
        var api: APIDomain = .default
        var userApi: UserDomain = .default
        var logLevel: LogLevel
        
        /**
         *  Creates a Gini Bank API Library
         *
         * - Parameter client:            The Gini Bank API client credentials
         * - Parameter api:               The Gini Bank API that the library interacts with. `APIDomain.default` by default
         * - Parameter userApi:           The Gini User API that the library interacts with. `UserDomain.default` by default
         * - Parameter logLevel:          The log level. `LogLevel.none` by default.
         */
        public init(client: Client,
                    api: APIDomain = .default,
                    userApi: UserDomain = .default,
                    logLevel: LogLevel = .none) {
            self.client = client
            self.api = api
            self.userApi = userApi
            self.logLevel = logLevel
        }
        
        public init(sessionManager: SessionManager,
                    api: APIDomain = .default,
                    logLevel: LogLevel = .none) {
            self.client = sessionManager.client
            self.api = api
            self.userApi = sessionManager.userDomain
            self.logLevel = logLevel
        }
        
        /**
         * Creates a Gini Bank API Library to be used with a transparent proxy and a custom api access token source.
         */
        public init(customApiDomain: String,
                    alternativeTokenSource: AlternativeTokenSource,
                    logLevel: LogLevel = .none) {
            self.client = Client(id: "", secret: "", domain: "")
            self.api = .custom(domain: customApiDomain, tokenSource: alternativeTokenSource)
            self.logLevel = logLevel
        }

        public func build() -> GiniBankAPI {
            // Save client information
            save(client)

            // Initialize logger
            GiniBankAPI.logLevel = logLevel

            // Initialize GiniBankAPI
            switch api {
            case .accounting:
                let sessionManager = SessionManager(userDomain: userApi)
                return GiniBankAPI(documentService: AccountingDocumentService(sessionManager: SessionManager(userDomain: userApi)), paymentService: PaymentService(sessionManager: sessionManager, apiDomain: .default))
            case .default:
                let sessionManager = SessionManager(userDomain: userApi)
                return GiniBankAPI(documentService: DefaultDocumentService(sessionManager: sessionManager), paymentService: PaymentService(sessionManager: sessionManager, apiDomain: .default))
            case .custom(_, let tokenSource):
                var sessionManager : SessionManager
                if let tokenSource = tokenSource {
                     sessionManager = SessionManager(alternativeTokenSource: tokenSource)
                } else {
                    sessionManager = SessionManager(userDomain: userApi)
                }
                return GiniBankAPI(documentService: DefaultDocumentService(sessionManager: sessionManager,apiDomain: api), paymentService: PaymentService(sessionManager: sessionManager, apiDomain: api))
            case let .gym(tokenSource):
                let sessionManager = SessionManager(alternativeTokenSource: tokenSource)
                return GiniBankAPI(documentService: DefaultDocumentService(sessionManager:
                                                                            sessionManager), paymentService: PaymentService(sessionManager: sessionManager))
            }
        }
        
        public func buildForPinning(pinningDelegate: URLSessionDelegate) -> GiniBankAPI {
            // Save client information
            save(client)

            // Initialize logger
            GiniBankAPI.logLevel = logLevel

            // Initialize GiniBankAPI
            switch api {
            case .accounting:
                let sessionManager = SessionManager(userDomain: userApi, pinningDelegate: pinningDelegate)
                return GiniBankAPI(documentService: AccountingDocumentService(sessionManager: sessionManager), paymentService: PaymentService(sessionManager: sessionManager, apiDomain: .default))
            case .default:
                let sessionManager = SessionManager(userDomain: userApi, pinningDelegate: pinningDelegate)
                return GiniBankAPI(documentService: DefaultDocumentService(sessionManager: sessionManager), paymentService: PaymentService(sessionManager: sessionManager, apiDomain: .default))
            case .custom(_, let tokenSource):
                var sessionManager : SessionManager
                if let tokenSource = tokenSource {
                     sessionManager = SessionManager(alternativeTokenSource: tokenSource, pinningDelegate: pinningDelegate)
                } else {
                    sessionManager = SessionManager(userDomain: userApi, pinningDelegate: pinningDelegate)
                }
                return GiniBankAPI(documentService: DefaultDocumentService(sessionManager: sessionManager,apiDomain: api), paymentService: PaymentService(sessionManager: sessionManager, apiDomain: api))
            case let .gym(tokenSource):
                let sessionManager = SessionManager(alternativeTokenSource: tokenSource)
                return GiniBankAPI(documentService: DefaultDocumentService(sessionManager:
                                                                            sessionManager), paymentService: PaymentService(sessionManager: sessionManager))
            }
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
                preconditionFailure("There was an error using the Keychain. " +
                    "Check that the Keychain capability is enabled in your project")
            }
        }
    }
}
