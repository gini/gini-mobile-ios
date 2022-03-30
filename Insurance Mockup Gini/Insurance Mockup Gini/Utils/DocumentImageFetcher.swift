//
//  DocumentImageFetcher.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 29.03.2022.
//

import UIKit
import GiniHealthAPILibrary
import GiniHealthSDK

struct DocumentImageFetcher {
    static func fetchDocumentPreviews(for document: Document?, with healthSDK: GiniHealth, completion: @escaping ([UIImage]) -> Void) {
        guard let document = document else { return }
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "imagesQueue")
        let dispatchSemaphore = DispatchSemaphore(value: 0)
        var images = [UIImage]()
        dispatchQueue.async {
            for page in 1 ... document.pageCount {
                dispatchGroup.enter()

                healthSDK.documentService.preview(for: document.id, pageNumber: page) { result in
                    switch result {
                    case let .success(dataImage):
                        if let image = UIImage(data: dataImage) {
                            images.append(image)
                        }
                    case let .failure(error):
                        print(error)
                    }
                    dispatchSemaphore.signal()
                    dispatchGroup.leave()
                }
                dispatchSemaphore.wait()
            }

            dispatchGroup.notify(queue: dispatchQueue) {
                DispatchQueue.main.async {
                    completion(images)
                }
            }
        }
    }
}
