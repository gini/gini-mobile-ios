//
//  GiniScreenAPICoordinatorTests.swift
//  GiniCapture_Tests
//
//  Created by Enrique del Pozo Gómez on 3/8/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import XCTest
import Testing
import UIKit
@testable import GiniBankAPILibrary
@testable import GiniCaptureSDK
final class GiniScreenAPICoordinatorTests: XCTestCase {
    
    var coordinator: GiniScreenAPICoordinator!
    let giniConfiguration = GiniConfiguration()
    let delegateMock = GiniCaptureDelegateMock()
    
    override func setUp() {
        super.setUp()
        giniConfiguration.openWithEnabled = true
        giniConfiguration.multipageEnabled = true
        coordinator = GiniScreenAPICoordinator(withDelegate: delegateMock, giniConfiguration: giniConfiguration)
    }
    
    func testNavControllerCountAfterStartWithoutDocuments() {
        let rootViewController = coordinator.start(withDocuments: nil)
        _ = rootViewController.view
        let screenNavigator = rootViewController.children.first as? UINavigationController
        XCTAssertEqual(screenNavigator?.viewControllers.count, 2,
                       "there should be two view controllers in the nav stack, Review and Camera screens")
    }
    
    func testNavControllerTypesAfterStartWithoutDocuments() {
        let rootViewController = coordinator.start(withDocuments: nil)
        _ = rootViewController.view
        let screenNavigator = rootViewController.children.first as? UINavigationController
        XCTAssertNotNil(screenNavigator?.viewControllers.first as? ReviewViewController,
                        "first view controller is not a ReviewViewController")
    }
    
    func testNavControllerCountAfterStartWithImages() {
        let capturedImages = [GiniCaptureTestsHelper.loadImageDocument(named: "invoice"),
                              GiniCaptureTestsHelper.loadImageDocument(named: "invoice2")]

        let rootViewController = coordinator.start(withDocuments: capturedImages)
        _ = rootViewController.view
        let screenNavigator = rootViewController.children.first as? UINavigationController
        XCTAssertEqual(screenNavigator?.viewControllers.count, 1,
                       "there should be 2 view controllers in the nav stack")
    }
    
    func testNavControllerTypesAfterStartWithImages() {
        let document1 = GiniCaptureTestsHelper.loadImageDocument(named: "invoice")
        document1.isImported = false
        let document2 = GiniCaptureTestsHelper.loadImageDocument(named: "invoice2")
        document2.isImported = false
        let capturedImages = [document1, document2]

        let rootViewController = coordinator.start(withDocuments: capturedImages)
        _ = rootViewController.view
        let screenNavigator = rootViewController.children.first as? UINavigationController
        
        XCTAssertNotNil(screenNavigator?.viewControllers.last as? ReviewViewController,
                        "first view controller is not a ReviewViewController")
        XCTAssertEqual(screenNavigator?.viewControllers.count, 1,
                       "there should be only one view controller in the nav stack")
        
    }
    
    func testNavControllerCountAfterStartWithAPDF() {
        let capturedPDFs = [GiniCaptureTestsHelper.loadPDFDocument(named: "testPDF")]

        let rootViewController = coordinator.start(withDocuments: capturedPDFs)
        _ = rootViewController.view
        let screenNavigator = rootViewController.children.first as? UINavigationController
        XCTAssertEqual(screenNavigator?.viewControllers.count, 1,
                       "there should be only one view controller in the nav stack")
    }
    
    func testNavControllerTypesAfterStartWithPDF() {
        let capturedPDFs = [GiniCaptureTestsHelper.loadPDFDocument(named: "testPDF")]

        let rootViewController = coordinator.start(withDocuments: capturedPDFs)
        _ = rootViewController.view
        let screenNavigator = rootViewController.children.first as? UINavigationController
        
        XCTAssertNotNil(screenNavigator?.viewControllers.first as? AnalysisViewController,
                        "first view controller is not a AnalysisViewController")
    }
    
