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
    private let configService: ClientConfigurationServiceProtocol?
    static var logLevel: LogLevel = .none

    init<T: DocumentService>(documentService: T,
                             paymentService: PaymentService?,
                             configurationService: ClientConfigurationServiceProtocol?) {
        self.docService = documentService
        self.payService = paymentService
        self.configService = configurationService
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
    
    public func configurationService() -> ClientConfigurationServiceProtocol? {
        return configService
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
        public var sessionDelegate: URLSessionDelegate? = nil
        
        /**
         *  Creates a Gini Bank API Library.
         *
         * - Parameter client:            The Gini Bank API client credentials
         * - Parameter api:               The Gini Bank API that the library interacts with. `APIDomain.default` by default
         * - Parameter userApi:           The Gini User API that the library interacts with. `UserDomain.default` by default
         * - Parameter logLevel:          The log level. `LogLevel.none` by default.
         * - Parameter sessionDelegate:   The session delegate `URLSessionDelegate` will be set for Gini Bank API Library with `Pinning`.
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
        }
        
        /**
         * Creates a Gini Bank API Library to be used with a transparent proxy and a custom api access token source.
         */
        public init(customApiDomain: String = APIDomain.default.domainString,
                    alternativeTokenSource: AlternativeTokenSource,
                    logLevel: LogLevel = .none,
                    sessionDelegate: URLSessionDelegate? = nil) {
            self.client = Client(id: "", secret: "", domain: "")
            self.api = .custom(domain: customApiDomain, tokenSource: alternativeTokenSource)
            self.logLevel = logLevel
            self.sessionDelegate = sessionDelegate
        }

        public func build() -> GiniBankAPI {
            // Save client information
            save(client)

            // Initialize logger
            GiniBankAPI.logLevel = logLevel

            // Initialize GiniBankAPI
            let sessionManager = createSessionManager()
            let documentService = DefaultDocumentService(sessionManager: sessionManager, apiDomain: api)
            let paymentService = PaymentService(sessionManager: sessionManager, apiDomain: api)
            let configurationService = ClientConfigurationService(sessionManager: sessionManager, apiDomain: api)

            return GiniBankAPI(documentService: documentService, 
                               paymentService: paymentService,
                               configurationService: configurationService)
        }
        
        private func createSessionManager() -> SessionManager {
            switch api {
            case .default:
                return SessionManager(userDomain: userApi, sessionDelegate: self.sessionDelegate)
            case .custom(_, _, let tokenSource):
                if let tokenSource = tokenSource {
                    return SessionManager(alternativeTokenSource: tokenSource, sessionDelegate: self.sessionDelegate)
                } else {
                    return SessionManager(userDomain: userApi, sessionDelegate: self.sessionDelegate)
                }
            }
        }
        
        private func save(_ client: Client) {
            guard !runningUnitTests() else { return }
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

        private func runningUnitTests() -> Bool {
            #if canImport(XCTest)
            return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
            #else
            return false
            #endif
        }
    }
}
