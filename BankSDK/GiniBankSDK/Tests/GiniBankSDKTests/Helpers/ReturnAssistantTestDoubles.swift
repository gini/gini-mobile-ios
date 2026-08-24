//
//  ReturnAssistantTestDoubles.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation
import Testing
import UIKit
@testable import GiniBankAPILibrary
@testable import GiniBankSDK
@testable import GiniCaptureSDK

// MARK: - Fixture loading

/**
 Loads `ExtractionResult` fixtures from JSON files in `Tests/Resources/`,
 using the same wire format the Gini Bank API returns (`ExtractionsContainer`).
 */
enum ExtractionResultFixture {

    /** Decodes the given fixture file into an `ExtractionResult`. */
    static func load(named fixtureName: String) throws -> ExtractionResult {
        let data = try #require(FileLoader.loadFile(withName: fixtureName, ofType: "json"),
                                "Fixture \(fixtureName).json should exist in Tests/Resources")
        let container = try JSONDecoder().decode(ExtractionsContainer.self, from: data)
        return ExtractionResult(extractionsContainer: container)
    }

    /** Builds a `DigitalInvoice` from the invoice fixture containing parseable line items. */
    static func digitalInvoice(named fixtureName: String = "extractionsContainerInvoiceLineItems") throws -> DigitalInvoice {
        try DigitalInvoice(extractionResult: load(named: fixtureName))
    }

    /** Returns a single parsed line item from the invoice fixture. */
    static func lineItem(at index: Int = 0) throws -> DigitalInvoice.LineItem {
        let invoice = try digitalInvoice()
        let lineItems = invoice.lineItems
        try #require(lineItems.indices.contains(index),
                     "Fixture should contain a line item at index \(index)")
        return lineItems[index]
    }

    /**
     Builds a `DigitalInvoice` whose extraction result carries both parseable
     line items and Skonto discounts, by merging the line items of the invoice
     fixture into the Skonto fixture's extraction result.
     */
    static func digitalInvoiceWithSkontoDiscounts() throws -> DigitalInvoice {
        let skontoExtractionResult = try load(named: "skontoDiscounts")
        let invoiceExtractionResult = try load(named: "extractionsContainerInvoiceLineItems")
        skontoExtractionResult.lineItems = invoiceExtractionResult.lineItems
        return try DigitalInvoice(extractionResult: skontoExtractionResult)
    }
}

// MARK: - Results delegate recording mock

/**
 Manual `GiniCaptureResultsDelegate` mock that records every delivered
 `AnalysisResult` and exposes an optional hook to resume async tests.
 */
final class RecordingCaptureResultsDelegate: GiniCaptureResultsDelegate {

    private(set) var deliveredResults: [AnalysisResult] = []
    private(set) var cancelCallCount = 0
    private(set) var enterManuallyCallCount = 0
    private(set) var schedulePaymentResults: [AnalysisResult] = []

    /// Invoked synchronously whenever a result is delivered.
    var onResult: ((AnalysisResult) -> Void)?

    func giniCaptureAnalysisDidFinishWith(result: AnalysisResult) {
        deliveredResults.append(result)
        onResult?(result)
    }

    func giniCaptureDidCancelAnalysis() {
        cancelCallCount += 1
    }

    func giniCaptureDidEnterManually() {
        enterManuallyCallCount += 1
    }

    func giniCaptureDidRequestSchedulePayment(result: AnalysisResult) {
        schedulePaymentResults.append(result)
    }
}

// MARK: - Capture network service stub

/**
 Manual `GiniCaptureNetworkService` stub that completes uploads and analysis
 synchronously with a stub document and an injected `ExtractionResult`,
 letting coordinator tests drive the post-analysis flow without any network.
 */
final class StubAnalysisCaptureNetworkService: GiniCaptureNetworkService {

    private let extractionResult: ExtractionResult

    init(extractionResult: ExtractionResult) {
        self.extractionResult = extractionResult
    }

