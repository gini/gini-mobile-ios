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
        let input = try loadWeroFixtureResult("wero_type_only")
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
        let input = try loadWeroFixtureResult("wero_with_payment_extractions")
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
        let input = try loadWeroFixtureResult("wero_mixed_case")
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
        let input = try loadWeroFixtureResult("non_wero_classification")
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
        let input = try loadWeroFixtureResult("missing_payment_qr_code_type")
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
        let input = try loadWeroFixtureResult("wero_type_only")
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
        let input = try loadWeroFixtureResult("wero_type_only")
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

    /**
     Six URL shapes that must all round-trip through the mapper unchanged in
     value — four Sparkasse production domains plus two legacy EU payment
     schemes that count as Wero but contain neither the string "wero" nor
     any Wero-specific keyword. The mapper must not inspect the payload
     format; it only forwards whatever the camera scanned.
     */
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
        let input = try loadWeroFixtureResult("wero_type_only")
        try GiniCaptureTestsHelper.withWeroFlag(true) {
            let output = GiniNetworkingScreenAPICoordinator.mapWeroExtractions(
                input,
                scannedPayload: payload
            )
            try expectWeroResult(output, payload: payload)
        }
    }

    // MARK: - Helpers

    /**
     Shape-asserts that `result` is the Wero single-extraction result with
     the expected scanned payload as the extraction value.
     */
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
}

// MARK: - Wero fixture loader (shared across suites)

private let weroFixtureBundleName = "wero_extraction_fixtures"

private struct WeroExtractionFixture: Decodable {
    let entity: String
    let value: String
}

private enum WeroFixtureError: Error {
    case bundleNotFound(String)
    case variantNotFound(String)
}

/**
 Loads a named variant from `Resources/wero_extraction_fixtures.json` into
 an `ExtractionResult`. Shared by all suites that need fixture-driven Wero
 inputs (mapper tests, deliver tests).
 */