    func testNavControllerTypesAfterStartWithImageAndMultipageDisabled() {
        giniConfiguration.multipageEnabled = false
        let document = GiniCaptureTestsHelper.loadImageDocument(named: "invoice")
        document.isImported = false
        let capturedImages = [document]

        let rootViewController = coordinator.start(withDocuments: capturedImages)
        _ = rootViewController.view
        let screenNavigator = rootViewController.children.first as? UINavigationController
        XCTAssertNotNil(screenNavigator?.viewControllers.last as? ReviewViewController,
                        "first view controller is not a ReviewViewController")
    }

    func testDocumentCollectionAfterRemoveImageInMultipage() {
        let capturedImageDocument = GiniCaptureTestsHelper.loadImagePage(named: "invoice")
        coordinator.addToDocuments(new: [capturedImageDocument])
        
        coordinator.review(coordinator.reviewViewController,
                                    didDelete: coordinator.reviewViewController.pages[0])
        XCTAssertTrue(coordinator.pages.isEmpty,
                      "vision documents collection should be empty after delete " +
            "the image in the multipage review view controller")
    }
    
    func testErrorTypeNoResponse() {
        giniConfiguration.multipageEnabled = false
        let capturedImages = [GiniCaptureTestsHelper.loadImageDocument(named: "invoice")]

        let rootViewController = coordinator.start(withDocuments: capturedImages)
        _ = rootViewController.view
        let errorType = ErrorType(error: .noResponse)
        coordinator.displayError(errorType: errorType, animated: false)
        let screenNavigator = rootViewController.children.first as? UINavigationController
        let errorScreen = screenNavigator?.viewControllers.last as? ErrorScreenViewController
        errorScreen?.setupView()
        XCTAssertNotNil(
            errorScreen,
            "first view controller is not a ErrorScreenViewController")
        XCTAssertTrue(errorScreen?.errorHeader.text == ErrorType.unexpected.title(), "Error title should match no response error type")
        XCTAssertTrue(errorScreen?.errorContent.text == ErrorType.unexpected.content(), "Error content should match no response error type")
        
    }
    
    func testErrorTooManyRequests() {
        giniConfiguration.multipageEnabled = false
        let capturedImages = [GiniCaptureTestsHelper.loadImageDocument(named: "invoice")]

        let rootViewController = coordinator.start(withDocuments: capturedImages)
        _ = rootViewController.view
        let response = HTTPURLResponse(url: URL(string: "example")!, statusCode: 429, httpVersion: "", headerFields: [:])
        let errorType = ErrorType(error: .tooManyRequests(response: response, data: Data()))
        coordinator.displayError(errorType: errorType, animated: false)
        let screenNavigator = rootViewController.children.first as? UINavigationController
        let errorScreen = screenNavigator?.viewControllers.last as? ErrorScreenViewController
        errorScreen?.setupView()
        XCTAssertNotNil(
            errorScreen,
            "first view controller is not a ErrorScreenViewController")
        XCTAssertTrue(errorScreen?.errorHeader.text == ErrorType.request.title(), "Error title should match no response error type")
        XCTAssertTrue(errorScreen?.errorContent.text == ErrorType.request.content(), "Error content should match no response error type")
    }
    
    func testUnauthorizedError() {
        giniConfiguration.multipageEnabled = false
        let capturedImages = [GiniCaptureTestsHelper.loadImageDocument(named: "invoice")]

        let rootViewController = coordinator.start(withDocuments: capturedImages)
        _ = rootViewController.view
        let response = HTTPURLResponse(url: URL(string: "example")!, statusCode: 401, httpVersion: "", headerFields: [:])
        let errorType = ErrorType(error: .unauthorized(response: response, data: Data()))
        coordinator.displayError(errorType: errorType, animated: false)
        let screenNavigator = rootViewController.children.first as? UINavigationController
        let errorScreen = screenNavigator?.viewControllers.last as? ErrorScreenViewController
        errorScreen?.setupView()
        XCTAssertNotNil(
            errorScreen,
            "first view controller is not a ErrorScreenViewController")
        XCTAssertTrue(errorScreen?.errorHeader.text == ErrorType.authentication.title(), "Error title should match unauthorized error type")
        XCTAssertTrue(errorScreen?.errorContent.text == ErrorType.authentication.content(), "Error content should match unauthorized error type")
    }