    static func makeStubDocument(id: String = "stub-document-id") -> Document? {
        guard let url = URL(string: "https://pay-api.gini.net/documents/\(id)") else { return nil }
        let links = Document.Links(giniAPIDocumentURL: url)
        return Document(creationDate: Date(),
                        id: id,
                        name: "stub-document",
                        links: links,
                        sourceClassification: .scanned)
    }

    func upload(document: GiniCaptureDocument,
                metadata: Document.Metadata?,
                completion: @escaping UploadDocumentCompletion) {
        guard let stubDocument = Self.makeStubDocument() else { return }
        completion(.success(stubDocument))
    }

    func analyse(partialDocuments: [PartialDocumentInfo],
                 metadata: Document.Metadata?,
                 cancellationToken: CancellationToken,
                 completion: @escaping (Result<(document: Document, extractionResult: ExtractionResult), GiniError>) -> Void) {
        guard let stubDocument = Self.makeStubDocument() else { return }
        completion(.success((stubDocument, extractionResult)))
    }

    func delete(document: Document, completion: @escaping (Result<String, GiniError>) -> Void) {
        // Intentionally empty; not needed for these tests.
    }

    func cleanup() {
        // Intentionally empty; not needed for these tests.
    }

    func sendFeedback(document: Document,
                      updatedExtractions: [Extraction],
                      updatedCompoundExtractions: [String: [[Extraction]]]?,
                      completion: @escaping (Result<Void, GiniError>) -> Void) {
        // Intentionally empty; not needed for these tests.
    }

    func sendFeedback(documentId: String,
                      updatedExtractions: [Extraction],
                      updatedCompoundExtractions: [String: [[Extraction]]]?,
                      completion: @escaping (Result<Void, GiniError>) -> Void) {
        // Intentionally empty; not needed for these tests.
    }

    func log(errorEvent: ErrorEvent, completion: @escaping (Result<Void, GiniError>) -> Void) {
        // Intentionally empty; not needed for these tests.
    }
}

// MARK: - Network delegate mock

/**
 Manual mock combining `AnalysisDelegate` and `UploadDelegate`
 (`GiniCaptureNetworkDelegate`) that records every callback.
 */
final class MockCaptureNetworkDelegate: NSObject, GiniCaptureNetworkDelegate {

    private(set) var displayedErrorTypes: [ErrorType] = []
    private(set) var noResultsCallCount = 0
    private(set) var uploadCompletedDocuments: [GiniCaptureDocument] = []
    private(set) var uploadFailedCallCount = 0

    func displayError(errorType: ErrorType, animated: Bool) {
        displayedErrorTypes.append(errorType)
    }

    func tryDisplayNoResultsScreen() {
        noResultsCallCount += 1
    }

    func uploadDidComplete(for document: GiniCaptureDocument) {
        uploadCompletedDocuments.append(document)
    }

    func uploadDidFail(for document: GiniCaptureDocument, with error: Error) {
        uploadFailedCallCount += 1
    }
}

// MARK: - Navigation controller spy

/**
 `UINavigationController` spy recording presentations, pushes and dismissals
 without touching the real presentation machinery (no window required).
 Completions run synchronously so coordinator flows stay deterministic.
 */
final class SpyNavigationController: UINavigationController {

    private(set) var presentedControllers: [UIViewController] = []
    private(set) var pushedControllers: [UIViewController] = []
    private(set) var dismissCallCount = 0
    private(set) var popCallCount = 0

    /// Invoked synchronously after a presentation is recorded.
    var onPresent: ((UIViewController) -> Void)?

    /// Invoked synchronously after a push is recorded.
    var onPush: ((UIViewController) -> Void)?

    override func present(_ viewControllerToPresent: UIViewController,
                          animated flag: Bool,
                          completion: (() -> Void)? = nil) {
        presentedControllers.append(viewControllerToPresent)
        completion?()
        onPresent?(viewControllerToPresent)
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        pushedControllers.append(viewController)
        onPush?(viewController)
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        dismissCallCount += 1
        completion?()
    }

