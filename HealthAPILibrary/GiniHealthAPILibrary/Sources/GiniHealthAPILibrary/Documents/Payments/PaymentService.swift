//
//  PaymentService.swift
//  GiniHealthAPI
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

/**
 The payment service. Interacts with the `Gini Health API` to support Gini Pay Connect functionality.
 */
public final class PaymentService: PaymentServiceProtocol {
    
    /**
     Returns a list of payment providers.

     - Parameter completion: A completion callback, returning the payment list on success.
     */
    public func paymentProviders(completion: @escaping CompletionResult<PaymentProviders>) {
        self.paymentProviders(resourceHandler: sessionManager.data, completion: completion)
    }

    /**
     Returns a payment provider.

     - Parameters:
       - id: The payment provider's unique identifier.
       - completion: A completion callback, returning the payment provider on success.
     */
    public func paymentProvider(id: String,
                                completion: @escaping CompletionResult<PaymentProvider>) {
        self.paymentProvider(id: id, resourceHandler: sessionManager.data, completion: completion)
    }
    
    
    /**
     Creates a payment request.

     - Parameters:
       - sourceDocumentLocation: The URI of the source document when payment details were extracted by Gini beforehand (optional).
       - paymentProvider: The id of the target payment provider.
       - recipient: The recipient of the payment.
       - iban: The IBAN of the payment recipient.
       - bic: The BIC for the payment (optional).
       - amount: The amount of the payment.
       - purpose: The purpose of the payment, e.g. the invoice or customer identifier.
       - completion: A completion callback, returning the payment request id on success.
     */
    public func createPaymentRequest(sourceDocumentLocation: String?,
                                     paymentProvider: String,
                                     recipient: String,
                                     iban: String,
                                     bic: String? = nil,
                                     amount: String,
                                     purpose: String,
                                     completion: @escaping CompletionResult<String>) {
        let requestBody = PaymentRequestBody(sourceDocumentLocation: sourceDocumentLocation, paymentProvider: paymentProvider, recipient: recipient, iban: iban, bic: bic, amount: amount, purpose: purpose)
        self.createPaymentRequest(paymentRequestBody: requestBody, resourceHandler: sessionManager.data, completion: completion)
    }
    
    /**
     Deletes a payment request.

     - Parameters:
       - id: The payment request's unique identifier.
       - completion: A completion callback, returning the payment request's unique identifier on success.
     */
    public func deletePaymentRequest(id: String,
                                     completion: @escaping CompletionResult<String>) {
        self.deletePaymentRequest(id: id, resourceHandler: sessionManager.data, completion: completion)
    }
    
    /**
     Deletes a batch of payment requests.

     - Parameters:
       - ids: An array of payment request ids to be deleted.
       - completion: A completion callback returning the deleted ids on success, or an error on failure.
     */
    public func deletePaymentRequests(_ ids: [String],
                                     completion: @escaping CompletionResult<[String]>) {
       self.deletePaymentRequests(ids,
                                  resourceHandler: sessionManager.data,
                                  completion: completion)
   }
    
    /**
     Returns a payment request.

     - Parameters:
       - id: The payment request's unique identifier.
       - completion: A completion callback, returning the payment request on success.
     */
    public func paymentRequest(id: String,
                               completion: @escaping CompletionResult<PaymentRequest>) {
        self.paymentRequest(id: id, resourceHandler: sessionManager.data, completion: completion)
    }
    
    /**
     Returns a list of payment requests.

     - Parameters:
       - limit: The maximum number of payment requests to return. Default is 20.
       - offset: A starting offset. Default is 0.
       - completion: A completion callback, returning the request list on success.
     */
    public func paymentRequests(limit: Int? = 20,
                                offset: Int? = 0,
                                completion: @escaping CompletionResult<PaymentRequests>) {
        self.paymentRequests(limit: limit, offset: offset, resourceHandler: sessionManager.data, completion: completion)
    }

