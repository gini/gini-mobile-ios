//
//  DocumentServiceProviding.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import GiniCaptureSDK
import GiniBankAPILibrary
import UIKit

protocol DocumentServiceProviding {
    func getDocumentPages(completion: @escaping (Result<[Document.Page], GiniError>) -> Void)
    func getDocumentPage(for pageNumber: Int,
                         size: Document.Page.Size,
                         completion: @escaping (Result<Data, GiniError>) -> Void)
}