private func loadWeroFixtureResult(_ variant: String) throws -> ExtractionResult {
    guard let fixtureURL = Bundle.module.url(forResource: weroFixtureBundleName,
                                             withExtension: "json") else {
        throw WeroFixtureError.bundleNotFound(weroFixtureBundleName)
    }
    let data = try Data(contentsOf: fixtureURL)
    let bundle = try JSONDecoder().decode([String: [String: WeroExtractionFixture]].self, from: data)
    guard let raw = bundle[variant] else {
        throw WeroFixtureError.variantNotFound(variant)
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

// MARK: - GiniNetworkingScreenAPICoordinator — Wero camera-fallback gate

/**
 Covers `GiniNetworkingScreenAPICoordinator.shouldRouteBackToCameraForWeroFallback`.
 This is the pure-of-coordinator-state gate that decides whether the delivery
 pipeline must route back to the camera (Wero fallback) rather than show the
 no-results screen. Each branch of the guard chain is exercised explicitly.
 */
@Suite("GiniNetworkingScreenAPICoordinator — shouldRouteBackToCameraForWeroFallback", .serialized)
struct GiniNetworkingScreenAPICoordinatorWeroFallbackGateTests {

    private let weroCandidatePage = GiniCapturePage(
        document: GiniQRCodeDocument(scannedString: "https://pay.weropay.eu/pay/v1/token=abc")
    )

    /// A QR document with a recognised Gini format — `qrCodeFormat` is non-nil, so
    /// the page does NOT count as a Wero candidate.
    private let giniQRCodePage = GiniCapturePage(
        document: GiniQRCodeDocument(
            scannedString: "https://pay.gini.net/482a6cc2-8247-4724-af5d-24cc44408254"
        )
    )

    private func emptyResult() -> ExtractionResult {
        ExtractionResult(extractions: [], candidates: [:])
    }

    private func resultWithWeroUrl(usingEntity: Bool) -> ExtractionResult {
        let key = QRCodesExtractor.weroPaymentQRCodeUrlKey
        let extraction = Extraction(box: nil,
                                    candidates: nil,
                                    entity: usingEntity ? key : "other",
                                    value: "https://pay.weropay.eu/x",
                                    name: usingEntity ? "other" : key)
        return ExtractionResult(extractions: [extraction], candidates: [:])
    }

    @Test("Flag off → never routes back, even with a Wero-candidate QR page")
    func flagOffReturnsFalse() throws {
        try GiniCaptureTestsHelper.withWeroFlag(false) {
            let decision = GiniNetworkingScreenAPICoordinator
                .shouldRouteBackToCameraForWeroFallback(pages: [weroCandidatePage],
                                                        extractionResult: emptyResult())
            #expect(decision == false)
        }
    }

    @Test("Flag on + no QR page → false (no candidate to recover)")
    func noQRPageReturnsFalse() throws {
        try GiniCaptureTestsHelper.withWeroFlag(true) {
            let decision = GiniNetworkingScreenAPICoordinator
                .shouldRouteBackToCameraForWeroFallback(pages: [],
                                                        extractionResult: emptyResult())
            #expect(decision == false)
        }
    }

    @Test("Flag on + QR page with known format → false (already classified)")
    func knownQRCodeFormatReturnsFalse() throws {
        /// `giniQRCode` scanned strings resolve `qrCodeFormat` to a non-nil value,
        /// so the page is not a Wero candidate; the fallback should not trigger.
        try GiniCaptureTestsHelper.withWeroFlag(true) {
            let decision = GiniNetworkingScreenAPICoordinator
                .shouldRouteBackToCameraForWeroFallback(pages: [giniQRCodePage],
                                                        extractionResult: emptyResult())
            #expect(decision == false)
        }
    }

    @Test("Flag on + Wero-candidate QR + empty extractions → true")
    func weroCandidateWithEmptyExtractionsReturnsTrue() throws {
        try GiniCaptureTestsHelper.withWeroFlag(true) {
            let decision = GiniNetworkingScreenAPICoordinator
                .shouldRouteBackToCameraForWeroFallback(pages: [weroCandidatePage],
                                                        extractionResult: emptyResult())
            #expect(decision == true)
        }
    }

    @Test("Flag on + Wero-candidate QR + extraction already keyed by name → false")
    func weroUrlAlreadyPresentByNameReturnsFalse() throws {
        try GiniCaptureTestsHelper.withWeroFlag(true) {
            let decision = GiniNetworkingScreenAPICoordinator
                .shouldRouteBackToCameraForWeroFallback(
                    pages: [weroCandidatePage],
                    extractionResult: resultWithWeroUrl(usingEntity: false)
                )
            #expect(decision == false)
        }
    }

    @Test("Flag on + Wero-candidate QR + extraction already keyed by entity → false")
    func weroUrlAlreadyPresentByEntityReturnsFalse() throws {
        try GiniCaptureTestsHelper.withWeroFlag(true) {
            let decision = GiniNetworkingScreenAPICoordinator
                .shouldRouteBackToCameraForWeroFallback(
                    pages: [weroCandidatePage],
                    extractionResult: resultWithWeroUrl(usingEntity: true)
                )
            #expect(decision == false)
        }
    }
}

// MARK: - GiniNetworkingScreenAPICoordinator — performWeroFallbackIfNeeded (shared executor)

/**
 Covers the shared executor `performWeroFallbackIfNeeded` used by both the
 CaptureSDK `deliver` call site and the BankSDK `presentNextScreen` call
 site. The gate branches are already covered in
 `GiniNetworkingScreenAPICoordinatorWeroFallbackGateTests`; these tests
 lock down the side-effects (delegate call + documentService reset) that
 fire when the gate returns true, plus the no-op path when it returns false.
 */
@Suite("GiniNetworkingScreenAPICoordinator — performWeroFallbackIfNeeded", .serialized)
@MainActor
struct GiniNetworkingScreenAPICoordinatorPerformWeroFallbackTests {

    /**
     Manual, minimal `AnalysisDelegate` stub that records whether the
     optional `tryDisplayInvalidQRMessage()` method was called.
     */
    private final class AnalysisDelegateSpy: NSObject, AnalysisDelegate {
        var tryDisplayInvalidQRMessageCallCount = 0
        var tryDisplayNoResultsScreenCallCount = 0
        func displayError(errorType: ErrorType, animated: Bool) {}
        func tryDisplayNoResultsScreen() { tryDisplayNoResultsScreenCallCount += 1 }
        func tryDisplayInvalidQRMessage() { tryDisplayInvalidQRMessageCallCount += 1 }
    }

    /**
     Manual `DocumentServiceProtocol` stub that only observes
     `resetToInitialState()`. All other requirements are no-op since the
     subject under test does not call them.
     */
    private final class DocumentServiceSpy: DocumentServiceProtocol {
        var document: Document?
        var metadata: Document.Metadata?
        var analysisCancellationToken: CancellationToken?
        var resetToInitialStateCallCount = 0

        func cancelAnalysis() {}
        func remove(document: GiniCaptureDocument) {}
        func resetToInitialState() { resetToInitialStateCallCount += 1 }
        func sendFeedback(with updatedExtractions: [Extraction],
                          updatedCompoundExtractions: [String: [[Extraction]]]?) {}
        func sendSkontoFeedback(with updatedExtractions: [Extraction],
                                updatedCompoundExtractions: [String: [[Extraction]]]?,
                                retryCount: Int) {}
        func startAnalysis(completion: @escaping AnalysisCompletion) {}
        func sortDocuments(withSameOrderAs documents: [GiniCaptureDocument]) {}
        func upload(document: GiniCaptureDocument, completion: UploadDocumentCompletion?) {}
        func update(imageDocument: GiniImageDocument) {}
        func log(errorEvent: ErrorEvent) {}
        func layout(completion: @escaping DocumentLayoutCompletion) {}
        func pages(completion: @escaping DocumentPagsCompletion) {}
        func documentPage(pageNumber: Int,
                          size: Document.Page.Size,
                          completion: @escaping DocumentPagePreviewCompletion) {}
    }

    private let weroCandidatePage = GiniCapturePage(
        document: GiniQRCodeDocument(scannedString: "https://pay.weropay.eu/pay/v1/token=abc")
    )

    private func emptyResult() -> ExtractionResult {
        ExtractionResult(extractions: [], candidates: [:])
    }

    @Test("Gate fires → delegate notified, documentService reset, returns true")
    func fallbackFiresWhenGateReturnsTrue() throws {
        let delegate = AnalysisDelegateSpy()
        let documentService = DocumentServiceSpy()
        var didFallback = false

        try GiniCaptureTestsHelper.withWeroFlag(true) {
            didFallback = GiniNetworkingScreenAPICoordinator.performWeroFallbackIfNeeded(
                pages: [weroCandidatePage],
                extractionResult: emptyResult(),
                delegate: delegate,
                documentService: documentService
            )
        }

        #expect(didFallback == true)
        #expect(delegate.tryDisplayInvalidQRMessageCallCount == 1)
        #expect(documentService.resetToInitialStateCallCount == 1)
    }

    @Test("Gate does not fire → no side effects, returns false")
    func fallbackSkippedWhenGateReturnsFalse() throws {
        let delegate = AnalysisDelegateSpy()
        let documentService = DocumentServiceSpy()
        var didFallback = true

        /// Flag off → gate returns false regardless of pages/extractions.
        try GiniCaptureTestsHelper.withWeroFlag(false) {
            didFallback = GiniNetworkingScreenAPICoordinator.performWeroFallbackIfNeeded(
                pages: [weroCandidatePage],
                extractionResult: emptyResult(),
                delegate: delegate,
                documentService: documentService
            )
        }

        #expect(didFallback == false)
        #expect(delegate.tryDisplayInvalidQRMessageCallCount == 0)
        #expect(documentService.resetToInitialStateCallCount == 0)
    }

    /// Delegate that omits the `@objc optional tryDisplayInvalidQRMessage`.
    private final class AnalysisDelegateWithoutOptionalSpy: NSObject, AnalysisDelegate {
        var tryDisplayNoResultsScreenCallCount = 0
        func displayError(errorType: ErrorType, animated: Bool) {}
        func tryDisplayNoResultsScreen() { tryDisplayNoResultsScreenCallCount += 1 }
    }

    @Test("Gate fires + delegate omits optional method → tryDisplayNoResultsScreen fallback")
    func fallbackCallsNoResultsWhenOptionalIsMissing() throws {
        let delegate = AnalysisDelegateWithoutOptionalSpy()
        let documentService = DocumentServiceSpy()
        var didFallback = false

        try GiniCaptureTestsHelper.withWeroFlag(true) {
            didFallback = GiniNetworkingScreenAPICoordinator.performWeroFallbackIfNeeded(
                pages: [weroCandidatePage],
                extractionResult: emptyResult(),
                delegate: delegate,
                documentService: documentService
            )
        }

        #expect(didFallback == true)
        #expect(delegate.tryDisplayNoResultsScreenCallCount == 1,
                "Must fall back to tryDisplayNoResultsScreen when the optional isn't implemented")
        #expect(documentService.resetToInitialStateCallCount == 1)
    }
}

// MARK: - GiniNetworkingScreenAPICoordinator — mapWeroExtractionsIfApplicable (instance method)

/**
 Covers the instance-method bridge `mapWeroExtractionsIfApplicable(_:)` which
 picks the first `GiniQRCodeDocument.scannedPayload` from `pages` and feeds it
 to the static `mapWeroExtractions`. The static mapper itself is covered
 exhaustively in `GiniNetworkingScreenAPICoordinatorWeroMapperTests` — these
 tests only verify the pages → scannedPayload wiring.
 */
@Suite("GiniNetworkingScreenAPICoordinator — mapWeroExtractionsIfApplicable", .serialized)
@MainActor
struct GiniNetworkingScreenAPICoordinatorInstanceMapperTests {

    /**
     Minimal `GiniCaptureResultsDelegate` so the coordinator initialiser accepts it.
     None of its callbacks fire in these tests — the subject under test is a pure
     read of `pages`.
     */
    private final class ResultsDelegateStub: NSObject, GiniCaptureResultsDelegate {
        func giniCaptureAnalysisDidFinishWith(result: AnalysisResult) {}
        func giniCaptureDidCancelAnalysis() {}
        func giniCaptureDidEnterManually() {}
    }

    private let sampleScannedPayload = "https://pay.weropay.eu/pay/v1/token=xyz"

    private func makeCoordinator() -> GiniNetworkingScreenAPICoordinator {
        GiniNetworkingScreenAPICoordinator(resultsDelegate: ResultsDelegateStub(),
                                           giniConfiguration: GiniConfiguration(),
                                           documentMetadata: nil,
                                           trackingDelegate: nil,
                                           captureNetworkService: MockCaptureNetworkService())
    }

    private func weroExtractionResult() -> ExtractionResult {
        let extraction = Extraction(box: nil,
                                    candidates: nil,
                                    entity: QRCodesExtractor.paymentQRCodeTypeKey,
                                    value: QRCodesExtractor.weroPaymentQRCodeTypeValue,
                                    name: QRCodesExtractor.paymentQRCodeTypeKey)
        return ExtractionResult(extractions: [extraction], candidates: [:])
    }

    @Test("Wero-candidate QR page in pages → scannedPayload forwarded to mapper")
    func qrPagePayloadForwardedToMapper() throws {
        let coordinator = makeCoordinator()
        coordinator.pages = [
            GiniCapturePage(document: GiniQRCodeDocument(scannedString: sampleScannedPayload))
        ]

        try GiniCaptureTestsHelper.withWeroFlag(true) {
            let output = coordinator.mapWeroExtractionsIfApplicable(weroExtractionResult())

            /// The static mapper rewrites to a single Wero-URL extraction whose
            /// value is the scanned payload — proof that `pages` were inspected
            /// and the payload was forwarded.
            #expect(output.extractions.count == 1)
            let extraction = try #require(output.extractions.first)
            #expect(extraction.name == QRCodesExtractor.weroPaymentQRCodeUrlKey)
            #expect(extraction.value == sampleScannedPayload)
        }
    }

    @Test("No QR page in pages → nil scannedPayload, mapper passes result through")
    func noQRPageYieldsPassThrough() throws {
        let coordinator = makeCoordinator()
        coordinator.pages = []  // No QR document → scannedPayload is nil

        try GiniCaptureTestsHelper.withWeroFlag(true) {
            let input = weroExtractionResult()
            let output = coordinator.mapWeroExtractionsIfApplicable(input)

            /// Mapper short-circuits on `nil` scannedPayload — the input is
            /// returned verbatim (reference-equal here because `ExtractionResult`
            /// is a class).
            #expect(output === input)
        }
    }
}

// MARK: - GiniScreenAPICoordinator.tryDisplayInvalidQRMessage — camera-absent fallback

/**
 Covers the camera-absent branch of `tryDisplayInvalidQRMessage()`.

 The camera-present branch is intentionally NOT exercised: `CameraViewController`
 initialisation runs lens discovery and loads a UIKit nib, and the
 `showUnsupportedQRCodeFeedback()` path it reaches touches outlets
 (`qrCodeOverLay`, `cameraPreviewViewController`, `cameraPane`) that require
 the view to be fully loaded. That is fragile UIKit internals, not business
 logic — the house rule here is "no useless tests to cover". The fallback branch
 (camera VC absent → `tryDisplayNoResultsScreen()`) is the business decision
 worth asserting.
 */
@Suite("GiniScreenAPICoordinator.tryDisplayInvalidQRMessage — camera-absent branch")
@MainActor
struct GiniScreenAPICoordinatorInvalidQRMessageTests {

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

    @Test("No CameraViewController in nav stack → falls back to no-results screen for QR pages")
    func cameraAbsentFallsBackToNoResultsScreen() async throws {
        let configuration = GiniConfiguration()
        let coordinator = GiniScreenAPICoordinator(withDelegate: DelegateStub(),
                                                   giniConfiguration: configuration)

        /// Seed `pages` with a QR document so `pages.type == .qrcode` and
        /// `tryDisplayNoResultsScreen` actually pushes a `NoResultScreenViewController`
        /// (the `.qrcode` case sets `shouldDisplay = true`).
        coordinator.pages = [
            GiniCapturePage(document: GiniQRCodeDocument(scannedString: "https://pay.weropay.eu/x"))
        ]

        /// Replace the nav stack with a plain non-camera VC so the camera-lookup
        /// guard inside `tryDisplayInvalidQRMessage` fails.
        let placeholder = UIViewController()
        coordinator.screenAPINavigationController.setViewControllers([placeholder], animated: false)
        #expect(coordinator.screenAPINavigationController.viewControllers.count == 1)

        coordinator.tryDisplayInvalidQRMessage()

        /// `tryDisplayInvalidQRMessage` hops to main, calls `tryDisplayNoResultsScreen`,
        /// which hops to main again to push. Spin the run loop twice to let both
        /// dispatches drain deterministically — no `Thread.sleep`, no 0.4s wait
        /// (that delay only runs on the camera-present branch).
        for _ in 0..<2 {
            await Task.yield()
            await MainActor.run {
                RunLoop.current.run(until: Date().addingTimeInterval(0.02))
            }
        }

        let topViewController = coordinator.screenAPINavigationController.topViewController
        #expect(topViewController is NoResultScreenViewController,
                "Camera-absent branch must fall through to the no-results screen push")
    }
}

