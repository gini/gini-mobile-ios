//
//  SessionManager+Auth.swift
//  GiniHealthAPI
//
//  Created by Enrique del Pozo Gómez on 3/6/19.
//

import Foundation

extension SessionManager: SessionAuthenticationProtocol {
    
    var client: Client {
        if let id = self.keyStore.fetch(service: .auth, key: .clientId),
           let secret = self.keyStore.fetch(service: .auth, key: .clientSecret),
           let domain = self.keyStore.fetch(service: .auth, key: .clientDomain) {
            return Client(id: id, secret: secret, domain: domain)
        } else {
            assertionFailure("There should always be a client stored")
            return Client(id: "", secret: "", domain: "")
        }
    }
    
    var user: User? {
        guard let email = self.keyStore.fetch(service: .auth, key: .userEmail),
            let password = self.keyStore.fetch(service: .auth, key: .userPassword) else { return nil }
        
        return User(email: email, password: password)
    }
    
    func logIn(completion: @escaping CompletionResult<Token>) {
        
        let saveTokenAndComplete: (Result<Token, GiniError>) -> Void = { result in
            
            switch result {
            case .failure:
                self.removeUserAccessToken()
            case .success(let token):
                self.userAccessToken = token.accessToken
            }
            
            completion(result)
        }
        
        if let alternativeTokenSource = alternativeTokenSource {
            alternativeTokenSource.fetchToken(completion: saveTokenAndComplete)
        } else {
            if let user = user {
                fetchUserAccessToken(for: user) { [weak self]  result in
                    guard let self = self else { return }
                    switch result {
                    case .success:
                        saveTokenAndComplete(result)
                    case .failure(let error):
                        if case .unauthorized = error {
                            self.handleUnauthorizedUserCreation(completion: saveTokenAndComplete)
                        } else {
                            completion(.failure(error))
                        }
                    }
                }
            } else {
                createUser { result in
                    switch result {
                    case .success(let user):
                        self.fetchUserAccessToken(for: user, completion: saveTokenAndComplete)
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }

    private func handleUnauthorizedUserCreation(completion: @escaping (Result<Token, GiniError>) -> Void) {
        self.removeCurrentUserInfo()
        self.createUser { result in
            switch result {
                case .success(let user):
                self.fetchUserAccessToken(for: user, completion: completion)
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }

    func logOut() {       
        // Remove current user info from SessionManager
        userAccessToken = nil
        clientAccessToken = nil

        // Remove current user info from Keychain
        keyStore.removeAll()
    }

    private func removeUserAccessToken() {
        // Remove current userAccessToken from SessionManager
        userAccessToken = nil

        // removing `userAccessToken` from Keychain is part of the old implementation where it was saved in Keychain
        do {
            try KeychainStore().remove(service: .auth, key: .userAccessToken)
        } catch {
            preconditionFailure("Gini couldn't remove the `userAccessToken` from Keychain.")
        }
    }

    private func removeClientAccessToken() {
        // Remove current clientAccessToken from SessionManager
        clientAccessToken = nil

        // removing  `clientAccessToken` from Keychain is part of the old implementation where it was saved in Keychain
        do {
            try KeychainStore().remove(service: .auth, key: .clientAccessToken)
        } catch {
            preconditionFailure("Gini couldn't remove the `clientAccessToken` from Keychain.")
        }
    }

    private func removeCurrentUserInfo() {
        removeUserAccessToken()
        removeClientAccessToken()

        do {
            try self.keyStore.remove(service: .auth, key: .userEmail)
            try self.keyStore.remove(service: .auth, key: .userPassword)
        } catch {
            preconditionFailure("Gini couldn't remove current user info from the Keychain.")
        }
    }
}

// MARK: - Fileprivate

fileprivate extension SessionManager {
    func createUser(completion: @escaping CompletionResult<User>) {
        fetchClientAccessToken { result in
            switch result {
            case .success(let token):
                self.clientAccessToken = token.accessToken
                let domain = self.keyStore.fetch(service: .auth, key: .clientDomain) ?? "no-domain-specified"
                let user = AuthHelper.generateUser(with: domain)

                let resource = UserResource<String>(method: .users,
                                                    userDomain: self.userDomain,
                                                    httpMethod: .post,
                                                    body: try? JSONEncoder().encode(user))

                self.handleDataResource(resource, for: user, completion: completion)

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func handleDataResource(_ resource: UserResource<String>, for user: User, completion: @escaping CompletionResult<User>) {
        self.data(resource: resource) { result in
            switch result {
            case .success:
                self.storeUserCredentials(for: user,
                                          completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    func fetchUserAccessToken(for user: User,
                              completion: @escaping CompletionResult<Token>) {
        let body = "username=\(user.email)&password=\(user.password)"
            .addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)?
            .data(using: .utf8)
        
        let resource = UserResource<Token>(method: .token(grantType: .password),
                                           userDomain: self.userDomain,
                                           httpMethod: .post,
                                           body: body)
        
        data(resource: resource, completion: completion)
    }
    
    func fetchClientAccessToken(completion: @escaping CompletionResult<Token>) {
        let resource = UserResource<Token>(method: .token(grantType: .clientCredentials),
                                           userDomain: self.userDomain,
                                           httpMethod: .get)
        data(resource: resource, completion: completion)
    }

    private func storeUserCredentials(for user: User,
                                      completion: @escaping CompletionResult<User>) {
        do {
            try self.keyStore.save(item: KeychainManagerItem(key: .userEmail,
                                                             value: user.email,
                                                             service: .auth))
            try self.keyStore.save(item: KeychainManagerItem(key: .userPassword,
                                                             value: user.password,
                                                             service: .auth))
            completion(.success((user)))
        } catch {
            preconditionFailure("Gini couldn't safely save the user credentials in the Keychain. " +
                                "Enable the 'Keychain Sharing' entitlement in your app")
        }
    }
}
