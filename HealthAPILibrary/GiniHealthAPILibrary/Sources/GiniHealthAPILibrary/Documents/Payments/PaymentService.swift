//
//  PaymentService.swift
//  GiniHealthAPI
//
//  Created by Nadya Karaban on 15.03.21.
//

import Foundation

/// The payment service. Interacts with the `Gini Health API`  to support Gini Pay Connect functionality.

public final class PaymentService: PaymentServiceProtocol {
    
    /**
     *  Returns a list of payment providers.
     *
     * - Parameter completion:    A completion callback, returning the payment list on success
     */
    
    public func paymentProviders(completion: @escaping CompletionResult<PaymentProviders>) {
        self.paymentProviders(resourceHandler: sessionManager.data, completion: completion)
    }

    /**
     *  Returns a payment provider.
     *
     * - Parameter id:            The the payment provider's unique identifier
     * - Parameter completion:    A completion callback, returning the payment provider on success
     */
    
    public func paymentProvider(id: String,
                                completion: @escaping CompletionResult<PaymentProvider>) {
        self.paymentProvider(id: id, resourceHandler: sessionManager.data, completion: completion)
    }
    
    
    /**
     *  Creates a payment request.
     *
     * - Parameter sourceDocumentLocation:  The URI of the source document whenever the payment details were                                                                                                  extracted by the Gini system beforehand (optional)
     * - Parameter paymentProvider:         The id of the target payment provider - see payment providers
     * - Parameter recipient:               The recipient of the payment
     * - Parameter iban:                    The iban (international bank account number) of the payment recipient
     * - Parameter bic:                     The bic (bank identifier code) for the payment
     * - Parameter amount:                  The amount of the paymentt
     * - Parameter purpose:                 The purpose of the payment, eg. the invoice or the customer identifier
     * - Parameter completion:              A completion callback, returning the payment request on success
     */
    
    public func createPaymentRequest(sourceDocumentLocation: String?,
                                     paymentProvider: String,
                                     recipient: String,
                                     iban: String,
                                     bic: String?,
                                     amount: String,
                                     purpose: String,
                                     completion: @escaping CompletionResult<String>) {
        let requestBody = PaymentRequestBody(sourceDocumentLocation: sourceDocumentLocation, paymentProvider: paymentProvider, recipient: recipient, iban: iban, bic: bic, amount: amount, purpose: purpose)
        self.createPaymentRequest(paymentRequestBody: requestBody, resourceHandler: sessionManager.data, completion: completion)
    }
    
    /**
     *  Returns a payment request.
     *
     * - Parameter id:            The the payment request's unique identifier
     * - Parameter completion:    A completion callback, returning the payment request on success
     */
    
    public func paymentRequest(id: String,
                               completion: @escaping CompletionResult<PaymentRequest>) {
        self.paymentRequest(id: id, resourceHandler: sessionManager.data, completion: completion)
    }
    
    /**
     *  Returns a list of payment requests.
     *
     * - Parameter limit:          The maximum number of payment requests to return (default 20), (optional)
     * - Parameter offset:         A starting offset (default 0), (optional)
     * - Parameter completion:     A completion callback, returning the request list on success
     */
    
    public func paymentRequests(limit: Int? = 20,
                                offset: Int? = 0,
                                completion: @escaping CompletionResult<PaymentRequests>) {
        self.paymentRequests(limit: limit, offset: offset, resourceHandler: sessionManager.data, completion: completion)
    }
    
    /**
     *  Resolves a payment request.
     *  A payment is sent by a payment provider in order to resolve a payment request after it was paid.
     *
     * - Parameter recipient:               The recipient of the payment
     * - Parameter iban:                    The iban (international bank account number) of the payment recipient
     * - Parameter bic:                     The bic (bank identifier code) for the payment
     * - Parameter amount:                  The amount of the paymentt
     * - Parameter purpose:                 The purpose of the payment, eg. the invoice or the customer identifier
     * - Parameter completion:              A completion callback, returning the resolved payment request structure on success
     */
    
    public func resolvePaymentRequest(id: String,
                                      recipient: String,
                                      iban: String,
                                      bic: String? = nil,
                                      amount: String,
                                      purpose: String,
                                      completion: @escaping CompletionResult<ResolvedPaymentRequest>) {
        let requestBody = ResolvingPaymentRequestBody(recipient: recipient, iban: iban, bic: bic, amount: amount, purpose: purpose)
        self.resolvePaymentRequest(id: id, resolvingPaymentRequestBody: requestBody, resourceHandler: sessionManager.data, completion: completion)
    }
    
    /**
     *  Returns a payment.
     *
     * - Parameter id:            The the payment request's unique identifier
     * - Parameter completion:    A completion callback, returning the payment on success
     */
    
