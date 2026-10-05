//
//  DocumentServiceHelperTests.swift
//  GiniHealthAPILibraryTests
//
//  Copyright © 2026 Gini. All rights reserved.
//

import Testing
import Foundation
@testable import GiniHealthAPILibrary

/**
 Focused unit tests for the private helpers extracted from
 `DocumentService.extractions(...)` and `DocumentService.preview(...)` during
 the SonarQube cleanup. Each test drives the internal `resourceHandler`
 seams so the helpers execute end-to-end without a live network.
 */
@Suite("DocumentService helpers")
struct DocumentServiceHelperTests {

    // MARK: - Doubles

    private static func makeService() -> DefaultDocumentService {
        DefaultDocumentService(sessionManager: SessionManagerMock(),
                               apiVersion: 5)
    }

    private static func loadCompletedDocument() -> Document {
        let document: Document = load(fromFile: "document", type: "json")
        return document
    }

    private static func loadPages() -> [Document.Page] {
        load(fromFile: "pages", type: "json")
    }

    private static func loadExtractionsContainer() -> ExtractionsContainer {
        load(fromFile: "extractionsContainer", type: "json")
    }

    // MARK: - extractions helpers (handlePollResult / handleExtractionsResult)

    @Test("extractions: poll success → extractions success → .success(ExtractionResult)")
    func extractionsFullSuccess() async {
        let service = Self.makeService()
        let document = Self.loadCompletedDocument()
        let extractionsContainer = Self.loadExtractionsContainer()

        let docHandler: CancellableResourceDataHandler<APIResource<Document>> = { _, _, completion in
            completion(.success(document))
        }
        let extractionsHandler: CancellableResourceDataHandler<APIResource<ExtractionsContainer>> = { _, _, completion in
            completion(.success(extractionsContainer))
        }

        let result: Result<ExtractionResult, GiniError> = await withCheckedContinuation { continuation in
            service.extractions(resourceHandler: extractionsHandler,
                                documentResourceHandler: docHandler,
                                for: document,
                                cancellationToken: nil) { continuation.resume(returning: $0) }
        }

        switch result {
        case .success(let extractionResult):
            #expect(extractionResult.extractions.count == extractionsContainer.extractions.count)
        case .failure(let error):
            Issue.record("Expected .success, got .failure(\(error))")
        }
    }

    @Test("extractions: poll success → extractions failure → .failure propagates")
    func extractionsFetchFailurePropagates() async {
        let service = Self.makeService()
        let document = Self.loadCompletedDocument()

        let docHandler: CancellableResourceDataHandler<APIResource<Document>> = { _, _, completion in
            completion(.success(document))
        }
        let extractionsHandler: CancellableResourceDataHandler<APIResource<ExtractionsContainer>> = { _, _, completion in
            completion(.failure(.notFound()))
        }

        let result: Result<ExtractionResult, GiniError> = await withCheckedContinuation { continuation in
            service.extractions(resourceHandler: extractionsHandler,
                                documentResourceHandler: docHandler,
                                for: document,
                                cancellationToken: nil) { continuation.resume(returning: $0) }
        }

        switch result {
        case .success:
            Issue.record("Expected .failure, got .success")
        case .failure(let error):
            if case .notFound = error {
                break
            } else {
                Issue.record("Expected .notFound, got \(error)")
            }
        }
    }