    func testErrorServerError() {
        giniConfiguration.multipageEnabled = false
        let capturedImages = [GiniCaptureTestsHelper.loadImageDocument(named: "invoice")]

        let rootViewController = coordinator.start(withDocuments: capturedImages)
        _ = rootViewController.view
        let errorType = ErrorType(error: .server(errorCode: 502))
        coordinator.displayError(errorType: errorType, animated: false)
        let screenNavigator = rootViewController.children.first as? UINavigationController
        let errorScreen = screenNavigator?.viewControllers.last as? ErrorScreenViewController
        errorScreen?.setupView()
        XCTAssertNotNil(
            errorScreen,
            "first view controller is not a ErrorScreenViewController")
        XCTAssertTrue(errorScreen?.errorHeader.text == ErrorType.server.title(), "Error title should match server error type")
        XCTAssertTrue(errorScreen?.errorContent.text == ErrorType.server.content(), "Error content should match server error type")
        
    }

    func testMaintenanceError() {
        giniConfiguration.multipageEnabled = false
        let capturedImages = [GiniCaptureTestsHelper.loadImageDocument(named: "invoice")]

        let rootViewController = coordinator.start(withDocuments: capturedImages)
        _ = rootViewController.view
        let errorType = ErrorType(error: .maintenance(errorCode: 503))
        coordinator.displayError(errorType: errorType, animated: false)
        let screenNavigator = rootViewController.children.first as? UINavigationController
        let errorScreen = screenNavigator?.viewControllers.last as? ErrorScreenViewController
        errorScreen?.setupView()
        XCTAssertNotNil(
            errorScreen,
            "first view controller is not a ErrorScreenViewController")
        XCTAssertTrue(errorScreen?.errorHeader.text == ErrorType.maintenance.title(), "Error title should match server error type")
        XCTAssertTrue(errorScreen?.errorContent.text == ErrorType.maintenance.content(), "Error content should match server error type")

    }

    func testOutageError() {
        giniConfiguration.multipageEnabled = false
        let capturedImages = [GiniCaptureTestsHelper.loadImageDocument(named: "invoice")]

        let rootViewController = coordinator.start(withDocuments: capturedImages)
        _ = rootViewController.view
        let errorType = ErrorType(error: .outage(errorCode: 500))
        coordinator.displayError(errorType: errorType, animated: false)
        let screenNavigator = rootViewController.children.first as? UINavigationController
        let errorScreen = screenNavigator?.viewControllers.last as? ErrorScreenViewController
        errorScreen?.setupView()
        XCTAssertNotNil(
            errorScreen,
            "first view controller is not a ErrorScreenViewController")
        XCTAssertTrue(errorScreen?.errorHeader.text == ErrorType.outage.title(), "Error title should match server error type")
        XCTAssertTrue(errorScreen?.errorContent.text == ErrorType.outage.content(), "Error content should match server error type")

    }
}

// MARK: - Swift Testing coverage for the positiveAction decision

@Suite("GiniScreenAPICoordinator.positiveAction decision")
@MainActor
struct GiniScreenAPICoordinatorPositiveActionTests {

    /// Manual, minimal `GiniCaptureDelegate` conformance for the coordinator under test.
    /// `GiniCaptureDelegate` is an `@objc` protocol, so the stub must subclass `NSObject`.
    private final class DelegateStub: NSObject, GiniCaptureDelegate {
        func didPressEnterManually() {}
        func didCapture(document: GiniCaptureDocument,
                        networkDelegate: GiniCaptureNetworkDelegate) {}
        func didReview(documents: [GiniCaptureDocument],
                       networkDelegate: GiniCaptureNetworkDelegate) {}
        func didCancelCapturing() {}
        func didCancelReview(for document: GiniCaptureDocument) {}
        func didCancelAnalysis() {}
    }

    /// Builds a minimal coordinator + picker pair for the pure decision under test.
    /// No window, no presentation, no async — `positiveAction(...)` is a pure function.
    private func makeSubject() -> (coordinator: GiniScreenAPICoordinator,
                                   picker: DocumentPickerCoordinator) {
        let configuration = GiniConfiguration()
        configuration.openWithEnabled = true
        configuration.multipageEnabled = true

        let delegate = DelegateStub()
        let coordinator = GiniScreenAPICoordinator(withDelegate: delegate,
                                                   giniConfiguration: configuration)
        let picker = DocumentPickerCoordinator(giniConfiguration: configuration)
        return (coordinator, picker)
    }

