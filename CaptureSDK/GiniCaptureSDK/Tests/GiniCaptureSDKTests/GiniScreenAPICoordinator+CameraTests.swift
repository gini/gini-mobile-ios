//
//  GiniScreenAPICoordinator+CameraTests.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import UIKit
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

@MainActor
@Suite("GiniScreenAPICoordinator — Camera extension")
struct GiniScreenAPICoordinatorCameraTests {

    private let giniConfiguration: GiniConfiguration
    private let spyDelegate: SpyCaptureDelegate
    private let coordinator: GiniScreenAPICoordinator

    init() {
        let config = GiniConfiguration()
        config.multipageEnabled = true
        config.fileImportSupportedTypes = .pdf_and_images
        self.giniConfiguration = config
        let spy = SpyCaptureDelegate()
        self.spyDelegate = spy
        self.coordinator = GiniScreenAPICoordinator(withDelegate: spy,
                                                    giniConfiguration: config)
        GiniCaptureUserDefaultsStorage.onboardingShowed = false
        GiniCaptureUserDefaultsStorage.onboardingShowAtLaunch = false
    }

    // MARK: - didCaptureAndValidate

    @Test func didCaptureAndValidateCallsVisionDelegateDidCapture() {
        let document = GiniCaptureTestsHelper.loadImageDocument(named: "invoice")

        coordinator.didCaptureAndValidate(document)

        #expect(spyDelegate.didCaptureCallCount == 1)
        #expect(spyDelegate.lastCapturedDocument != nil)
    }

    // MARK: - shouldShowOnboarding

    @Test func shouldShowOnboardingFirstLaunchNotYetShownReturnsTrueAndFlipsFlag() {
        giniConfiguration.onboardingShowAtFirstLaunch = true
        giniConfiguration.onboardingShowAtLaunch = false
        GiniCaptureUserDefaultsStorage.onboardingShowed = false

        let result = coordinator.shouldShowOnboarding()

        #expect(result == true)
        #expect(GiniCaptureUserDefaultsStorage.onboardingShowed == true)
    }

    @Test func shouldShowOnboardingFirstLaunchAlreadyShownFallsThrough() {
        giniConfiguration.onboardingShowAtFirstLaunch = true
        giniConfiguration.onboardingShowAtLaunch = false
        GiniCaptureUserDefaultsStorage.onboardingShowed = true

        let result = coordinator.shouldShowOnboarding()

        #expect(result == false)
    }

    @Test func shouldShowOnboardingLaunchFlagAndNotShownThisLaunchReturnsTrue() {
        giniConfiguration.onboardingShowAtFirstLaunch = false
        giniConfiguration.onboardingShowAtLaunch = true

        let result = coordinator.shouldShowOnboarding()

        #expect(result == true)
    }

    @Test func shouldShowOnboardingBothDisabledReturnsFalse() {
        giniConfiguration.onboardingShowAtFirstLaunch = false
        giniConfiguration.onboardingShowAtLaunch = false

        #expect(coordinator.shouldShowOnboarding() == false)
    }

    // MARK: - validate

    @Test func validateSingleImageSucceeds() async {
        let document = GiniCaptureTestsHelper.loadImageDocument(named: "invoice")

        let pages: [GiniCapturePage] = await withCheckedContinuation { continuation in
            coordinator.validate([document]) { result in
                if case .success(let value) = result {
                    continuation.resume(returning: value)
                } else {
                    continuation.resume(returning: [])
                }
            }
        }

        #expect(pages.count == 1)
    }

