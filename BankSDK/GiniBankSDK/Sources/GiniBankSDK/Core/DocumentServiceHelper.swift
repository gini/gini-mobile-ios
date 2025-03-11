//
//  DocumentServiceHelper.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import GiniCaptureSDK
import GiniBankAPILibrary
import UIKit

class DocumentServiceHelper {
    static func loadAllPages(from service: DocumentPagesProvider,
                             pages: [Document.Page],
                             completion: @escaping (Result<[UIImage], GiniError>) -> Void) {
        var images: [UIImage] = []
        var loadError: GiniError?
        let dispatchGroup = DispatchGroup()

        for page in pages {
            dispatchGroup.enter()
            service.getDocumentPage(for: page.number, size: page.images[0].size) { result in
                switch result {
                case .success(let data):
                    if let image = UIImage(data: data) {
                        images.append(image)
                    }
                case .failure(let error):
                    loadError = error
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            if let error = loadError {
                completion(.failure(error))
            } else {
                completion(.success(images))
            }
        }
    }

    static func fetchDocumentPages(from service: DocumentPagesProvider,
                                   completion: @escaping (Result<[UIImage], GiniError>) -> Void) {
        service.getDocumentPages { result in
            switch result {
            case .success(let pages):
                loadAllPages(from: service, pages: pages, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
