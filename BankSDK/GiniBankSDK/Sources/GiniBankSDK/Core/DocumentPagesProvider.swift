//
//  DocumentPagesProvider.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import GiniBankAPILibrary
import UIKit

/**
 A protocol defining the required methods for fetching document pages.
 Implementing types provide functionality to retrieve document pages
 and specific page data.
 */
protocol DocumentPagesProvider {
    /**
     Retrieves all pages of a document.

     - Parameters:
     - completion: A closure that returns a `Result` containing either an array of `Document.Page` instances
     if successful, or a `GiniError` in case of failure.
     */
    func getDocumentPages(completion: @escaping (Result<[Document.Page], GiniError>) -> Void)

    /**
     Retrieves a specific document page.

     - Parameters:
     - pageNumber: The number of the page to retrieve.
     - size: The size of the page to be fetched.
     - completion: A closure that returns a `Result` containing either the page data (`Data`)
     if successful, or a `GiniError` in case of failure.
     */
    func getDocumentPage(for pageNumber: Int,
                         size: Document.Page.Size,
                         completion: @escaping (Result<Data, GiniError>) -> Void)
}