    @Test("maxFilesPickedCountExceeded with existing pages returns a non-nil action")
    func testMaxFilesExceededWithExistingPagesReturnsAction() {
        let subject = makeSubject()
        let action = subject.coordinator.positiveAction(for: FilePickerError.maxFilesPickedCountExceeded,
                                                        hasExistingPages: true,
                                                        coordinator: subject.picker)
        #expect(action != nil)
    }

    @Test("maxFilesPickedCountExceeded with no existing pages returns nil")
    func testMaxFilesExceededWithoutExistingPagesReturnsNil() {
        let subject = makeSubject()
        let action = subject.coordinator.positiveAction(for: FilePickerError.maxFilesPickedCountExceeded,
                                                        hasExistingPages: false,
                                                        coordinator: subject.picker)
        #expect(action == nil)
    }

    @Test("mixedDocumentsUnsupported with no existing pages returns nil")
    func testMixedDocumentsWithoutExistingPagesReturnsNil() {
        let subject = makeSubject()
        let action = subject.coordinator.positiveAction(for: FilePickerError.mixedDocumentsUnsupported,
                                                        hasExistingPages: false,
                                                        coordinator: subject.picker)
        #expect(action == nil)
    }

    @Test("photoLibraryAccessDenied always returns nil")
    func testPhotoLibraryAccessDeniedReturnsNil() {
        let subject = makeSubject()
        let actionWithPages = subject.coordinator.positiveAction(for: FilePickerError.photoLibraryAccessDenied,
                                                                 hasExistingPages: true,
                                                                 coordinator: subject.picker)
        let actionWithoutPages = subject.coordinator.positiveAction(for: FilePickerError.photoLibraryAccessDenied,
                                                                    hasExistingPages: false,
                                                                    coordinator: subject.picker)
        #expect(actionWithPages == nil)
        #expect(actionWithoutPages == nil)
    }

    @Test("Non-FilePickerError returns nil regardless of existing pages")
    func testNonFilePickerErrorReturnsNil() {
        let subject = makeSubject()
        let error = NSError(domain: "test", code: 0)
        let action = subject.coordinator.positiveAction(for: error,
                                                        hasExistingPages: true,
                                                        coordinator: subject.picker)
        #expect(action == nil)
    }

    // MARK: - documentPicker(_:didPick:) end-to-end

    /**
     Runs the main run loop briefly so the async `validate(_:completion:)` pipeline
     can hop back to main and invoke the coordinator's success/failure handlers.
     */
    private func spinRunLoop(times: Int = 25) async {
        for _ in 0..<times {
            await Task.yield()
            RunLoop.current.run(until: Date().addingTimeInterval(0.02))
        }
    }

    /**
     Exercises the failure path through the public delegate entry: passing more
     than `maxPagesCount` documents trips `.maxFilesPickedCountExceeded`, which
     drives `handleFailure` → `positiveAction` → `presentError`. In a bare-bones
     coordinator neither `cameraScreen` nor `currentPickerViewController` is
     set, so `?.showErrorDialog(...)` no-ops cleanly. The invariant asserted:
     validation failure must not add pages to the document collection.
     */
    @Test("documentPicker(_:didPick:) with over-limit documents leaves pages unchanged")
    func testDocumentPickerFailurePathLeavesPagesUnchanged() async throws {
        let subject = makeSubject()
        let before = subject.coordinator.pages.count
        let overLimit = (0..<11).map { _ in
            GiniCaptureTestsHelper.loadImageDocument(named: "invoice")
        }

        subject.coordinator.documentPicker(subject.picker, didPick: overLimit)
        await spinRunLoop()

        #expect(subject.coordinator.pages.count == before)
    }

    /**
     Exercises the success path through the public delegate entry: a single
     valid image passes validation, drives `handlePickSuccess` →
     `addToDocuments` → navigation. The invariant asserted: a successful
     pick appends exactly one page to the collection.
     */
    @Test("documentPicker(_:didPick:) with valid document adds one page")
    func testDocumentPickerSuccessPathAppendsOnePage() async throws {
        let subject = makeSubject()
        // Prime the coordinator so cameraScreen exists and post-success
        // navigation has a nav stack to push onto — otherwise the closure
        // reaches for `nil` and the added page never lands.
        _ = subject.coordinator.start(withDocuments: nil)
        let before = subject.coordinator.pages.count
        let document = GiniCaptureTestsHelper.loadImageDocument(named: "invoice")

        subject.coordinator.documentPicker(subject.picker, didPick: [document])
        await spinRunLoop()

        #expect(subject.coordinator.pages.count == before + 1)
    }
}