    /**
     Returns a payment.

     - Parameters:
       - id: The payment request's unique identifier.
       - completion: A completion callback, returning the payment on success.
     */
    public func payment(id: String,
                        completion: @escaping CompletionResult<Payment>) {
        self.payment(id: id, resourceHandler: sessionManager.data, completion: completion)
    }

    let sessionManager: SessionManagerProtocol

    /** The API domain this service communicates with. */
    public var apiDomain: APIDomain
    /** The API version used for requests. */
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
     Returns pdf data containing a payment request in QR code format.

     - Parameters:
       - paymentRequestId: The payment request's unique identifier.
       - completion: A completion callback, returning the pdf document with the payment details in QR code on success.
     */
    public func pdfWithQRCode(paymentRequestId: String,
                               completion: @escaping CompletionResult<Data>){
        pdfWithQRCode(paymentRequestId: paymentRequestId,
                      mimeSubtype: .pdf,
                      resourceHandler: sessionManager.data,
                      completion: completion)
    }
    
    /**
     Returns a QR code image for a payment request in PNG format.

     - Parameters:
       - paymentRequestId: The payment request's unique identifier.
       - completion: A completion callback, returning the QR code image in PNG format on success.
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
     Returns a list of payment providers.

     - Parameter completion: A completion callback, returning the payment list on success.
     */
    func paymentProviders(completion: @escaping CompletionResult<PaymentProviders>)

    /**
     Returns a payment provider.

     - Parameters:
       - id: The payment provider's unique identifier.
       - completion: A completion callback, returning the payment provider on success.
     */
    func paymentProvider(id: String, completion: @escaping CompletionResult<PaymentProvider>)

    /**
     Creates a payment request.

     - Parameters:
       - sourceDocumentLocation: The URI of the source document when payment details were extracted by Gini beforehand (optional).
       - paymentProvider: The id of the target payment provider.
       - recipient: The recipient of the payment.
       - iban: The IBAN of the payment recipient.
       - bic: The BIC for the payment (optional).
       - amount: The amount of the payment.
       - purpose: The purpose of the payment, e.g. the invoice or customer identifier.
       - completion: A completion callback, returning the payment request id on success.
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
     Deletes a payment request.

     - Parameters:
       - id: The payment request's unique identifier.
       - completion: A completion callback, returning the payment request's unique identifier on success.
     */
    func deletePaymentRequest(id: String,
                              completion: @escaping CompletionResult<String>)

    /**
     Deletes a batch of payment requests.

     - Parameters:
       - ids: An array of payment request ids to be deleted.
       - completion: A completion callback returning the deleted ids on success, or an error on failure.
     */
    func deletePaymentRequests(_ ids: [String],
                               completion: @escaping CompletionResult<[String]>)

    /**
     Returns a payment request.

     - Parameters:
       - id: The payment request's unique identifier.
       - completion: A completion callback, returning the payment request on success.
     */
    func paymentRequest(id: String,
                        completion: @escaping CompletionResult<PaymentRequest>)

    /**
     Returns a list of payment requests.

     - Parameters:
       - limit: The maximum number of payment requests to return. Default is 20.
       - offset: A starting offset. Default is 0.
       - completion: A completion callback, returning the request list on success.
     */
    func paymentRequests(limit: Int?,
                         offset: Int?,
                         completion: @escaping CompletionResult<PaymentRequests>)

    /**
     Returns a payment.

     - Parameters:
       - id: The payment request's unique identifier.
       - completion: A completion callback, returning the payment on success.
     */
    func payment(id: String,
                 completion: @escaping CompletionResult<Payment>)

    /**
     Returns pdf data containing a payment request in QR code format.

     - Parameters:
       - paymentRequestId: The payment request's unique identifier.
       - completion: A completion callback, returning the pdf document with the payment details in QR code on success.
     */
    func pdfWithQRCode(paymentRequestId: String,
                       completion: @escaping CompletionResult<Data>)
}

extension PaymentService {
    
