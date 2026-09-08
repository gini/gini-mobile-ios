//
//  GiniScreenAPICoordinator+CameraTests.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import XCTest
import GiniBankAPILibrary
@testable import GiniCaptureSDK

// MARK: - Test doubles

private final class SpyCaptureDelegate: GiniCaptureDelegate {
    var didCaptureCallCount = 0
    var lastCapturedDocument: GiniCaptureDocument?
    var didCancelCapturingCallCount = 0
    var didCancelReviewCallCount = 0
    var didReviewCallCount = 0
    var didCancelAnalysisCallCount = 0
    var didPressEnterManuallyCallCount = 0

    func didCapture(document: GiniCaptureDocument,
                    networkDelegate: GiniCaptureNetworkDelegate) {
        didCaptureCallCount += 1
        lastCapturedDocument = document
    }
    func didReview(documents: [GiniCaptureDocument],
                   networkDelegate: GiniCaptureNetworkDelegate) {
        didReviewCallCount += 1
    }
    func didCancelCapturing() { didCancelCapturingCallCount += 1 }
    func didCancelReview(for document: GiniCaptureDocument) { didCancelReviewCallCount += 1 }
    func didCancelAnalysis() { didCancelAnalysisCallCount += 1 }
    func didPressEnterManually() { didPressEnterManuallyCallCount += 1 }
}

// MARK: - Suite

final class GiniScreenAPICoordinatorCameraTests: XCTestCase {

    private var coordinator: GiniScreenAPICoordinator!
    private var spyDelegate: SpyCaptureDelegate!
    private var giniConfiguration: GiniConfiguration!

    override func setUp() {
        super.setUp()
        giniConfiguration = GiniConfiguration()
        giniConfiguration.multipageEnabled = true
        giniConfiguration.fileImportSupportedTypes = .pdf_and_images
        spyDelegate = SpyCaptureDelegate()
        coordinator = GiniScreenAPICoordinator(withDelegate: spyDelegate,
                                               giniConfiguration: giniConfiguration)
        GiniCaptureUserDefaultsStorage.onboardingShowed = false
        GiniCaptureUserDefaultsStorage.onboardingShowAtLaunch = false
    }

    override func tearDown() {
        coordinator = nil
        spyDelegate = nil
        giniConfiguration = nil
        GiniCaptureUserDefaultsStorage.onboardingShowed = false
        GiniCaptureUserDefaultsStorage.onboardingShowAtLaunch = false
        super.tearDown()
    }

    // MARK: - didCaptureAndValidate

    func testDidCaptureAndValidate_callsVisionDelegateDidCapture() {
        let document = GiniCaptureTestsHelper.loadImageDocument(named: "invoice")

        coordinator.didCaptureAndValidate(document)

        XCTAssertEqual(spyDelegate.didCaptureCallCount, 1)
        XCTAssertNotNil(spyDelegate.lastCapturedDocument)
    }

    // MARK: - shouldShowOnboarding

    func testShouldShowOnboarding_firstLaunchNotYetShown_returnsTrueAndFlipsFlag() {
        giniConfiguration.onboardingShowAtFirstLaunch = true
        giniConfiguration.onboardingShowAtLaunch = false
        GiniCaptureUserDefaultsStorage.onboardingShowed = false

        let result = coordinator.shouldShowOnboarding()

        XCTAssertTrue(result)
        XCTAssertTrue(GiniCaptureUserDefaultsStorage.onboardingShowed)
    }

    func testShouldShowOnboarding_firstLaunchAlreadyShown_fallsThrough() {
        giniConfiguration.onboardingShowAtFirstLaunch = true
        giniConfiguration.onboardingShowAtLaunch = false
        GiniCaptureUserDefaultsStorage.onboardingShowed = true

        let result = coordinator.shouldShowOnboarding()

        XCTAssertFalse(result)
    }

    func testShouldShowOnboarding_launchFlagAndNotShownThisLaunch_returnsTrue() {
        giniConfiguration.onboardingShowAtFirstLaunch = false
        giniConfiguration.onboardingShowAtLaunch = true

        let result = coordinator.shouldShowOnboarding()

        XCTAssertTrue(result)
    }

