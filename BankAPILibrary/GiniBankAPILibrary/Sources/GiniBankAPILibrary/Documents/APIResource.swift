//
//  APIResource.swift
//  GiniBankAPI
//
//  Created by Enrique del Pozo Gómez on 1/18/18.
//

import Foundation

public enum APIDomain {
    /// The default one, which points to https://pay-api.gini.net
    case `default`
    /// A custom domain with optional path and custom token source
    case custom(domain: String, path: String? = nil, tokenSource: AlternativeTokenSource?)
    
    public var domainString: String {
        switch self {
        case .default: return "pay-api.gini.net"
        case .custom(let domain, _, _): return domain
        }
    }
    
    var path: String {
        switch self {
        case .custom(_, let path, _): return path ?? ""
        default: return ""
        }
    }
}

struct APIResource<T: Decodable>: Resource {
    
    typealias ResourceMethodType = APIMethod
    typealias ResponseType = T
    
    var domain: APIDomain
    var params: RequestParameters
    var method: APIMethod
    var authServiceType: AuthServiceType? = .apiService
    
    var host: String {
        return "\(domain.domainString)"
    }
    
    var scheme: URLScheme {
        return .https
    }
    
    var apiVersion: Int {
        switch domain {
        case .default, .custom: return 2
        }
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
            return [URLQueryItem(name: "offset", itemValue: offset),
                    URLQueryItem(name: "limit", itemValue: limit)]
        default: return nil
        }
    }
    
    var path: String {
        return "\(domain.path)\(methodPath)"
    }
    
    private var methodPath: String {
        switch method {
        case .composite:
            return "/documents/composite"
        case .documents, .createDocument:
            return "/documents/"
        case .document(let id):
            return "/documents/\(id)"
        case .errorReport(let id, _, _):
            return "/documents/\(id)/errorreport"
        case .extractions(let id):
            return "/documents/\(id)/extractions"
        case .extraction(let label, let documentId):
            return "/documents/\(documentId)/extractions/\(label)"
        case .feedback(let id):
            return "/documents/\(id)/extractions/feedback"
        case .layout(let id):
            return "/documents/\(id)/layout"
        case .pages(let id):
            return "/documents/\(id)/pages"
        case .page(let id, let number, let size):
            if let size = size {
                return "/documents/\(id)/pages/\(number)/\(size.rawValue)"
            } else {
                return "/documents/\(id)/pages/\(number)"
            }
        case .pagePreview(let id, let number):
            return "/documents/\(id)/pages/\(number)/large"
        case .documentPage(let id, let number, let sizeType):
            return "/documents/\(id)/pages/\(number)/\(sizeType)"
        case .partial:
            return "/documents/partial"
        case .processedDocument(let id):
            return "/documents/\(id)/processed"
        case .paymentRequest(let id):
            return "/paymentRequests/\(id)"
        case .paymentRequests(_, _):
            return "/paymentRequests"
        case .resolvePaymentRequest(let id):
            return "/paymentRequests/\(id)/payment"
        case .payment(let id):
            return "/paymentRequests/\(id)/payment"
        case .logErrorEvent:
            return "/events/error"
        case .configurations:
            return "/configurations"
        case .analyticsEvent:
            return "/events/batch"
        }
    }
    
    var defaultHeaders: HTTPHeaders {
        let acceptKey = "Accept"
        let contentTypeKey = "Content-Type"
        
        let jsonAcceptValue = ContentType.content(version: apiVersion, subtype: nil, mimeSubtype: "json").value
        let jsonContentTypeValue = ContentType.content(version: apiVersion, subtype: nil, mimeSubtype: "json").value
        let amplitudeEventsValue = "application/vnd.gini.v1.events.amplitude"
        
        switch method {
        case .createDocument(_, _, let mimeSubType, let documentType):
            let dynamicContentType = ContentType.content(version: apiVersion, subtype: documentType?.name, mimeSubtype: mimeSubType).value
            return [acceptKey: jsonAcceptValue, contentTypeKey: dynamicContentType]
            
        case .page, .pagePreview, .documentPage:
            return [:]
            
        case .paymentRequests:
            return [acceptKey: jsonAcceptValue]
            
        case .analyticsEvent:
            return [acceptKey: ContentType.json.value, contentTypeKey: amplitudeEventsValue]
            
        default:
            return [acceptKey: jsonAcceptValue, contentTypeKey: jsonContentTypeValue]
        }
    }
    
    init(method: APIMethod,
         apiDomain: APIDomain,
         httpMethod: HTTPMethod,
         additionalHeaders: HTTPHeaders = [:],
         body: Data? = nil) {
        self.method = method
        self.domain = apiDomain
        self.params = RequestParameters(method: httpMethod,
                                        body: body)
        self.params.headers = defaultHeaders.merging(additionalHeaders) { (current, _ ) in current }
    }
    
    func parsed(response: HTTPURLResponse, data: Data) throws -> ResponseType {
        guard ResponseType.self != String.self else {
            let string: String?
            switch method {
            case .createDocument:
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