    public func payment(id: String,
                        completion: @escaping CompletionResult<Payment>) {
        self.payment(id: id, resourceHandler: sessionManager.data, completion: completion)
    }

    let sessionManager: SessionManagerProtocol

    public var apiDomain: APIDomain

    init(sessionManager: SessionManagerProtocol, apiDomain: APIDomain = .default) {
        self.sessionManager = sessionManager
        self.apiDomain = apiDomain
    }
    
    public func file(urlString: String, completion: @escaping CompletionResult<Data>){
        self.file(urlString: urlString, resourceHandler: sessionManager.download, completion: completion)
    }
}

public protocol PaymentServiceProtocol: AnyObject {

    /**
     *  Returns a list of payment providers.
     *
     * - Parameter completion:    A completion callback, returning the payment list on success
     */
    
    func paymentProviders(completion: @escaping CompletionResult<PaymentProviders>)
    
    /**
     *  Returns a payment providers.
     *
     * - Parameter id:            The id of the payment provider
     * - Parameter completion:    A completion callback, returning the payment provider on success
     */

    func paymentProvider(id: String, completion: @escaping CompletionResult<PaymentProvider>)
    
    
    /**
     *  Creates a payment request.
     *
     * - Parameter sourceDocumentLocation:  The URI of the source document whenever the payment details were                                                                                                  extracted by the Gini system beforehand (optional)
     * - Parameter paymentProvider:         The id of the target payment provider - see payment providers
     * - Parameter recipient:               The recipient of the payment
     * - Parameter iban:                    The iban (international bank account number) of the payment recipient
     * - Parameter bic:                     The bic (bank identifier code) for the payment
     * - Parameter amount:                  The amount of the paymentt
     * - Parameter purpose:                 The purpose of the payment, eg. the invoice or the customer identifier
     * - Parameter completion:              A completion callback, returning the payment request on success
     */

    func createPaymentRequest(sourceDocumentLocation: String?,
                              paymentProvider: String,
                              recipient: String,
                              iban: String,
                              bic: String?,
                              amount: String,
                              purpose: String,
                              completion: @escaping CompletionResult<String>)
    
    /**
     *  Returns a payment request.
     *
     * - Parameter id:            The id of the payment request
     * - Parameter completion:    A completion callback, returning the payment request on success
     */
    
    func paymentRequest(id: String,
                        completion: @escaping CompletionResult<PaymentRequest>)
    
    /**
     *  Returns a list of payment requests.
     *
     * - Parameter limit:          The maximum number of payment requests to return (default 20), (optional)
     * - Parameter offset:         A starting offset (default 0), (optional)
     * - Parameter completion:     A completion callback, returning the request list on success
     */
    
    func paymentRequests(limit: Int?,
                         offset: Int?,
                         completion: @escaping CompletionResult<PaymentRequests>)
    /**
     *  Resolves a payment request
     *  A payment is sent by a payment provider in order to resolve a payment request after it was paid.
     *
     * - Parameter recipient:               The recipient of the payment
     * - Parameter iban:                    The iban (international bank account number) of the payment recipient
     * - Parameter bic:                     The bic (bank identifier code) for the payment
     * - Parameter amount:                  The amount of the paymentt
     * - Parameter purpose:                 The purpose of the payment, eg. the invoice or the customer identifier
     * - Parameter completion:              A completion callback, returning the resolved payment request structure on success
     */
    
    func resolvePaymentRequest(id: String,
                               recipient: String,
                               iban: String,
                               bic: String?,
                               amount: String,
                               purpose: String,
                               completion: @escaping CompletionResult<ResolvedPaymentRequest>)
    
    /**
     *  Returns a payment.
     *
     * - Parameter id:            The the payment request's unique identifier
     * - Parameter completion:    A completion callback, returning the payment on success
     */
    
    func payment(id: String,
                 completion: @escaping CompletionResult<Payment>)
}

extension PaymentService {
    
    func paymentProviders(resourceHandler: ResourceDataHandler<APIResource<[PaymentProviderResponse]>>,
                          completion: @escaping CompletionResult<PaymentProviders>) {
        let resource = APIResource<[PaymentProviderResponse]>(method: .paymentProviders, apiDomain: .default, httpMethod: .get)
        var providers = [PaymentProvider]()
        resourceHandler(resource, { result in
            switch result {
            case let .success(providersResponse):
                let dispatchGroup = DispatchGroup()
                for providerResponse in providersResponse {
                    dispatchGroup.enter()

                    self.file(urlString: providerResponse.iconLocation) { result in
                        switch result {
                        case let .success(imageData):
                            let provider = PaymentProvider(id: providerResponse.id, name: providerResponse.name, appSchemeIOS: providerResponse.appSchemeIOS, minAppVersion: providerResponse.minAppVersion, colors: providerResponse.colors, iconData: imageData)
                             providers.append(provider)
                        case let .failure(error):
                            completion(.failure(error))
                        }
                        dispatchGroup.leave()
                    }
                    
                }
                dispatchGroup.notify(queue: DispatchQueue.global()) {
                    completion(.success(providers))
                }

            case let .failure(error):
                completion(.failure(error))
            }
        })
    }