// MARK: - GiniNetworkingScreenAPICoordinator — Wero extraction mapper

/**
 Covers the pure static mapper
 `GiniNetworkingScreenAPICoordinator.mapWeroExtractions(_:scannedPayload:)`
 that turns an `/analysis` extraction response into the single-extraction
 Wero result when the backend has classified the payload as Wero.

 All payload shapes live in a single
 `Resources/wero_extraction_fixtures.json` keyed by variant name — each
 variant encodes the extractions dict in the shape the backend returns
 (`name → { entity, value }`). Loading the file once per test keeps related
 payload shapes side by side for diffing while still letting individual
 tests ask for a named variant.
 */
@Suite("GiniNetworkingScreenAPICoordinator — Wero extraction mapper", .serialized)
struct GiniNetworkingScreenAPICoordinatorWeroMapperTests {

    private let sampleScannedPayload = "https://pay.weropay.eu/pay/v1/token=abc123"

    // MARK: - Happy path

    @Test("Wero label + scanned payload + flag on → single-extraction result")
    func weroLabelProducesSingleExtraction() throws {
        let input = try loadResult(fromFixture: "wero_type_only")
        try GiniCaptureTestsHelper.withWeroFlag(true) {
            let output = GiniNetworkingScreenAPICoordinator.mapWeroExtractions(
                input,
                scannedPayload: sampleScannedPayload
            )
            try expectWeroResult(output, payload: sampleScannedPayload)
        }
    }

    @Test("Wero label with other extractions → only Wero survives")
    func weroLabelDropsOtherExtractions() throws {
        let input = try loadResult(fromFixture: "wero_with_payment_extractions")
        try GiniCaptureTestsHelper.withWeroFlag(true) {
            let output = GiniNetworkingScreenAPICoordinator.mapWeroExtractions(
                input,
                scannedPayload: sampleScannedPayload
            )
            try expectWeroResult(output, payload: sampleScannedPayload)
            #expect(output.lineItems == nil, "lineItems must be cleared")
            #expect(output.skontoDiscounts == nil, "skontoDiscounts must be cleared")
            #expect(output.crossBorderPayment == nil, "crossBorderPayment must be cleared")
            #expect(output.candidates.isEmpty, "candidates must be empty")
        }
    }

    @Test("Mixed-case Wero key and value match case-insensitively")
    func weroLabelMatchesCaseInsensitively() throws {
        let input = try loadResult(fromFixture: "wero_mixed_case")
        try GiniCaptureTestsHelper.withWeroFlag(true) {
            let output = GiniNetworkingScreenAPICoordinator.mapWeroExtractions(
                input,
                scannedPayload: sampleScannedPayload
            )
            try expectWeroResult(output, payload: sampleScannedPayload)
        }
    }

    // MARK: - Pass-through cases

    @Test("Non-Wero classification → pass-through")
    func nonWeroClassificationPassesThrough() throws {
        let input = try loadResult(fromFixture: "non_wero_classification")
        GiniCaptureTestsHelper.withWeroFlag(true) {
            let output = GiniNetworkingScreenAPICoordinator.mapWeroExtractions(
                input,
                scannedPayload: sampleScannedPayload
            )
            #expect(output === input, "Non-Wero response must not be rewritten")
        }
    }

    @Test("paymentQRCodeType missing from response → pass-through")
    func missingClassificationPassesThrough() throws {
        let input = try loadResult(fromFixture: "missing_payment_qr_code_type")
        GiniCaptureTestsHelper.withWeroFlag(true) {
            let output = GiniNetworkingScreenAPICoordinator.mapWeroExtractions(
                input,
                scannedPayload: sampleScannedPayload
            )
            #expect(output === input, "Response without paymentQRCodeType must not be rewritten")
        }
    }

