//
//  File.swift
//  
//
//  Created by Alpár Szotyori on 12.01.22.
//

import Foundation
import GiniBankAPILibrary

public protocol GiniCaptureNetworkService {
    func delete(document: GiniCaptureDocument)
    func cleanup()
    func analyse(completion: @escaping AnalysisCompletion)
    func upload(document: GiniCaptureDocument,
                metadata: Document.Metadata?,
                completion: @escaping UploadDocumentCompletion)
}

class DefaultCaptureNetworkService: GiniCaptureNetworkService {
    
    var documentService: DefaultDocumentService
    
    public init(lib: GiniBankAPI) {
        self.documentService = lib.documentService()
    }
    
    func delete(document: GiniCaptureDocument) {
        
    }
    
    func cleanup() {
        
    }
    
    func analyse(completion: @escaping AnalysisCompletion) {
        
    }
    
    func upload(document: GiniCaptureDocument, metadata: Document.Metadata?, completion: @escaping UploadDocumentCompletion) {
        Log(message: "Creating document...", event: "📝")
        
        let fileName = "Partial-\(NSDate().timeIntervalSince1970)"
        
        documentService.createDocument(fileName: fileName,
                                       docType: nil,
                                       type: .partial(document.data),
                                       metadata: metadata) { result in
                                        switch result {
                                        case .success(let createdDocument):
                                            Log(message: "Created document with id: \(createdDocument.id) " +
                                                "for vision document \(document.id)", event: "📄")
                                            completion(.success(createdDocument))
                                        case .failure(let error):
                                            let message = "Document creation failed"
                                            Log(message: message, event: .error)
                                            let errorLog = ErrorLog(description: message, error: error)
                                            GiniConfiguration.shared.errorLogger.handleErrorLog(error: errorLog)
                                            completion(.failure(error))
                                        }
        }
    }
    
    
}