    override func popViewController(animated: Bool) -> UIViewController? {
        popCallCount += 1
        return super.popViewController(animated: animated)
    }
}

// MARK: - SkontoCoordinatorDelegate mock

/** Manual `SkontoCoordinatorDelegate` mock recording forwarded Skonto events. */
final class MockSkontoCoordinatorDelegate: SkontoCoordinatorDelegate {

    private(set) var cancelledCoordinators: [SkontoCoordinator] = []
    private(set) var finishedExtractionResults: [ExtractionResult?] = []
    private(set) var previewedViewModels: [SkontoViewModel] = []

    func didCancelAnalysis(_ coordinator: SkontoCoordinator) {
        cancelledCoordinators.append(coordinator)
    }

    func didFinishAnalysis(_ coordinator: SkontoCoordinator,
                           _ editedExtractionResult: ExtractionResult?) {
        finishedExtractionResults.append(editedExtractionResult)
    }

    func didTapDocumentPreview(_ coordinator: GiniBankSDK.Coordinator,
                               _ viewModel: SkontoViewModel) {
        previewedViewModels.append(viewModel)
    }
}

// MARK: - EditLineItemViewModel delegate mock

/** Manual `EditLineItemViewModelDelegate` mock recording save and cancel calls. */
final class MockEditLineItemViewModelDelegate: EditLineItemViewModelDelegate {

    private(set) var savedLineItems: [DigitalInvoice.LineItem] = []
    private(set) var cancelCallCount = 0

    func didSave(lineItem: DigitalInvoice.LineItem, on viewModel: EditLineItemViewModel) {
        savedLineItems.append(lineItem)
    }

    func didCancel(on viewModel: EditLineItemViewModel) {
        cancelCallCount += 1
    }
}

// MARK: - DigitalInvoiceCoordinator delegate mock

/** Manual `DigitalInvoiceCoordinatorDelegate` mock recording the forwarded events. */
final class MockDigitalInvoiceCoordinatorDelegate: DigitalInvoiceCoordinatorDelegate {

    private(set) var cancelledCoordinators: [DigitalInvoiceCoordinator] = []
    private(set) var finishedInvoices: [DigitalInvoice?] = []
    private(set) var finishedAnalysisDelegates: [AnalysisDelegate] = []

    func didCancelAnalysis(_ coordinator: DigitalInvoiceCoordinator) {
        cancelledCoordinators.append(coordinator)
    }

    func didFinishAnalysis(_ coordinator: DigitalInvoiceCoordinator,
                           invoice: DigitalInvoice?,
                           analysisDelegate: AnalysisDelegate) {
        finishedInvoices.append(invoice)
        finishedAnalysisDelegates.append(analysisDelegate)
    }
}

// MARK: - UIControl action triggering

@MainActor
extension UIControl {

    /**
     Invokes all `.touchUpInside` target-actions directly.
     `sendActions(for:)` relies on a running `UIApplication`, which is not
     guaranteed inside an SPM test runner, so the actions are performed manually.
     */
    func triggerTouchUpInside() {
        for target in allTargets {
            guard let target = target.base as? NSObject else { continue }
            let actionNames = actions(forTarget: target, forControlEvent: .touchUpInside) ?? []
            for actionName in actionNames {
                let selector = Selector(actionName)
                if actionName.hasSuffix(":") {
                    _ = target.perform(selector, with: self)
                } else {
                    _ = target.perform(selector)
                }
            }
        }
    }
}

// MARK: - Test image document factory

@MainActor
enum TestDocumentFactory {

    /** Creates a small in-memory image document suitable for driving `didReview`. */
    static func makeImageDocument() -> GiniImageDocument {
        let size = CGSize(width: 4, height: 4)
        let renderer = UIGraphicsImageRenderer(size: size)
        let data = renderer.pngData { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
        return GiniImageDocument(data: data, imageSource: .camera)
    }
}
