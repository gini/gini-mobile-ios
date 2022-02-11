//
//  PaymentService.swift
//  GiniBankAPI
//
//  Created by Nadya Karaban on 15.03.21.
//

import Foundation

/// The payment service. Interacts with the `Gini Bank API` to support Gini Pay Connect functionality.

public final class PaymentService: PaymentServiceProtocol {
    
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
}

public protocol PaymentServiceProtocol: AnyObject {
    
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
}
