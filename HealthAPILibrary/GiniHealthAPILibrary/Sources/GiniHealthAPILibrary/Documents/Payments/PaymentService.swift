//
//  PaymentService.swift
//  GiniHealthAPI
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
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
     *  Deletes a payment request.
     *
     * - Parameter id:                 The the payment request's unique identifier
     * - Parameter completion:         A completion callback, returning the payment request's unique identifier on success
     */
    
    public func deletePaymentRequest(id: String,
                                     completion: @escaping CompletionResult<String>) {
        self.deletePaymentRequest(id: id, resourceHandler: sessionManager.data, completion: completion)
    }
    
    /**
    *  Deletes a batch of payment request
    *
    * - Parameter ids:                                  An array of paymen request ids to be deleted
    * - Parameter completion:                     An action for deleting a batch of payment request. Result is a value that represents either a success or a failure, including an associated value in each case.
                                       In success it includes an array of deleted ids
                                       In case of failure error from the server side.
    */
   public func deletePaymentRequests(_ ids: [String],
                                     completion: @escaping CompletionResult<[String]>) {
       self.deletePaymentRequests(ids,
                                  resourceHandler: sessionManager.data,
                                  completion: completion)
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
    public var apiVersion: Int

    init(sessionManager: SessionManagerProtocol, apiDomain: APIDomain = .default, apiVersion: Int) {
        self.sessionManager = sessionManager
        self.apiDomain = apiDomain
        self.apiVersion = apiVersion
    }
    
    func file(urlString: String, completion: @escaping CompletionResult<Data>){
        file(urlString: urlString, resourceHandler: sessionManager.download, completion: completion)
    }

    /**
     *  Returns a pdf data with a payment request in QR code.
     *
     * - Parameter paymentRequestId: The the payment request's unique identifie
     * - Parameter completion:       A completion callback, returning the pdf document with the payment details in QR Code on success
     */

    public func pdfWithQRCode(paymentRequestId: String,
                               completion: @escaping CompletionResult<Data>){
        pdfWithQRCode(paymentRequestId: paymentRequestId,
                      mimeSubtype: .pdf,
                      resourceHandler: sessionManager.data,
                      completion: completion)
    }
    
    /**
     *  Returns a QR Code image with a payment request in PNG format.
     *
     * - Parameter paymentRequestId: The payment request's unique identifier.
     * - Parameter completion:       A completion callback, returning the QR Code image in PNG format on success.
     */
    public func qrCodeImage(paymentRequestId: String,
                            completion: @escaping CompletionResult<Data>) {
        pdfWithQRCode(paymentRequestId: paymentRequestId,
                      mimeSubtype: .png,
                      resourceHandler: sessionManager.data,
                      completion: completion)
    }
}

protocol PaymentServiceProtocol: AnyObject {

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
     *  Deletes a payment request.
     *
     * - Parameter id:                 The the payment request's unique identifier
     * - Parameter completion:         A completion callback, returning the payment's'request unique identifier on success
     */
    
    func deletePaymentRequest(id: String,
                              completion: @escaping CompletionResult<String>)
    
    /**
    *  Deletes a batch of payment request
    *
    * - Parameter ids:                                    An array of payment request ids to be deleted
    * - Parameter completion:                       An action for deleting a batch of payment request. Result is a value that represents either a success or a failure, including an associated value in each case.
                                       In success it includes an array of deleted ids
                                       In case of failure error from the server side.
    */
   func deletePaymentRequests(_ ids: [String],
                              completion: @escaping CompletionResult<[String]>)
    
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
     *  Returns a payment.
     *
     * - Parameter id:            The the payment request's unique identifier
     * - Parameter completion:    A completion callback, returning the payment on success
     */

    func payment(id: String,
                 completion: @escaping CompletionResult<Payment>)

    /**
     *  Returns a pdf data with a payment request in QR code.
     *
     * - Parameter paymentRequestId: The the payment request's unique identifie
     * - Parameter completion:       A completion callback, returning the pdf document with the payment details in QR Code on success
     */

    func pdfWithQRCode(paymentRequestId: String,
                       completion: @escaping CompletionResult<Data>)
}

extension PaymentService {
    