    func paymentProvider(id: String, resourceHandler: ResourceDataHandler<APIResource<PaymentProvider>>,
                         completion: @escaping CompletionResult<PaymentProvider>) {
        let resource = APIResource<PaymentProvider>(method: .paymentProvider(id: id), apiDomain: .default, httpMethod: .get)

        resourceHandler(resource, { result in
            switch result {
            case let .success(provider):
                completion(.success(provider))
            case let .failure(error):
                completion(.failure(error))
            }
        })
    }

    func createPaymentRequest(paymentRequestBody: PaymentRequestBody,
                              resourceHandler: ResourceDataHandler<APIResource<String>>,
                              completion: @escaping CompletionResult<String>) {
        let encoder = JSONEncoder()
        guard let jsonData = try? encoder.encode(paymentRequestBody)
        else {
            assertionFailure("The PaymentRequestBody cannot be encoded")
            return
        }
        let resource = APIResource<String>(method: .createPaymentRequest,
                                           apiDomain: apiDomain,
                                           httpMethod: .post,
                                           body: jsonData)
        resourceHandler(resource, { result in
            switch result {
            case let .success(paymentRequestUrl):
                guard let id = paymentRequestUrl.split(separator: "/").last else {
                    completion(.failure(.parseError(message: "Invalid payment request url: \(paymentRequestUrl)")))
                    return
                }
                completion(.success(String(id)))
            case let .failure(error):
                completion(.failure(error))
            }
        })
    }

    func paymentRequest(id: String, resourceHandler: ResourceDataHandler<APIResource<PaymentRequest>>,
                        completion: @escaping CompletionResult<PaymentRequest>) {
        let resource = APIResource<PaymentRequest>(method: .paymentRequest(id: id), apiDomain: .default, httpMethod: .get)

        resourceHandler(resource, { result in
            switch result {
            case let .success(paymentRequest):
                completion(.success(paymentRequest))
            case let .failure(error):
                completion(.failure(error))
            }
        })
    }

    func paymentRequests(limit: Int?,
                         offset: Int?, resourceHandler: ResourceDataHandler<APIResource<PaymentRequests>>,
                         completion: @escaping CompletionResult<PaymentRequests>) {
        let resource = APIResource<PaymentRequests>(method: .paymentRequests(limit: limit, offset: offset), apiDomain: .default, httpMethod: .get)

        resourceHandler(resource, { result in
            switch result {
            case let .success(paymentRequests):
                completion(.success(paymentRequests))
            case let .failure(error):
                completion(.failure(error))
            }
        })
    }

    func resolvePaymentRequest(id: String,
                               resolvingPaymentRequestBody: ResolvingPaymentRequestBody, resourceHandler: ResourceDataHandler<APIResource<ResolvedPaymentRequest>>,
                               completion: @escaping CompletionResult<ResolvedPaymentRequest>) {
        guard let json = try? JSONEncoder().encode(resolvingPaymentRequestBody)
        else {
            assertionFailure("The ResolvingPaymentRequestBody cannot be encoded")
            return
        }
        let resource = APIResource<ResolvedPaymentRequest>(method: .resolvePaymentRequest(id: id), apiDomain: .default, httpMethod: .post, body: json)

        resourceHandler(resource, { result in
            switch result {
            case let .success(resolvedPaymentRequest):
                completion(.success(resolvedPaymentRequest))
            case let .failure(error):
                completion(.failure(error))
            }
        })
    }

    func payment(id: String,
                 resourceHandler: ResourceDataHandler<APIResource<Payment>>,
                 completion: @escaping CompletionResult<Payment>) {
        let resource = APIResource<Payment>(method: .payment(id: id), apiDomain: .default, httpMethod: .get)

        resourceHandler(resource, { result in
            switch result {
            case let .success(payment):
                completion(.success(payment))
            case let .failure(error):
                completion(.failure(error))
            }
        })
    }
    
    func file(urlString: String,
                 resourceHandler: ResourceDataHandler<APIResource<Data>>,
                 completion: @escaping CompletionResult<Data>) {
        var resource = APIResource<Data>(method: .file(urlString: urlString), apiDomain: .default, httpMethod: .get)
        resource.fullUrlString = urlString
        resourceHandler(resource) { result in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
            
        }
    }
}


