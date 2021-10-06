//
//  SessionManager+Auth.swift
//  GiniPayApiLib
//
//  Created by Enrique del Pozo Gómez on 3/6/19.
//

import Foundation

extension SessionManager: SessionAuthenticationProtocol {
    
    var client: Client {
        guard let id = self.keyStore.fetch(service: .auth, key: .clientId),
            let secret = self.keyStore.fetch(service: .auth, key: .clientSecret),
            let domain = self.keyStore.fetch(service: .auth, key: .clientDomain) else {
                preconditionFailure("There should always be a client stored")
        }
        
        return Client(id: id, secret: secret, domain: domain)
    }
    
    var user: User? {
        guard let email = self.keyStore.fetch(service: .auth, key: .userEmail),
            let password = self.keyStore.fetch(service: .auth, key: .userPassword) else { return nil }
        
        return User(email: email, password: password)
    }
    
    func logIn(completion: @escaping CompletionResult<Token>) {
        
        let saveTokenAndComplete: (Result<Token, GiniError>) -> Void = { result in
            
            switch result {
            case .failure: break
            case .success(let token):
                
                do {
                    try self.keyStore.save(item: KeychainManagerItem(key: .userAccessToken,
                                                                     value: token.accessToken,
                                                                     service: .auth))
                    
                } catch {
                    preconditionFailure("Gini couldn't safely save the user credentials in the Keychain. " +
                        "Enable the 'Keychain Sharing' entitlement in your app")
                }
            }
            
            completion(result)
        }
        
        if let alternativeTokenSource = alternativeTokenSource {
            alternativeTokenSource.fetchToken(completion: saveTokenAndComplete)
        } else {
            
            if let user = user {
                
                fetchUserAccessToken(for: user, completion: saveTokenAndComplete)
                
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
    
    func logOut() {
        keyStore.removeAll()
    }
}

// MARK: - Fileprivate

fileprivate extension SessionManager {
    func createUser(completion: @escaping CompletionResult<User>) {
        fetchClientAccessToken { result in
            switch result {
            case .success:
                let domain = self.keyStore.fetch(service: .auth, key: .clientDomain) ?? "no-domain-specified"
                let user = AuthHelper.generateUser(with: domain)
                
                let resource = UserResource<String>(method: .users,
                                                    userDomain: self.userDomain,
                                                    httpMethod: .post,
                                                    body: try? JSONEncoder().encode(user))

                self.data(resource: resource) { result in
                    switch result {
                    case .success:
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
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
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
    
    func fetchClientAccessToken(completion: @escaping CompletionResult<Void>) {
        let resource = UserResource<Token>(method: .token(grantType: .clientCredentials),
                                           userDomain: self.userDomain,
                                           httpMethod: .get)
        data(resource: resource) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let token):
                do {
                    try self.keyStore.save(item: KeychainManagerItem(key: .clientAccessToken,
                                                                     value: token.accessToken,
                                                                     service: .auth))
                    completion(.success(()))
                } catch {
                    preconditionFailure("Gini couldn't safely save the user credentials in the Keychain. " +
                        "Enable the 'Keychain Sharing' entitlement in your app")
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