    func paymentProviders(resourceHandler: ResourceDataHandler<APIResource<[PaymentProviderResponse]>>,
                          completion: @escaping CompletionResult<PaymentProviders>) {
        let resource = APIResource<[PaymentProviderResponse]>(method: .paymentProviders, apiDomain: apiDomain, apiVersion: apiVersion, httpMethod: .get)
        var providers = [PaymentProvider]()
        
        // Serial queue to synchronize access to shared mutable state
        let serialQueue = DispatchQueue(label: "net.gini.paymentProviders.serialQueue")
        var firstError: GiniError?
        
        resourceHandler(resource, { result in
            switch result {
            case let .success(providersResponse):
                let dispatchGroup = DispatchGroup()
                for providerResponse in providersResponse {
                    self.fetchProviderIcon(providerResponse, serialQueue: serialQueue, dispatchGroup: dispatchGroup) { fileResult in
                        switch fileResult {
                        case let .success(imageData):
                            if firstError == nil {
                                let provider = PaymentProvider(id: providerResponse.id,
                                                               name: providerResponse.name,
                                                               appSchemeIOS: providerResponse.appSchemeIOS,
                                                               minAppVersion: providerResponse.minAppVersion,
                                                               colors: providerResponse.colors,
                                                               iconData: imageData,
                                                               appStoreUrlIOS: providerResponse.appStoreUrlIOS,
                                                               universalLinkIOS: providerResponse.universalLinkIOS,
                                                               index: providerResponse.index,
                                                               gpcSupportedPlatforms: providerResponse.gpcSupportedPlatforms,
                                                               openWithSupportedPlatforms: providerResponse.openWithSupportedPlatforms)
                                providers.append(provider)
                            }
                        case let .failure(error):
                            if firstError == nil {
                                firstError = error
                            }
                        }
                    }
                }
                dispatchGroup.notify(queue: serialQueue) {
                    if let error = firstError {
                        completion(.failure(error))
                    } else {
                        completion(.success(providers))
                    }
                }

            case let .failure(error):
                completion(.failure(error))
            }
        })
    }

    private func fetchProviderIcon(_ providerResponse: PaymentProviderResponse,
                                   serialQueue: DispatchQueue,
                                   dispatchGroup: DispatchGroup,
                                   onResult: @escaping (Result<Data, GiniError>) -> Void) {
        dispatchGroup.enter()
        file(urlString: providerResponse.iconLocation) { result in
            serialQueue.async {
                onResult(result)
                dispatchGroup.leave()
            }
        }
    }

    func paymentProvider(id: String,
                         resourceHandler: ResourceDataHandler<APIResource<PaymentProviderResponse>>,
                         completion: @escaping CompletionResult<PaymentProvider>) {
        let resource = APIResource<PaymentProviderResponse>(method: .paymentProvider(id: id), apiDomain: apiDomain, apiVersion: apiVersion, httpMethod: .get)

        resourceHandler(resource, { result in
            switch result {
            case let .success(providerResponse):
                self.file(urlString: providerResponse.iconLocation) { result in
                    switch result {
                    case let .success(imageData):
                        let provider = PaymentProvider(id: providerResponse.id,
                                                       name: providerResponse.name,
                                                       appSchemeIOS: providerResponse.appSchemeIOS,
                                                       minAppVersion: providerResponse.minAppVersion,
                                                       colors: providerResponse.colors,
                                                       iconData: imageData,
                                                       appStoreUrlIOS: providerResponse.appStoreUrlIOS,
                                                       universalLinkIOS: providerResponse.universalLinkIOS,
                                                       index: providerResponse.index,
                                                       gpcSupportedPlatforms: providerResponse.gpcSupportedPlatforms,
                                                       openWithSupportedPlatforms: providerResponse.openWithSupportedPlatforms)
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
            completion(.failure(.parseError(message: "Failed to encode PaymentRequestBody")))
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
            completion(.failure(.parseError(message: "Failed to encode payment request IDs")))
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