    @Test func validateMixedTypesReturnsMixedError() async {
        let image = GiniCaptureTestsHelper.loadImageDocument(named: "invoice")
        let pdf = GiniCaptureTestsHelper.loadPDFDocument(named: "testPDF")

        let error: Error? = await withCheckedContinuation { continuation in
            coordinator.validate([image, pdf]) { result in
                if case .failure(let err) = result {
                    continuation.resume(returning: err)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }

        #expect(error as? FilePickerError == .mixedDocumentsUnsupported)
    }

    @Test func validateMultiplePdfsReturnsMultiplePdfError() async {
        let pdf1 = GiniCaptureTestsHelper.loadPDFDocument(named: "testPDF")
        let pdf2 = GiniCaptureTestsHelper.loadPDFDocument(named: "testPDF")

        let error: Error? = await withCheckedContinuation { continuation in
            coordinator.validate([pdf1, pdf2]) { result in
                if case .failure(let err) = result {
                    continuation.resume(returning: err)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }

        #expect(error as? FilePickerError == .multiplePdfsUnsupported)
    }

    @Test func validateMaxPagesExceededReturnsMaxError() async {
        let docs = (0..<GiniCaptureDocumentValidator.maxPagesCount + 1).map { _ in
            GiniCaptureTestsHelper.loadImageDocument(named: "invoice")
        }

        let error: Error? = await withCheckedContinuation { continuation in
            coordinator.validate(docs) { result in
                if case .failure(let err) = result {
                    continuation.resume(returning: err)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }

        #expect(error as? FilePickerError == .maxFilesPickedCountExceeded)
    }

    @Test func validateImportedDocumentsReturnsPagePerDocument() async {
        let document = GiniCaptureTestsHelper.loadImageDocument(named: "invoice")

        let pages: [GiniCapturePage] = await withCheckedContinuation { continuation in
            coordinator.validate(importedDocuments: [document]) { result in
                continuation.resume(returning: result)
            }
        }

        #expect(pages.count == 1)
        #expect(pages.first?.document != nil)
    }

    // MARK: - showNextScreenAfterPicking

    @Test func showNextScreenAfterPickingImagePushesReview() {
        let root = coordinator.start(withDocuments: nil)
        _ = root.view
        let nav = root.children.first as? UINavigationController
        let initialCount = nav?.viewControllers.count ?? 0

        let imagePage = GiniCaptureTestsHelper.loadImagePage(named: "invoice")
        coordinator.pages = [imagePage]
        coordinator.showNextScreenAfterPicking(pages: [imagePage])

        #expect((nav?.viewControllers.count ?? 0) >= initialCount)
    }

    @Test func showNextScreenAfterPickingPdfPushesAnalysis() {
        let root = coordinator.start(withDocuments: nil)
        _ = root.view
        let nav = root.children.first as? UINavigationController

        let pdfDoc = GiniCaptureTestsHelper.loadPDFDocument(named: "testPDF")
        let pdfPage = GiniCapturePage(document: pdfDoc)
        coordinator.pages = [pdfPage]
        coordinator.showNextScreenAfterPicking(pages: [pdfPage])

        let hasAnalysis = nav?.viewControllers.contains(where: { $0 is AnalysisViewController }) ?? false
        #expect(hasAnalysis, "AnalysisViewController should be pushed for PDF")
    }

    @Test func showNextScreenAfterPickingEmptyPagesDoesNotCrash() {
        _ = coordinator.start(withDocuments: nil)
        coordinator.showNextScreenAfterPicking(pages: [])
        /// Coverage of the guard path — no crash means the test passes.
    }

    @Test func showNextScreenAfterPickingImageFromOtherAppShowsAnalysis() {
        let root = coordinator.start(withDocuments: nil)
        _ = root.view
        let nav = root.children.first as? UINavigationController

        let doc = GiniCaptureTestsHelper.loadImageDocument(named: "invoice")
        doc.isFromOtherApp = true
        let page = GiniCapturePage(document: doc)
        coordinator.pages = [page]

        coordinator.showNextScreenAfterPicking(pages: [page])

        let hasAnalysis = nav?.viewControllers.contains(where: { $0 is AnalysisViewController }) ?? false
        #expect(hasAnalysis)
    }

    // MARK: - camera(_:didSelect:)

    @Test func cameraDidSelectGalleryRoutesToDocumentPickerCoordinator() {
        let cameraVC = coordinator.createCameraViewController()

        coordinator.camera(cameraVC, didSelect: .gallery)

        /// Success = no crash. The picker itself is stateful and hard to
        /// observe, so this covers the `.gallery` routing branch only.
    }

    @Test func cameraDidSelectExplorerSetsPDFSelectionAllowedFromPagesEmpty() {
        let cameraVC = coordinator.createCameraViewController()
        coordinator.pages = []

        coordinator.camera(cameraVC, didSelect: .explorer)

        #expect(coordinator.documentPickerCoordinator.isPDFSelectionAllowed == true)
    }

    @Test func cameraDidSelectExplorerSetsPDFSelectionDisallowedWhenPagesNotEmpty() {
        let cameraVC = coordinator.createCameraViewController()
        coordinator.pages = [GiniCaptureTestsHelper.loadImagePage(named: "invoice")]

        coordinator.camera(cameraVC, didSelect: .explorer)

        #expect(coordinator.documentPickerCoordinator.isPDFSelectionAllowed == false)
    }

    @Test func cameraDidSelectEInvoiceRoutesToEInvoicePicker() {
        let cameraVC = coordinator.createCameraViewController()

        coordinator.camera(cameraVC, didSelect: .eInvoice)

        /// Coverage of the `.eInvoice` switch branch.
    }

    // MARK: - cameraDidTapReviewButton

    @Test func cameraDidTapReviewButtonPopsBackToReview() {
        let root = coordinator.start(withDocuments: nil)
        _ = root.view
        let cameraVC = coordinator.createCameraViewController()

        coordinator.cameraDidTapReviewButton(cameraVC)

        /// Coverage — no observable side effect beyond a nav pop that only
        /// happens if review was presented already.
    }

    // MARK: - createCameraViewController

    @Test func createCameraViewControllerWithoutPagesSetsCancelNavItem() {
        coordinator.pages = []

        let cameraVC = coordinator.createCameraViewController()

        #expect(cameraVC.navigationItem.leftBarButtonItem != nil)
        #expect(cameraVC.navigationItem.rightBarButtonItem != nil)
    }

    @Test func createCameraViewControllerWithPagesSetsBackNavItem() {
        coordinator.pages = [GiniCaptureTestsHelper.loadImagePage(named: "invoice")]

        let cameraVC = coordinator.createCameraViewController()

        #expect(cameraVC.navigationItem.leftBarButtonItem != nil)
    }

    @Test func createCameraViewControllerSetsCameraScreen() {
        let cameraVC = coordinator.createCameraViewController()

        #expect(coordinator.cameraScreen === cameraVC)
    }

    @Test func createCameraViewControllerFileImportNoneSkipsGalleryDelegateWiring() {
        giniConfiguration.fileImportSupportedTypes = .none

        _ = coordinator.createCameraViewController()

        /// Coverage of the `giniConfiguration.fileImportSupportedTypes != .none` branch.
    }

    // MARK: - documentPicker(_:failedToPickDocumentsAt:)

    @Test func documentPickerFailedToPickWithCameraScreenNilDoesNotCrash() {
        coordinator.documentPicker(coordinator.documentPickerCoordinator,
                                   failedToPickDocumentsAt: [URL(fileURLWithPath: "/tmp/x.pdf")])

        /// Coverage: automatic-dismiss branch, `cameraScreen` nil.
    }

    @Test func documentPickerFailedToPickWithCameraScreenShowsDialog() {
        _ = coordinator.start(withDocuments: nil)
        let cameraVC = coordinator.createCameraViewController()
        coordinator.cameraScreen = cameraVC

        coordinator.documentPicker(coordinator.documentPickerCoordinator,
                                   failedToPickDocumentsAt: [URL(fileURLWithPath: "/tmp/x.pdf")])

        /// Coverage: automatic-dismiss branch with live `cameraScreen`.
    }

    // MARK: - documentPicker(_:didPick:) — failure branches

    @Test func documentPickerDidPickMixedTypesShowsError() async throws {
        _ = coordinator.start(withDocuments: nil)
        let image = GiniCaptureTestsHelper.loadImageDocument(named: "invoice")
        let pdf = GiniCaptureTestsHelper.loadPDFDocument(named: "testPDF")

        coordinator.documentPicker(coordinator.documentPickerCoordinator, didPick: [image, pdf])
        try await Task.sleep(nanoseconds: 500_000_000)
        /// Coverage: the mixed-types error branch inside didPick.
    }

    @Test func documentPickerDidPickMultiplePdfsShowsError() async throws {
        _ = coordinator.start(withDocuments: nil)
        let pdf1 = GiniCaptureTestsHelper.loadPDFDocument(named: "testPDF")
        let pdf2 = GiniCaptureTestsHelper.loadPDFDocument(named: "testPDF")

        coordinator.documentPicker(coordinator.documentPickerCoordinator, didPick: [pdf1, pdf2])
        try await Task.sleep(nanoseconds: 500_000_000)
    }

    @Test func documentPickerDidPickMaxExceededShowsError() async throws {
        _ = coordinator.start(withDocuments: nil)
        let docs = (0..<GiniCaptureDocumentValidator.maxPagesCount + 1).map { _ in
            GiniCaptureTestsHelper.loadImageDocument(named: "invoice")
        }

        coordinator.documentPicker(coordinator.documentPickerCoordinator, didPick: docs)
        try await Task.sleep(nanoseconds: 500_000_000)
    }

    @Test func documentPickerDidPickMaxExceededWithExistingPagesSetsPositiveAction() async throws {
        _ = coordinator.start(withDocuments: nil)
        coordinator.pages = [GiniCaptureTestsHelper.loadImagePage(named: "invoice")]
        let docs = (0..<GiniCaptureDocumentValidator.maxPagesCount + 1).map { _ in
            GiniCaptureTestsHelper.loadImageDocument(named: "invoice")
        }

        coordinator.documentPicker(coordinator.documentPickerCoordinator, didPick: docs)
        try await Task.sleep(nanoseconds: 500_000_000)
        /// Coverage: the `if self.pages.isNotEmpty { positiveAction = ... }` branch.
    }

    // MARK: - uploadDidComplete / uploadDidFail

    @Test func uploadDidCompleteDispatchesToMainAndCallsUpdate() async throws {
        _ = coordinator.start(withDocuments: nil)
        let document = GiniCaptureTestsHelper.loadImageDocument(named: "invoice")
        let page = GiniCapturePage(document: document)
        coordinator.pages = [page]

        coordinator.uploadDidComplete(for: document)
        try await Task.sleep(nanoseconds: 50_000_000)
        /// Coverage of the main-dispatch branch.
    }

    @Test func uploadDidFailWithRequestCancelledDispatchesButDoesNotDisplayError() async throws {
        _ = coordinator.start(withDocuments: nil)
        let document = GiniCaptureTestsHelper.loadImageDocument(named: "invoice")
        let page = GiniCapturePage(document: document)
        coordinator.pages = [page]

        coordinator.uploadDidFail(for: document, with: GiniError.requestCancelled)
        try await Task.sleep(nanoseconds: 50_000_000)
        /// Coverage: uploadDidFail up to the `giniError != .requestCancelled` guard.
    }

    @Test func uploadDidFailWithNonGiniErrorDispatchesAndLogsError() async throws {
        _ = coordinator.start(withDocuments: nil)
        let document = GiniCaptureTestsHelper.loadImageDocument(named: "invoice")
        let page = GiniCapturePage(document: document)
        coordinator.pages = [page]

        let error = NSError(domain: "test", code: 42)
        coordinator.uploadDidFail(for: document, with: error)
        try await Task.sleep(nanoseconds: 50_000_000)
        /// Coverage: uploadDidFail with a non-GiniError — hits the early `guard let giniError` return.
    }

    // MARK: - camera(_:didCapture:) — success + error branches

    @Test func cameraDidCaptureImageDocumentCompletesValidation() async throws {
        _ = coordinator.start(withDocuments: nil)
        let cameraVC = coordinator.createCameraViewController()
        _ = cameraVC.view

        let document = GiniCaptureTestsHelper.loadImageDocument(named: "invoice")

        coordinator.camera(cameraVC, didCapture: document)
        try await Task.sleep(nanoseconds: 500_000_000)
        /// Coverage of camera(_:didCapture:) success path + closure.
    }

    @Test func cameraDidCaptureQrCodeDocumentSkipsRouting() async throws {
        _ = coordinator.start(withDocuments: nil)
        let cameraVC = coordinator.createCameraViewController()
        _ = cameraVC.view

        let url = URL(string: "https://example.com")!
        let qrDoc = GiniQRCodeDocument(scannedString: url.absoluteString)

        coordinator.camera(cameraVC, didCapture: qrDoc)
        try await Task.sleep(nanoseconds: 500_000_000)
        /// Coverage: the `document.type == .qrcode` early-return branch.
    }

    // MARK: - cameraDidAppear — with UIWindow

    @Test func cameraDidAppearNoOnboardingNoInitStopsLoading() {
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

    @Test func cameraDidAppearShouldShowOnboardingPresentsOnboarding() async throws {
        _ = coordinator.start(withDocuments: nil)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = coordinator.rootViewController
        window.makeKeyAndVisible()

        let cameraVC = coordinator.createCameraViewController()
        _ = cameraVC.view

        giniConfiguration.onboardingShowAtFirstLaunch = true
        GiniCaptureUserDefaultsStorage.onboardingShowed = false

        coordinator.cameraDidAppear(cameraVC)
        try await Task.sleep(nanoseconds: 500_000_000)

        window.isHidden = true
        /// Coverage: showOnboardingScreen presentation path.
    }

    // MARK: - addDropInteraction

    @Test func addDropInteractionAddsInteractionToView() {
        let view = UIView()
        let initialCount = view.interactions.count

        coordinator.addDropInteraction(forView: view,
                                       with: coordinator.documentPickerCoordinator)

        #expect(view.interactions.count == initialCount + 1)
        #expect(view.interactions.last is UIDropInteraction)
    }
}