// MARK: - GiniNetworkingScreenAPICoordinator — deliver(result:and:to:)

/**
 Covers the three branches of `deliver(result:and:to:)` on the shared
 `GiniNetworkingScreenAPICoordinator`: the extractions-success path, the
 Wero-fallback path, and the no-results path. The main dispatch is drained
 via `RunLoop` so each branch runs synchronously enough to assert on the
 side-effects captured by the spies.
 */
@Suite("GiniNetworkingScreenAPICoordinator — deliver(result:and:to:)", .serialized)
@MainActor
struct GiniNetworkingScreenAPICoordinatorDeliverTests {

    private final class ResultsDelegateSpy: NSObject, GiniCaptureResultsDelegate {
        var didFinishResultCallCount = 0
        var lastResult: AnalysisResult?
        func giniCaptureAnalysisDidFinishWith(result: AnalysisResult) {
            didFinishResultCallCount += 1
            lastResult = result
        }
        func giniCaptureDidCancelAnalysis() {}
        func giniCaptureDidEnterManually() {}
    }

    private final class AnalysisDelegateSpy: NSObject, AnalysisDelegate {
        var tryDisplayInvalidQRMessageCallCount = 0
        var tryDisplayNoResultsScreenCallCount = 0
        func displayError(errorType: ErrorType, animated: Bool) {}
        func tryDisplayNoResultsScreen() { tryDisplayNoResultsScreenCallCount += 1 }
        func tryDisplayInvalidQRMessage() { tryDisplayInvalidQRMessageCallCount += 1 }
    }