    @Test("Flag off → pass-through even when the backend returned the Wero label")
    func weroLabelPassesThroughWhenFlagOff() throws {
        let input = try loadResult(fromFixture: "wero_type_only")
        GiniCaptureTestsHelper.withWeroFlag(false) {
            let output = GiniNetworkingScreenAPICoordinator.mapWeroExtractions(
                input,
                scannedPayload: sampleScannedPayload
            )
            #expect(output === input, "Flag off must preserve the backend response verbatim")
        }
    }

    @Test("Scanned payload nil → pass-through (picture/PDF open-with path)")
    func nilScannedPayloadPassesThrough() throws {
        let input = try loadResult(fromFixture: "wero_type_only")
        GiniCaptureTestsHelper.withWeroFlag(true) {
            let output = GiniNetworkingScreenAPICoordinator.mapWeroExtractions(
                input,
                scannedPayload: nil
            )
            #expect(output === input,
                    "Mapper has no on-device payload for picture/PDF uploads; existing no-results flow fires")
        }
    }

    // MARK: - Keyword independence

    /// Six URL shapes that must all round-trip through the mapper unchanged in
    /// value — four Sparkasse production domains plus two legacy EU payment
    /// schemes that count as Wero but contain neither the string "wero" nor
    /// any Wero-specific keyword. The mapper must not inspect the payload
    /// format; it only forwards whatever the camera scanned.
    @Test("Scanned payload is passed through verbatim regardless of URL shape",
          arguments: [
            "https://pay.weropay.eu/pay/v1/eyJhbGciOiJIUzI1NiJ9",
            "https://pay.wero-wallet.eu/direct/token-abc123",
            "https://qr.weropay.eu/redirect/qr/9f8e7d",
            "https://share.weropay.eu/p2p/invite/alice",
            "https://ideal.nl/pay?trxid=1234567890",
            "https://payconiq.com/t/1/ABCDEF"
          ])
    func scannedPayloadRoundTripsVerbatim(_ payload: String) throws {
        let input = try loadResult(fromFixture: "wero_type_only")
        try GiniCaptureTestsHelper.withWeroFlag(true) {
            let output = GiniNetworkingScreenAPICoordinator.mapWeroExtractions(
                input,
                scannedPayload: payload
            )
            try expectWeroResult(output, payload: payload)
        }
    }

    // MARK: - Helpers

    private static let fixtureBundleName = "wero_extraction_fixtures"

    private func loadResult(fromFixture variant: String) throws -> ExtractionResult {
        guard let fixtureURL = Bundle.module.url(forResource: Self.fixtureBundleName,
                                                 withExtension: "json") else {
            throw FixtureError.bundleNotFound(Self.fixtureBundleName)
        }
        let data = try Data(contentsOf: fixtureURL)
        let bundle = try JSONDecoder().decode([String: [String: ExtractionFixture]].self, from: data)
        guard let raw = bundle[variant] else {
            throw FixtureError.variantNotFound(variant)
        }
        let extractions = raw.map { key, value in
            Extraction(box: nil,
                       candidates: nil,
                       entity: value.entity,
                       value: value.value,
                       name: key)
        }
        return ExtractionResult(extractions: extractions, candidates: [:])
    }

    /// Shape-asserts that `result` is the Wero single-extraction result with
    /// the expected scanned payload as the extraction value.
    private func expectWeroResult(_ result: ExtractionResult, payload: String) throws {
        #expect(result.extractions.count == 1, "Wero result must contain exactly one extraction")
        let extraction = try #require(result.extractions.first,
                                      "Wero result must contain exactly one extraction")
        #expect(extraction.name == QRCodesExtractor.weroPaymentQRCodeUrlKey,
                "Extraction name must be weroPaymentQRCodeUrlKey")
        #expect(extraction.entity == QRCodesExtractor.weroPaymentQRCodeUrlKey,
                "Extraction entity must be weroPaymentQRCodeUrlKey")
        #expect(extraction.value == payload, "Extraction value must be the raw scanned payload")
        #expect(extraction.box == nil, "box must be nil")
        #expect(extraction.candidates == nil, "candidates must be nil")
    }

    private struct ExtractionFixture: Decodable {
        let entity: String
        let value: String
    }

    private enum FixtureError: Error {
        case bundleNotFound(String)
        case variantNotFound(String)
    }
}