    func paymentProviders(resourceHandler: ResourceDataHandler<APIResource<[PaymentProviderResponse]>>,
                          completion: @escaping CompletionResult<PaymentProviders>) {
        let resource = APIResource<[PaymentProviderResponse]>(method: .paymentProviders, apiDomain: apiDomain, apiVersion: apiVersion, httpMethod: .get)
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
                            let provider = PaymentProvider(id: providerResponse.id, name: providerResponse.name, appSchemeIOS: providerResponse.appSchemeIOS, minAppVersion: providerResponse.minAppVersion, colors: providerResponse.colors, iconData: imageData, appStoreUrlIOS: providerResponse.appStoreUrlIOS, universalLinkIOS: providerResponse.universalLinkIOS, index: providerResponse.index, gpcSupportedPlatforms: providerResponse.gpcSupportedPlatforms, openWithSupportedPlatforms: providerResponse.openWithSupportedPlatforms)
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

    func paymentProvider(id: String, resourceHandler: ResourceDataHandler<APIResource<PaymentProviderResponse>>,
                         completion: @escaping CompletionResult<PaymentProvider>) {
        let resource = APIResource<PaymentProviderResponse>(method: .paymentProvider(id: id), apiDomain: apiDomain, apiVersion: apiVersion, httpMethod: .get)

        resourceHandler(resource, { result in
            switch result {
            case let .success(providerResponse):
                self.file(urlString: providerResponse.iconLocation) { result in
                    switch result {
                    case let .success(imageData):
                        let provider = PaymentProvider(id: providerResponse.id, name: providerResponse.name, appSchemeIOS: providerResponse.appSchemeIOS, minAppVersion: providerResponse.minAppVersion, colors: providerResponse.colors, iconData: imageData, appStoreUrlIOS: providerResponse.appStoreUrlIOS, universalLinkIOS: providerResponse.universalLinkIOS, index: providerResponse.index, gpcSupportedPlatforms: providerResponse.gpcSupportedPlatforms, openWithSupportedPlatforms: providerResponse.openWithSupportedPlatforms)
                        completion(.success(provider))
                    case let .failure(error):
                        completion(.failure(error))
                    }
                }
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
                                           apiVersion: apiVersion,
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
    
    func deletePaymentRequest(id: String,
                              resourceHandler: ResourceDataHandler<APIResource<String>>,
                              completion: @escaping CompletionResult<String>) {
        let resource = APIResource<String>(method: .paymentRequest(id: id),
                                           apiDomain: apiDomain,
                                           apiVersion: apiVersion,
                                           httpMethod: .delete)
        
        resourceHandler(resource, { result in
            switch result {
            case .success:
                completion(.success(id))
            case let .failure(error):
                completion(.failure(error))
            }
        })
    }
    
    func deletePaymentRequests(_ ids: [String],
                               resourceHandler: ResourceDataHandler<APIResource<String>>,
                               completion: @escaping CompletionResult<[String]>) {
        guard let json = try? JSONEncoder().encode(ids) else {
            assertionFailure("The payment request ids provided cannot be encoded")
            return
        }
        
        let resource = APIResource<String>(method: .paymentRequests(limit: nil, offset: nil),
                                           apiDomain: apiDomain,
                                           apiVersion: apiVersion,
                                           httpMethod: .delete,
                                           body: json)
        
        resourceHandler(resource, { result in
            switch result {
            case .success:
                completion(.success(ids))
            case let .failure(error):
                completion(.failure(error))
            }
        })
    }

    func paymentRequest(id: String, resourceHandler: ResourceDataHandler<APIResource<PaymentRequest>>,
                        completion: @escaping CompletionResult<PaymentRequest>) {
        let resource = APIResource<PaymentRequest>(method: .paymentRequest(id: id), apiDomain: apiDomain, apiVersion: apiVersion, httpMethod: .get)

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
        let resource = APIResource<PaymentRequests>(method: .paymentRequests(limit: limit, offset: offset), apiDomain: apiDomain, apiVersion: apiVersion, httpMethod: .get)

        resourceHandler(resource, { result in
            switch result {
            case let .success(paymentRequests):
                completion(.success(paymentRequests))
            case let .failure(error):
                completion(.failure(error))
            }
        })
    }
    
    private func file(urlString: String,
                 resourceHandler: ResourceDataHandler<APIResource<Data>>,
                 completion: @escaping CompletionResult<Data>) {
        var resource = APIResource<Data>(method: .file(urlString: urlString), apiDomain: apiDomain, apiVersion: apiVersion, httpMethod: .get)
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

    func payment(id: String,
                 resourceHandler: ResourceDataHandler<APIResource<Payment>>,
                 completion: @escaping CompletionResult<Payment>) {
        let resource = APIResource<Payment>(method: .payment(id: id), apiDomain: apiDomain, apiVersion: apiVersion, httpMethod: .get)

        resourceHandler(resource, { result in
            switch result {
            case let .success(payment):
                completion(.success(payment))
            case let .failure(error):
                completion(.failure(error))
            }
        })
    }

    func pdfWithQRCode(paymentRequestId: String,
                       mimeSubtype: MimeSubtype,
                       resourceHandler: ResourceDataHandler<APIResource<Data>>,
                       completion: @escaping CompletionResult<Data>) {
        let resource = APIResource<Data>(method: .pdfWithQRCode(paymentRequestId: paymentRequestId,
                                                                mimeSubtype: mimeSubtype),
                                         apiDomain: apiDomain,
                                         apiVersion: apiVersion,
                                         httpMethod: .get)
        resourceHandler(resource, { result in
            switch result {
            case .success(let data):
                completion(.success(data))
            case let .failure(error):
                completion(.failure(error))
            }
        })
    }
}