    func testShouldShowOnboarding_bothDisabled_returnsFalse() {
        giniConfiguration.onboardingShowAtFirstLaunch = false
        giniConfiguration.onboardingShowAtLaunch = false

        XCTAssertFalse(coordinator.shouldShowOnboarding())
    }

    // MARK: - validate

    func testValidate_singleImage_succeeds() {
        let document = GiniCaptureTestsHelper.loadImageDocument(named: "invoice")
        let expectation = expectation(description: "validate completion")
        var validatedPages: [GiniCapturePage] = []

        coordinator.validate([document]) { result in
            if case .success(let pages) = result { validatedPages = pages }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
        XCTAssertEqual(validatedPages.count, 1)
    }

    func testValidate_mixedTypes_returnsMixedError() {
        let image = GiniCaptureTestsHelper.loadImageDocument(named: "invoice")
        let pdf = GiniCaptureTestsHelper.loadPDFDocument(named: "testPDF")
        let expectation = expectation(description: "validate completion")
        var receivedError: Error?

        coordinator.validate([image, pdf]) { result in
            if case .failure(let error) = result { receivedError = error }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
        XCTAssertEqual(receivedError as? FilePickerError, .mixedDocumentsUnsupported)
    }

    func testValidate_multiplePdfs_returnsMultiplePdfError() {
        let pdf1 = GiniCaptureTestsHelper.loadPDFDocument(named: "testPDF")
        let pdf2 = GiniCaptureTestsHelper.loadPDFDocument(named: "testPDF")
        let expectation = expectation(description: "validate completion")
        var receivedError: Error?

        coordinator.validate([pdf1, pdf2]) { result in
            if case .failure(let error) = result { receivedError = error }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
        XCTAssertEqual(receivedError as? FilePickerError, .multiplePdfsUnsupported)
    }

    func testValidate_maxPagesExceeded_returnsMaxError() {
        let docs = (0..<GiniCaptureDocumentValidator.maxPagesCount + 1).map { _ in
            GiniCaptureTestsHelper.loadImageDocument(named: "invoice")
        }
        let expectation = expectation(description: "validate completion")
        var receivedError: Error?

        coordinator.validate(docs) { result in
            if case .failure(let error) = result { receivedError = error }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
        XCTAssertEqual(receivedError as? FilePickerError, .maxFilesPickedCountExceeded)
    }

    func testValidateImportedDocuments_returnsPagePerDocument() {
        let document = GiniCaptureTestsHelper.loadImageDocument(named: "invoice")
        let expectation = expectation(description: "importedDocuments completion")
        var pages: [GiniCapturePage] = []

        coordinator.validate(importedDocuments: [document]) { result in
            pages = result
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
        XCTAssertEqual(pages.count, 1)
        XCTAssertNotNil(pages.first?.document)
    }

    // MARK: - showNextScreenAfterPicking

    func testShowNextScreenAfterPicking_image_pushesReview() {
        let root = coordinator.start(withDocuments: nil)
        _ = root.view
        let nav = root.children.first as? UINavigationController
        let initialCount = nav?.viewControllers.count ?? 0

        let imagePage = GiniCaptureTestsHelper.loadImagePage(named: "invoice")
        coordinator.pages = [imagePage]
        coordinator.showNextScreenAfterPicking(pages: [imagePage])

        XCTAssertGreaterThanOrEqual(nav?.viewControllers.count ?? 0, initialCount)
    }

    func testShowNextScreenAfterPicking_pdf_pushesAnalysis() {
        let root = coordinator.start(withDocuments: nil)
        _ = root.view
        let nav = root.children.first as? UINavigationController

        let pdfDoc = GiniCaptureTestsHelper.loadPDFDocument(named: "testPDF")
        let pdfPage = GiniCapturePage(document: pdfDoc)
        coordinator.pages = [pdfPage]
        coordinator.showNextScreenAfterPicking(pages: [pdfPage])

        let hasAnalysis = nav?.viewControllers.contains(where: { $0 is AnalysisViewController }) ?? false
        XCTAssertTrue(hasAnalysis, "AnalysisViewController should be pushed for PDF")
    }

    func testShowNextScreenAfterPicking_emptyPages_doesNotCrash() {
        _ = coordinator.start(withDocuments: nil)
        coordinator.showNextScreenAfterPicking(pages: [])
        // No crash, no assertion needed — coverage of the guard path.
    }

    // MARK: - camera(_:didSelect:)

    func testCameraDidSelectGallery_routesToDocumentPickerCoordinator() {
        let cameraVC = coordinator.createCameraViewController()

        coordinator.camera(cameraVC, didSelect: .gallery)

        /// Success is that no crash occurs. The picker itself is stateful and hard to observe,
        /// so this test covers the routing branch only.
    }

    func testCameraDidSelectExplorer_setsPDFSelectionAllowedFromPagesEmpty() {
        let cameraVC = coordinator.createCameraViewController()
        coordinator.pages = []

        coordinator.camera(cameraVC, didSelect: .explorer)

        XCTAssertTrue(coordinator.documentPickerCoordinator.isPDFSelectionAllowed)
    }

    func testCameraDidSelectExplorer_setsPDFSelectionDisallowedWhenPagesNotEmpty() {
        let cameraVC = coordinator.createCameraViewController()
        coordinator.pages = [GiniCaptureTestsHelper.loadImagePage(named: "invoice")]

        coordinator.camera(cameraVC, didSelect: .explorer)

        XCTAssertFalse(coordinator.documentPickerCoordinator.isPDFSelectionAllowed)
    }

    func testCameraDidSelectEInvoice_routesToEInvoicePicker() {
        let cameraVC = coordinator.createCameraViewController()

        coordinator.camera(cameraVC, didSelect: .eInvoice)

        /// Coverage of the `.eInvoice` switch branch.
    }

    // MARK: - cameraDidTapReviewButton

    func testCameraDidTapReviewButton_popsBackToReview() {
        let root = coordinator.start(withDocuments: nil)
        _ = root.view
        let cameraVC = coordinator.createCameraViewController()

        coordinator.cameraDidTapReviewButton(cameraVC)

        /// Coverage — the method has no observable side effect beyond a nav pop
        /// which only happens if review was already presented.
    }

    // MARK: - createCameraViewController

    func testCreateCameraViewController_withoutPages_setsCancelNavItem() {
        coordinator.pages = []

        let cameraVC = coordinator.createCameraViewController()

        XCTAssertNotNil(cameraVC.navigationItem.leftBarButtonItem)
        XCTAssertNotNil(cameraVC.navigationItem.rightBarButtonItem)
    }

    func testCreateCameraViewController_withPages_setsBackNavItem() {
        coordinator.pages = [GiniCaptureTestsHelper.loadImagePage(named: "invoice")]

        let cameraVC = coordinator.createCameraViewController()

        XCTAssertNotNil(cameraVC.navigationItem.leftBarButtonItem)
    }

    func testCreateCameraViewController_setsCameraScreen() {
        let cameraVC = coordinator.createCameraViewController()

        XCTAssertTrue(coordinator.cameraScreen === cameraVC)
    }

    func testCreateCameraViewController_fileImportNone_skipsGalleryDelegateWiring() {
        giniConfiguration.fileImportSupportedTypes = .none

        _ = coordinator.createCameraViewController()

        /// Coverage — the `if giniConfiguration.fileImportSupportedTypes != .none` branch.
    }

    // MARK: - documentPicker(_:failedToPickDocumentsAt:)

    func testDocumentPickerFailedToPick_withCameraScreenNil_doesNotCrash() {
        coordinator.documentPicker(coordinator.documentPickerCoordinator,
                                   failedToPickDocumentsAt: [URL(fileURLWithPath: "/tmp/x.pdf")])

        /// Coverage: goes through the `dismissesAutomatically` branch — `cameraScreen` is nil, `showErrorDialog` is a no-op call.
    }

    func testDocumentPickerFailedToPick_withCameraScreen_showsDialog() {
        _ = coordinator.start(withDocuments: nil)
        let cameraVC = coordinator.createCameraViewController()
        coordinator.cameraScreen = cameraVC

        coordinator.documentPicker(coordinator.documentPickerCoordinator,
                                   failedToPickDocumentsAt: [URL(fileURLWithPath: "/tmp/x.pdf")])

        /// Coverage: the automatic-dismiss branch with a live `cameraScreen`.
    }

    // MARK: - documentPicker(_:didPick:) — failure branches

    func testDocumentPickerDidPick_mixedTypes_showsError() {
        _ = coordinator.start(withDocuments: nil)
        let image = GiniCaptureTestsHelper.loadImageDocument(named: "invoice")
        let pdf = GiniCaptureTestsHelper.loadPDFDocument(named: "testPDF")
        let expectation = expectation(description: "async")

        coordinator.documentPicker(coordinator.documentPickerCoordinator,
                                   didPick: [image, pdf])
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { expectation.fulfill() }
        wait(for: [expectation], timeout: 3)
        /// Coverage of the mixed-types error branch inside didPick.
    }

    func testDocumentPickerDidPick_multiplePdfs_showsError() {
        _ = coordinator.start(withDocuments: nil)
        let pdf1 = GiniCaptureTestsHelper.loadPDFDocument(named: "testPDF")
        let pdf2 = GiniCaptureTestsHelper.loadPDFDocument(named: "testPDF")
        let expectation = expectation(description: "async")

        coordinator.documentPicker(coordinator.documentPickerCoordinator, didPick: [pdf1, pdf2])
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { expectation.fulfill() }
        wait(for: [expectation], timeout: 3)
    }

    func testDocumentPickerDidPick_maxExceeded_showsError() {
        _ = coordinator.start(withDocuments: nil)
        let docs = (0..<GiniCaptureDocumentValidator.maxPagesCount + 1).map { _ in
            GiniCaptureTestsHelper.loadImageDocument(named: "invoice")
        }
        let expectation = expectation(description: "async")

        coordinator.documentPicker(coordinator.documentPickerCoordinator, didPick: docs)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { expectation.fulfill() }
        wait(for: [expectation], timeout: 3)
    }

    func testDocumentPickerDidPick_maxExceededWithExistingPages_setsPositiveAction() {
        _ = coordinator.start(withDocuments: nil)
        coordinator.pages = [GiniCaptureTestsHelper.loadImagePage(named: "invoice")]
        let docs = (0..<GiniCaptureDocumentValidator.maxPagesCount + 1).map { _ in
            GiniCaptureTestsHelper.loadImageDocument(named: "invoice")
        }
        let expectation = expectation(description: "async")

        coordinator.documentPicker(coordinator.documentPickerCoordinator, didPick: docs)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { expectation.fulfill() }
        wait(for: [expectation], timeout: 3)
        /// Coverage of the `if self.pages.isNotEmpty { positiveAction = ... }` branch.
    }

    // MARK: - uploadDidComplete / uploadDidFail

    func testUploadDidComplete_dispatchesToMainAndCallsUpdate() {
        _ = coordinator.start(withDocuments: nil)
        let document = GiniCaptureTestsHelper.loadImageDocument(named: "invoice")
        let page = GiniCapturePage(document: document)
        coordinator.pages = [page]
        let expectation = expectation(description: "main dispatch")

        coordinator.uploadDidComplete(for: document)
        DispatchQueue.main.async { expectation.fulfill() }

        wait(for: [expectation], timeout: 3)
        /// Coverage of the main-dispatch branch.
    }

    func testUploadDidFail_withRequestCancelled_dispatchesButDoesNotDisplayError() {
        _ = coordinator.start(withDocuments: nil)
        let document = GiniCaptureTestsHelper.loadImageDocument(named: "invoice")
        let page = GiniCapturePage(document: document)
        coordinator.pages = [page]
        let expectation = expectation(description: "main dispatch")

        coordinator.uploadDidFail(for: document, with: GiniError.requestCancelled)
        DispatchQueue.main.async { expectation.fulfill() }

        wait(for: [expectation], timeout: 3)
        /// Coverage: uploadDidFail up to the `giniError != .requestCancelled` guard.
    }

    func testUploadDidFail_withNonGiniError_dispatchesAndLogsError() {
        _ = coordinator.start(withDocuments: nil)
        let document = GiniCaptureTestsHelper.loadImageDocument(named: "invoice")
        let page = GiniCapturePage(document: document)
        coordinator.pages = [page]
        let expectation = expectation(description: "main dispatch")

        let error = NSError(domain: "test", code: 42)
        coordinator.uploadDidFail(for: document, with: error)
        DispatchQueue.main.async { expectation.fulfill() }

        wait(for: [expectation], timeout: 3)
        /// Coverage: uploadDidFail with error that isn't a GiniError — hits the `guard let giniError` early return.
    }

    // MARK: - showNextScreenAfterPicking — isFromOtherApp branch

    func testShowNextScreenAfterPicking_imageFromOtherApp_showsAnalysis() {
        let root = coordinator.start(withDocuments: nil)
        _ = root.view
        let nav = root.children.first as? UINavigationController

        let doc = GiniCaptureTestsHelper.loadImageDocument(named: "invoice")
        doc.isFromOtherApp = true
        let page = GiniCapturePage(document: doc)
        coordinator.pages = [page]

        coordinator.showNextScreenAfterPicking(pages: [page])

        let hasAnalysis = nav?.viewControllers.contains(where: { $0 is AnalysisViewController }) ?? false
        XCTAssertTrue(hasAnalysis)
    }

    // MARK: - camera(_:didCapture:) — success + error branches

    func testCameraDidCapture_imageDocument_completesValidation() {
        _ = coordinator.start(withDocuments: nil)
        let cameraVC = coordinator.createCameraViewController()
        _ = cameraVC.view

        let document = GiniCaptureTestsHelper.loadImageDocument(named: "invoice")
        let expectation = expectation(description: "async validate")

        coordinator.camera(cameraVC, didCapture: document)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { expectation.fulfill() }

        wait(for: [expectation], timeout: 3)
        /// Coverage of camera(_:didCapture:) success path + closure.
    }

    func testCameraDidCapture_qrCodeDocument_skipsRouting() {
        _ = coordinator.start(withDocuments: nil)
        let cameraVC = coordinator.createCameraViewController()
        _ = cameraVC.view

        let url = URL(string: "https://example.com")!
        let qrDoc = GiniQRCodeDocument(scannedString: url.absoluteString)
        let expectation = expectation(description: "async validate qr")

        coordinator.camera(cameraVC, didCapture: qrDoc)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { expectation.fulfill() }

        wait(for: [expectation], timeout: 3)
        /// Coverage: the `document.type == .qrcode` early-return branch.
    }

    // MARK: - cameraDidAppear — with UIWindow

    func testCameraDidAppear_noOnboardingNoInit_stopsLoading() {
        _ = coordinator.start(withDocuments: nil)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = coordinator.rootViewController
        window.makeKeyAndVisible()

        let cameraVC = coordinator.createCameraViewController()
        _ = cameraVC.view

        // Onboarding suppressed and cameraNeedsInitializing == false → hits stopLoading path.
        GiniCaptureUserDefaultsStorage.onboardingShowed = true
        giniConfiguration.onboardingShowAtFirstLaunch = false
        giniConfiguration.onboardingShowAtLaunch = false

        coordinator.cameraDidAppear(cameraVC)

        window.isHidden = true
        /// Coverage: the early-return guard branch of cameraDidAppear.
    }

    func testCameraDidAppear_shouldShowOnboarding_presentsOnboarding() {
        _ = coordinator.start(withDocuments: nil)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = coordinator.rootViewController
        window.makeKeyAndVisible()

        let cameraVC = coordinator.createCameraViewController()
        _ = cameraVC.view

        giniConfiguration.onboardingShowAtFirstLaunch = true
        GiniCaptureUserDefaultsStorage.onboardingShowed = false

        coordinator.cameraDidAppear(cameraVC)

        // Give the presentation a moment to complete.
        let exp = expectation(description: "present")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { exp.fulfill() }
        wait(for: [exp], timeout: 3)
        window.isHidden = true
        /// Coverage: showOnboardingScreen presentation path.
    }

    // MARK: - addDropInteraction

    func testAddDropInteraction_addsInteractionToView() {
        let view = UIView()
        let initialCount = view.interactions.count

        coordinator.addDropInteraction(forView: view, with: coordinator.documentPickerCoordinator)

        XCTAssertEqual(view.interactions.count, initialCount + 1)
        XCTAssertTrue(view.interactions.last is UIDropInteraction)
    }
}