    private func makeCoordinator(resultsDelegate: ResultsDelegateSpy = .init()) -> (
        coordinator: GiniNetworkingScreenAPICoordinator,
        resultsDelegate: ResultsDelegateSpy
    ) {
        let coordinator = GiniNetworkingScreenAPICoordinator(resultsDelegate: resultsDelegate,
                                                             giniConfiguration: GiniConfiguration(),
                                                             documentMetadata: nil,
                                                             trackingDelegate: nil,
                                                             captureNetworkService: MockCaptureNetworkService())
        return (coordinator, resultsDelegate)
    }

    /**
     Drains main-queue work queued by `deliver(result:and:to:)` so the spies observe it.
     Mirrors the pattern used by `GiniScreenAPICoordinatorInvalidQRMessageTests`.
     */
    private func drainMain(iterations: Int = 10) async {
        for _ in 0..<iterations {
            await Task.yield()
            await MainActor.run {
                RunLoop.current.run(until: Date().addingTimeInterval(0.02))
            }
        }
    }

    @Test("Extractions present → results delegate receives AnalysisResult")
    func extractionsPresentDeliversToResultsDelegate() async throws {
        let subject = makeCoordinator()
        let delegate = AnalysisDelegateSpy()

        let extraction = Extraction(box: nil,
                                    candidates: nil,
                                    entity: "amount",
                                    value: "42.00:EUR",
                                    name: "amountToPay")
        let result = ExtractionResult(extractions: [extraction], candidates: [:])

        subject.coordinator.deliver(result: result, to: delegate)
        await drainMain()

        #expect(subject.resultsDelegate.didFinishResultCallCount == 1)
        #expect(subject.resultsDelegate.lastResult?.extractions["amountToPay"] != nil)
        #expect(delegate.tryDisplayInvalidQRMessageCallCount == 0)
        #expect(delegate.tryDisplayNoResultsScreenCallCount == 0)
    }

