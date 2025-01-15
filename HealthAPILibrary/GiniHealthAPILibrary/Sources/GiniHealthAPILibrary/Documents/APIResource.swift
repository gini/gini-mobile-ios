//
//  APIResource.swift
//  GiniHealthAPI
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

public enum APIDomain {
    /// The default one, which points to https://health-api.gini.net
    case `default`
    /// A custom domain with optional custom token source
    case custom(domain: String, tokenSource: AlternativeTokenSource?)
    /// Merchant domain
    case merchant

    var domainString: String {
        
        switch self {
        case .default: return "health-api.gini.net"
        case .custom(let domain, _): return domain
        case .merchant: return "merchant-api.gini.net"
        }
    }
    
}

enum MimeSubtype: String {
    case pdf = "qr+pdf"
    case png = "qr+png"
    case json = "json"
    case jpeg = "jpeg"
}

struct APIResource<T: Decodable>: Resource {
    var fullUrlString: String?
    
    typealias ResourceMethodType = APIMethod
    typealias ResponseType = T
    
    var domain: APIDomain
    let apiVersion: Int
    var params: RequestParameters
    var method: APIMethod
    var authServiceType: AuthServiceType? = .apiService
    
    var host: String {
        return "\(domain.domainString)"
    }
    
    var scheme: URLScheme {
        return .https
    }
    
    var queryItems: [URLQueryItem?]? {
        switch method {
        case .documents(let limit, let offset):
            return [URLQueryItem(name: "limit", itemValue: limit),
                    URLQueryItem(name: "offset", itemValue: offset)
            ]
        case .errorReport(_, let summary, let description):
            return [URLQueryItem(name: "summary", itemValue: summary),
                    URLQueryItem(name: "description", itemValue: description)
            ]
        case .createDocument(let fileName, let docType, _, _):
            return [URLQueryItem(name: "filename", itemValue: fileName),
                    URLQueryItem(name: "doctype", itemValue: docType?.rawValue)
            ]
        case .paymentRequests(let limit, let offset):
            return [URLQueryItem(name: "offset", itemValue: offset),URLQueryItem(name: "limit", itemValue: limit)]
        default: return nil
        }
    }
    
    var path: String {
        switch method {
        case .composite:
            return APIEndpoint.composite
        case .documents, .createDocument:
            return APIEndpoint.documents
        case .document(let id):
            return APIEndpoint.document(id)
        case .errorReport(let id, _, _):
            return APIEndpoint.errorReport(id)
        case .extractions(let id):
            return APIEndpoint.extractions(id)
        case .extraction(let label, let documentId):
            return APIEndpoint.extraction(label, documentId)
        case .feedback(let id):
            return APIEndpoint.feedback(id)
        case .layout(let id):
            return APIEndpoint.layout(id)
        case .pages(let id):
            return APIEndpoint.pages(id)
        case .partial:
            return APIEndpoint.partial
        case .processedDocument(let id):
            return APIEndpoint.processedDocument(id)
        case .paymentProviders:
            return APIEndpoint.paymentProviders
        case .paymentProvider(let id):
            return APIEndpoint.paymentProvider(id)
        case .createPaymentRequest:
            return APIEndpoint.createPaymentRequest
        case .paymentRequest(let id):
            return APIEndpoint.paymentRequest(id)
        case .paymentRequests(_, _):
            return APIEndpoint.paymentRequests
        case .file(urlString: let urlString):
            return APIEndpoint.file(urlString)
        case .payment(let id):
            return APIEndpoint.payment(id)
        case .pdfWithQRCode(let paymentRequestId, _):
            return APIEndpoint.pdfWithQRCode(paymentRequestId)
        case .configurations:
            return APIEndpoint.configurations
        }
    }
    
    var defaultHeaders: HTTPHeaders {
        // Define common headers
        let acceptHeader = ["Accept": ContentType.content(
            version: apiVersion,
            subtype: nil,
            mimeSubtype: MimeSubtype.json.rawValue
        ).value]

        // Helper method to construct Content-Type header
        func contentTypeHeader(subtype: String?, mimeSubtype: String) -> HTTPHeaders {
            return ["Content-Type": ContentType.content(
                version: apiVersion,
                subtype: subtype,
                mimeSubtype: mimeSubtype
            ).value]
        }

        switch method {
            case .createDocument(_, _, let mimeSubType, let documentType):
                return acceptHeader.merging(contentTypeHeader(
                    subtype: documentType?.name,
                    mimeSubtype: mimeSubType.rawValue
                )) { _, new in new }

            case .file(_):
                return [:]

            case .paymentProviders, .paymentProvider(_), .paymentRequests(_, _):
                return acceptHeader

            case .pdfWithQRCode(_, let mimeSubtype):
                return ["Accept": ContentType.content(
                    version: apiVersion,
                    subtype: nil,
                    mimeSubtype: mimeSubtype.rawValue
                ).value]

            default:
                // Default headers for other cases
                return acceptHeader.merging(contentTypeHeader(
                    subtype: nil,
                    mimeSubtype: MimeSubtype.json.rawValue
                )) { _, new in new }
        }
    }
    
    init(method: APIMethod,
         apiDomain: APIDomain,
         apiVersion: Int,
         httpMethod: HTTPMethod,
         additionalHeaders: HTTPHeaders = [:],
         body: Data? = nil) {
        self.method = method
        self.domain = apiDomain
        self.apiVersion = apiVersion
        self.params = RequestParameters(method: httpMethod,
                                        body: body)
        self.params.headers = defaultHeaders.merging(additionalHeaders) { (current, _ ) in current }
    }
    
    func parsed(response: HTTPURLResponse, data: Data) throws -> ResponseType {
        guard ResponseType.self != String.self else {
            let string: String?
            switch method {
            case .createDocument, .createPaymentRequest:
                string = response.allHeaderFields["Location"] as? String
            default:
                string = String(data: data, encoding: .utf8)
            }
            
            if let string = string as? ResponseType {
                return string
            } else {
                throw GiniError.parseError(message: "Invalid string response", response: response, data: data)
            }
        }
        
        guard ResponseType.self != Data.self else {
            //swiftlint:disable force_cast
            return data as! ResponseType
        }
        
        return try JSONDecoder().decode(ResponseType.self, from: data)
    }
}