    @Test("extractions: poll failure → .failure propagates and extractions handler is never called")
    func extractionsPollFailurePropagates() async {
        let service = Self.makeService()
        let document = Self.loadCompletedDocument()

        let docHandler: CancellableResourceDataHandler<APIResource<Document>> = { _, _, completion in
            completion(.failure(.badRequest()))
        }
        let extractionsCalled = ExtractionsCalledFlag()
        let extractionsHandler: CancellableResourceDataHandler<APIResource<ExtractionsContainer>> = { _, _, _ in
            extractionsCalled.wasCalled = true
        }

        let result: Result<ExtractionResult, GiniError> = await withCheckedContinuation { continuation in
            service.extractions(resourceHandler: extractionsHandler,
                                documentResourceHandler: docHandler,
                                for: document,
                                cancellationToken: nil) { continuation.resume(returning: $0) }
        }

        #expect(extractionsCalled.wasCalled == false,
                "extractions handler must not run when the poll fails")
        switch result {
        case .success:
            Issue.record("Expected .failure, got .success")
        case .failure(let error):
            if case .badRequest = error {
                break
            } else {
                Issue.record("Expected .badRequest, got \(error)")
            }
        }
    }

    /// Reference wrapper so the closure-based mock can flip a flag without needing an actor.
    private final class ExtractionsCalledFlag { var wasCalled = false }

    // MARK: - preview helpers (handlePreviewPages / retryPreviewIfNeeded / handleFileResult)

    /**
     End-to-end success uses the real `DefaultDocumentService.preview` entry point so
     `handlePreviewPages` → `file(urlString:)` → `handleFileResult` all execute, but
     stubs the underlying `sessionManager.download` via a custom resource handler by
     routing through the extension's `preview(resourceHandler:...)` overload.
     */
    @Test("preview: pages success → handleFileResult forwards the downloaded data")
    func previewHandlePreviewPagesSuccess() async {
        let service = Self.makeService()
        let pages = Self.loadPages()

        let previewHandler: ResourceDataHandler<APIResource<[Document.Page]>> = { _, completion in
            completion(.success(pages))
        }

        let result: Result<Data, GiniError> = await withCheckedContinuation { continuation in
            service.preview(resourceHandler: previewHandler,
                            with: "dcd0c7a0-8382-11ec-9fb5-a5611818595c",
                            pageNumber: 1) { continuation.resume(returning: $0) }
        }

        /// The internal call chain hits `file(urlString:)` → `sessionManager.download`,
        /// which the mock resolves to a bundled PNG. We only care that data flowed
        /// through `handleFileResult`.
        switch result {
        case .success(let data):
            #expect(data.isEmpty == false, "handleFileResult should forward the downloaded payload")
        case .failure(let error):
            Issue.record("Expected .success, got .failure(\(error))")
        }
    }

    @Test("preview: empty pages returns .notFound")
    func previewEmptyPagesReturnsNotFound() async {
        let service = Self.makeService()

        let previewHandler: ResourceDataHandler<APIResource<[Document.Page]>> = { _, completion in
            completion(.success([]))
        }

        let result: Result<Data, GiniError> = await withCheckedContinuation { continuation in
            service.preview(resourceHandler: previewHandler,
                            with: "dcd0c7a0-8382-11ec-9fb5-a5611818595c",
                            pageNumber: 1) { continuation.resume(returning: $0) }
        }

        switch result {
        case .success:
            Issue.record("Expected .failure, got .success")
        case .failure(let error):
            if case .notFound = error {
                break
            } else {
                Issue.record("Expected .notFound, got \(error)")
            }
        }
    }

    @Test("preview: non-.notFound failure is propagated instead of silently retrying")
    func previewNonNotFoundFailurePropagates() async {
        let service = Self.makeService()

        let previewHandler: ResourceDataHandler<APIResource<[Document.Page]>> = { _, completion in
            completion(.failure(.badRequest()))
        }

        let result: Result<Data, GiniError> = await withCheckedContinuation { continuation in
            service.preview(resourceHandler: previewHandler,
                            with: "dcd0c7a0-8382-11ec-9fb5-a5611818595c",
                            pageNumber: 1) { continuation.resume(returning: $0) }
        }

        switch result {
        case .success:
            Issue.record("Expected .failure, got .success")
        case .failure(let error):
            if case .badRequest = error {
                break
            } else {
                Issue.record("Expected .badRequest, got \(error)")
            }
        }
    }
}