    @Test("Wero extractions present → URL-only AnalysisResult (EPS parity)")
    func weroExtractionsDeliverURLOnlyShape() async throws {
        let subject = makeCoordinator()
        let delegate = AnalysisDelegateSpy()
        let result = try loadWeroFixtureResult("confirmed_wero_url")
        let expectedURL = try #require(result.extractions.first?.value)

        subject.coordinator.deliver(result: result, to: delegate)
        await drainMain()

        #expect(subject.resultsDelegate.didFinishResultCallCount == 1)
        let delivered = try #require(subject.resultsDelegate.lastResult)
        #expect(delivered.extractions[QRCodesExtractor.weroPaymentQRCodeUrlKey]?.value == expectedURL)
        /// EPS parity: no document, images, or line items on a Wero delivery.
        #expect(delivered.document == nil)
        #expect(delivered.images.isEmpty)
        #expect(delivered.lineItems?.count == 0)
    }

    @Test("Nonempty non-Wero extractions + Wero candidate + flag on → invalid-QR message")
    func nonEmptyNonWeroExtractionsWithWeroCandidateHitsFallback() async throws {
        let subject = makeCoordinator()
        let delegate = AnalysisDelegateSpy()

        subject.coordinator.pages = [
            GiniCapturePage(document: GiniQRCodeDocument(scannedString: "https://pay.weropay.eu/x"))
        ]

        /// `non_wero_classification` fixture: `paymentQRCodeType=epc` + an IBAN.
        /// Simulates a backend response that is nonempty but is NOT a confirmed Wero.
        let result = try loadWeroFixtureResult("non_wero_classification")

        let previousFlag = GiniCaptureUserDefaultsStorage.weroQRCodeScanningEnabled
        GiniCaptureTestsHelper.acquireFlagLock()
        GiniCaptureUserDefaultsStorage.weroQRCodeScanningEnabled = true
        defer {
            GiniCaptureUserDefaultsStorage.weroQRCodeScanningEnabled = previousFlag
            GiniCaptureTestsHelper.releaseFlagLock()
        }

        subject.coordinator.deliver(result: result, to: delegate)
        await drainMain()

        #expect(delegate.tryDisplayInvalidQRMessageCallCount == 1,
                "Wero fallback must fire for a Wero-candidate scan with a non-Wero response")
        #expect(subject.resultsDelegate.didFinishResultCallCount == 0,
                "Garbage data must not reach the results callback")
        #expect(delegate.tryDisplayNoResultsScreenCallCount == 0,
                "No-results path is bypassed when the fallback fires")
    }

    @Test("Empty extractions + Wero candidate + flag on → invalid-QR message")
    func noExtractionsWithWeroCandidateHitsFallback() async throws {
        let subject = makeCoordinator()
        let delegate = AnalysisDelegateSpy()

        subject.coordinator.pages = [
            GiniCapturePage(document: GiniQRCodeDocument(scannedString: "https://pay.weropay.eu/x"))
        ]

        /// Acquire the flag lock manually (not via `withWeroFlag`) because the
        /// Wero gate check runs inside `deliver`'s async main dispatch, and we
        /// need the flag to stay set across the `await drainMain()` call.
        let previousFlag = GiniCaptureUserDefaultsStorage.weroQRCodeScanningEnabled
        GiniCaptureTestsHelper.acquireFlagLock()
        GiniCaptureUserDefaultsStorage.weroQRCodeScanningEnabled = true
        defer {
            GiniCaptureUserDefaultsStorage.weroQRCodeScanningEnabled = previousFlag
            GiniCaptureTestsHelper.releaseFlagLock()
        }

        subject.coordinator.deliver(result: ExtractionResult(extractions: [], candidates: [:]),
                                    to: delegate)
        await drainMain()

        #expect(delegate.tryDisplayInvalidQRMessageCallCount == 1,
                "Wero fallback must notify the delegate when the gate fires")
        #expect(delegate.tryDisplayNoResultsScreenCallCount == 0,
                "No-results path must be skipped when Wero fallback fires")
        #expect(subject.resultsDelegate.didFinishResultCallCount == 0)
    }

    @Test("Empty extractions + no Wero candidate → no-results screen")
    func noExtractionsWithoutWeroCandidateFallsThroughToNoResults() async throws {
        let subject = makeCoordinator()
        let delegate = AnalysisDelegateSpy()

        /// No pages → `shouldRouteBackToCameraForWeroFallback` returns false
        /// regardless of flag → no flag override is needed here.
        subject.coordinator.deliver(result: ExtractionResult(extractions: [], candidates: [:]),
                                    to: delegate)
        await drainMain()

        #expect(delegate.tryDisplayNoResultsScreenCallCount == 1)
        #expect(delegate.tryDisplayInvalidQRMessageCallCount == 0)
        #expect(subject.resultsDelegate.didFinishResultCallCount == 0)
    }
}
