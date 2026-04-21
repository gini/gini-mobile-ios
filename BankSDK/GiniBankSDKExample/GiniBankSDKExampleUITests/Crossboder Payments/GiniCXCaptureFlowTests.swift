//
//  GiniCXCaptureFlowTests.swift
//  GiniBankSDKExampleUITests
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import XCTest

/**
 Base class for CX and PP capture flow tests.

 Provides shared test logic reusable across local and BrowserStack runs.
 The default `provideImageAndReachReviewScreen(imageName:)` imports from the
 device Files app, making every test in this class runnable locally on a
 simulator or device without any additional tooling.

 Subclasses override `provideImageAndReachReviewScreen(imageName:)` for
 platform-specific image delivery. `GiniCaptureFlowUITestsUsingBS` overrides
 it to use BrowserStack camera injection.

 **Running locally:**
 Place the following files in the device's Files app before running:
 - `Swift_AccNo_routing_DOLL` — CX invoice with crossBorderPayment extractions
 - `Photopayment_Invoice1` — SEPA invoice (used as a "no CX results" document)
 - `QR_Code_Payment` — QR code invoice (for QR-suppression smoke test)

 **Running on BrowserStack:** Use `GiniCaptureFlowUITestsUsingBS`, which
 injects images via BrowserStack camera injection.
 */
class GiniCXCaptureFlowTests: GiniBankSDKExampleUITests {

    // MARK: - Image provision

    /**
     Provides a document image and navigates to the Review screen.

     The default implementation imports the image from the device Files app using
     `imageName` (without extension) as the file picker display name. After this
     method returns, `reviewScreen.processButton` is ready to be tapped.

     Override in subclasses for platform-specific image delivery (e.g., BS camera injection).
     - Parameters:
       - imageName: The filename including extension (e.g., `"Swift_AccNo_routing_DOLL.png"`).
     */
    func provideImageAndReachReviewScreen(imageName: String) {
        let fileName = (imageName as NSString).deletingPathExtension
        captureScreen.filesButton.tap()
        captureScreen.uploadFilesButton.tap()
        mainScreen.tapFileWithName(fileName: fileName)
        captureScreen.openGalleryButton.tap()
    }

    // MARK: - Settings helpers

    /**
     Opens Settings, selects Cross-border product tag, and switches to
     Cross border client credentials. Closes Settings on exit.
     */
    private func setupCXMode() {
        mainScreen.configurationButton.tap()
        let crossBorderButton = app.buttons["Cross-border"]
        XCTAssertTrue(crossBorderButton.waitForExistence(timeout: 5),
                      "Cross-border option should exist in Product Tag section")
        crossBorderButton.tap()

        let crossBorderClientButton = app.buttons["Cross border client"]
        XCTAssertTrue(crossBorderClientButton.waitForExistence(timeout: 5),
                      "Cross border client option should exist in Credentials Set section")
        crossBorderClientButton.tap()

        let okButton = app.alerts.buttons["OK"]
        XCTAssertTrue(okButton.waitForExistence(timeout: 5),
                      "OK button should appear after credentials change")
        okButton.tap()

        settingScreen.closeButton.tap()
    }

    /**
     Opens Settings, selects Auto-detect product tag, and switches to
     Cross border client credentials. Closes Settings on exit.
     */
    private func setupAutoDetectMode() {
        mainScreen.configurationButton.tap()
        let autoDetectButton = app.buttons["Auto-detect"]
        XCTAssertTrue(autoDetectButton.waitForExistence(timeout: 5),
                      "Auto-detect option should exist in Product Tag section")
        autoDetectButton.tap()

        let crossBorderClientButton = app.buttons["Cross border client"]
        XCTAssertTrue(crossBorderClientButton.waitForExistence(timeout: 5),
                      "Cross border client option should exist in Credentials Set section")
        crossBorderClientButton.tap()

        let okButton = app.alerts.buttons["OK"]
        XCTAssertTrue(okButton.waitForExistence(timeout: 5),
                      "OK button should appear after credentials change")
        okButton.tap()

        settingScreen.closeButton.tap()
    }

    // MARK: - PP capture flow

    func testPPCaptureFlow() throws {
        mainScreen.photoPaymentButton.tap()
        mainScreen.handleCameraPermission(answer: true)
        onboadingScreen.skipOnboardingScreens()

        provideImageAndReachReviewScreen(imageName: TestFixtures.Camera.ppInvoice)

        XCTAssertTrue(reviewScreen.processButton.waitForExistence(timeout: 15),
                      "Process button should appear in review screen")
        reviewScreen.waitForElementToBecomeEnabled(reviewScreen.processButton, timeout: 10)
        reviewScreen.processButton.tap()

        XCTAssertTrue(transactionDocsScreen.onlyForThisTransaction.waitForExistence(timeout: 5),
                      "Transaction docs option should appear")
        transactionDocsScreen.onlyForThisTransaction.tap()

        let doneButton = app.navigationBars.buttons["Done"]
        XCTAssertTrue(doneButton.waitForExistence(timeout: 10),
                      "Done button should exist on the extraction screen")

        let ibanContainer = app.otherElements.containing(.staticText, identifier: "iban").firstMatch
        XCTAssertTrue(ibanContainer.waitForExistence(timeout: 5),
                      "IBAN field container should exist on the extraction screen")
        let ibanField = ibanContainer.textFields.firstMatch
        XCTAssertTrue(ibanField.exists, "IBAN text field should exist")
        XCTAssertFalse((ibanField.value as? String)?.isEmpty ?? true,
                       "IBAN field should not be empty")

        doneButton.tap()
        XCTAssertTrue(mainScreen.photoPaymentButton.waitForExistence(timeout: 5),
                      "Should return to main screen after tapping Done")
    }

    // MARK: - CX capture flow (camera entry point)

    func testCXCaptureFlow() throws {
        setupCXMode()

        mainScreen.photoPaymentButton.tap()
        mainScreen.handleCameraPermission(answer: true)
        onboadingScreen.skipOnboardingScreens()

        provideImageAndReachReviewScreen(imageName: TestFixtures.Camera.cxInvoice)

        XCTAssertTrue(reviewScreen.processButton.waitForExistence(timeout: 15),
                      "Process button should appear in review screen")
        reviewScreen.waitForElementToBecomeEnabled(reviewScreen.processButton, timeout: 10)
        reviewScreen.processButton.tap()

        XCTAssertTrue(transactionDocsScreen.onlyForThisTransaction.waitForExistence(timeout: 5),
                      "Transaction docs option should appear")
        transactionDocsScreen.onlyForThisTransaction.tap()

        XCTAssertTrue(cxExtractionScreen.waitForExistence(timeout: 10),
                      "Done button should exist on the CX extraction screen")

        let extractionReport = cxExtractionScreen.verifyExtractionFields()
        XCTAssertFalse(extractionReport.found.isEmpty,
                       "None of the expected CX extraction fields were found on the extraction screen")

        let anyKeyFieldHasValue = cxExtractionScreen.verifyKeyFieldsHaveValues()
        XCTAssertTrue(anyKeyFieldHasValue,
                      "All key payment fields (creditorIBAN, creditorAccountNumber, creditorName, creditorAgentBIC) are empty or not found")

        cxExtractionScreen.tapDoneButton()
        XCTAssertTrue(mainScreen.photoPaymentButton.waitForExistence(timeout: 5),
                      "Should return to main screen after tapping Done")
    }

    // MARK: - CX capture flow (gallery entry point)
    //
    // This test specifically exercises the gallery upload entry point (Files → Upload photo).
    // It does not use provideImageAndReachReviewScreen so that the gallery path is tested
    // independently of the camera/injection path on all platforms.

    func testCXflowGalleryUpload() {
        setupCXMode()

        mainScreen.photoPaymentButton.tap()
        mainScreen.handleCameraPermission(answer: true)
        onboadingScreen.skipOnboardingScreens()
        captureScreen.filesButton.tap()
        captureScreen.uploadPhotoButton.tap()
        mainScreen.handlePhotoPermission(answer: true)
        uploadLatestPhotoFromGallery()

        XCTAssertTrue(reviewScreen.processButton.waitForExistence(timeout: 15))
        reviewScreen.waitForElementToBecomeEnabled(reviewScreen.processButton, timeout: 10)
        reviewScreen.processButton.tap()

        XCTAssertTrue(transactionDocsScreen.onlyForThisTransaction.waitForExistence(timeout: 5),
                      "Transaction docs option should appear")
        transactionDocsScreen.onlyForThisTransaction.tap()

        XCTAssertTrue(cxExtractionScreen.waitForExistence(timeout: 10),
                      "Done button should exist on the CX extraction screen")

        let extractionReport = cxExtractionScreen.verifyExtractionFields()
        XCTAssertFalse(extractionReport.found.isEmpty,
                       "None of the expected extraction fields were found on the extraction screen")

        let anyKeyFieldHasValue = cxExtractionScreen.verifyKeyFieldsHaveValues()
        XCTAssertTrue(anyKeyFieldHasValue,
                      "All key payment fields (creditorIBAN, creditorAccountNumber, creditorName, creditorAgentBIC) are empty or not found")

        cxExtractionScreen.tapDoneButton()
        XCTAssertTrue(mainScreen.photoPaymentButton.waitForExistence(timeout: 5),
                      "Should return to main screen after tapping Done")
    }

    // MARK: - CX Auto-detect capture flow

    func testCXAutoDetectCaptureFlow() throws {
        setupAutoDetectMode()

        mainScreen.photoPaymentButton.tap()
        mainScreen.handleCameraPermission(answer: true)
        onboadingScreen.skipOnboardingScreens()

        provideImageAndReachReviewScreen(imageName: TestFixtures.Camera.cxInvoice)

        XCTAssertTrue(reviewScreen.processButton.waitForExistence(timeout: 15),
                      "Process button should appear in review screen")
        reviewScreen.waitForElementToBecomeEnabled(reviewScreen.processButton, timeout: 10)
        reviewScreen.processButton.tap()

        XCTAssertTrue(transactionDocsScreen.onlyForThisTransaction.waitForExistence(timeout: 5),
                      "Transaction docs option should appear")
        transactionDocsScreen.onlyForThisTransaction.tap()

        XCTAssertTrue(cxExtractionScreen.waitForExistence(timeout: 10),
                      "Done button should exist on the extraction screen when Auto-detect processes a CX invoice")

        let extractionReport = cxExtractionScreen.verifyExtractionFields()
        XCTAssertFalse(extractionReport.found.isEmpty,
                       "No CX extraction fields were found — Auto-detect may not have routed to the CX flow")

        let anyKeyFieldHasValue = cxExtractionScreen.verifyKeyFieldsHaveValues()
        XCTAssertTrue(anyKeyFieldHasValue,
                      "Key CX payment fields are all empty or not found in Auto-detect mode")

        cxExtractionScreen.tapDoneButton()
        XCTAssertTrue(mainScreen.photoPaymentButton.waitForExistence(timeout: 5),
                      "Should return to main screen after tapping Done in Auto-detect CX flow")
    }

    // MARK: - CX Transaction Docs: Don't attach

    func testCXTransactionDocsDontAttach() throws {
        setupCXMode()

        mainScreen.photoPaymentButton.tap()
        mainScreen.handleCameraPermission(answer: true)
        onboadingScreen.skipOnboardingScreens()

        provideImageAndReachReviewScreen(imageName: TestFixtures.Camera.cxInvoice)

        XCTAssertTrue(reviewScreen.processButton.waitForExistence(timeout: 15),
                      "Process button should appear in review screen")
        reviewScreen.waitForElementToBecomeEnabled(reviewScreen.processButton, timeout: 10)
        reviewScreen.processButton.tap()

        XCTAssertTrue(transactionDocsScreen.dontAttach.waitForExistence(timeout: 5),
                      "Don't attach option should appear in Transaction Docs sheet")
        transactionDocsScreen.dontAttach.tap()

        XCTAssertTrue(cxExtractionScreen.waitForExistence(timeout: 10),
                      "Done button should exist on the extraction screen after choosing Don't attach")

        let extractionReport = cxExtractionScreen.verifyExtractionFields()
        XCTAssertFalse(extractionReport.found.isEmpty,
                       "No CX extraction fields found after choosing Don't attach in Transaction Docs")

        let anyKeyFieldHasValue = cxExtractionScreen.verifyKeyFieldsHaveValues()
        XCTAssertTrue(anyKeyFieldHasValue,
                      "Key CX payment fields are all empty or not found after Don't attach selection")

        cxExtractionScreen.tapDoneButton()
        XCTAssertTrue(mainScreen.photoPaymentButton.waitForExistence(timeout: 5),
                      "Should return to main screen after tapping Done")
    }

    // MARK: - C1: Skonto not shown in CX mode

    func testCXSkontoIsNotShown() throws {
        setupCXMode()

        mainScreen.photoPaymentButton.tap()
        mainScreen.handleCameraPermission(answer: true)
        onboadingScreen.skipOnboardingScreens()

        provideImageAndReachReviewScreen(imageName: TestFixtures.Camera.cxInvoice)

        XCTAssertTrue(reviewScreen.processButton.waitForExistence(timeout: 15),
                      "Process button should appear in review screen")
        reviewScreen.waitForElementToBecomeEnabled(reviewScreen.processButton, timeout: 10)
        reviewScreen.processButton.tap()

        XCTAssertTrue(transactionDocsScreen.onlyForThisTransaction.waitForExistence(timeout: 10),
                      "Transaction docs option should appear")
        transactionDocsScreen.onlyForThisTransaction.tap()

        //Skonto "Understood" button must NOT appear — Skonto is disabled for CX
        XCTAssertFalse(skontoScreen.gotItButton.waitForExistence(timeout: 5),
                       "Skonto screen should not be shown when productTag = cxExtractions.")

        XCTAssertTrue(cxExtractionScreen.waitForExistence(timeout: 15),
                      "CX extraction screen should appear — Skonto must be suppressed.")

        cxExtractionScreen.tapDoneButton()
        XCTAssertTrue(mainScreen.photoPaymentButton.waitForExistence(timeout: 5),
                      "Should return to main screen after tapping Done.")
    }

    // MARK: - C2: Return Assistant not shown in CX mode

    func testCXReturnAssistantIsNotShown() throws {
        setupCXMode()

        mainScreen.photoPaymentButton.tap()
        mainScreen.handleCameraPermission(answer: true)
        onboadingScreen.skipOnboardingScreens()

        provideImageAndReachReviewScreen(imageName: TestFixtures.Camera.cxInvoice)

        XCTAssertTrue(reviewScreen.processButton.waitForExistence(timeout: 15),
                      "Process button should appear in review screen")
        reviewScreen.waitForElementToBecomeEnabled(reviewScreen.processButton, timeout: 10)
        reviewScreen.processButton.tap()

        XCTAssertTrue(transactionDocsScreen.onlyForThisTransaction.waitForExistence(timeout: 10),
                      "Transaction docs option should appear")
        transactionDocsScreen.onlyForThisTransaction.tap()

        //Return Assistant "Get started" must NOT appear — RA is disabled for CX
        XCTAssertFalse(returnAssistantScreen.getStartedButton.waitForExistence(timeout: 5),
                       "Return Assistant screen should not be shown when productTag = cxExtractions.")

        XCTAssertTrue(cxExtractionScreen.waitForExistence(timeout: 15),
                      "CX extraction screen should appear — Return Assistant must be suppressed.")

        cxExtractionScreen.tapDoneButton()
        XCTAssertTrue(mainScreen.photoPaymentButton.waitForExistence(timeout: 5),
                      "Should return to main screen after tapping Done.")
    }

    // MARK: - E1: No-Results screen shown for a non-CX invoice
    //
    // Photopayment_Invoice1.png is a SEPA/PP invoice with no crossBorderPayment extractions.
    // In CX mode the backend returns no results, triggering the No-Results screen.

    func testCXNoResultsScreen() throws {
        setupCXMode()

        mainScreen.photoPaymentButton.tap()
        mainScreen.handleCameraPermission(answer: true)
        onboadingScreen.skipOnboardingScreens()

        provideImageAndReachReviewScreen(imageName: TestFixtures.Camera.ppInvoice)

        XCTAssertTrue(reviewScreen.processButton.waitForExistence(timeout: 15),
                      "Process button should appear in review screen")
        reviewScreen.waitForElementToBecomeEnabled(reviewScreen.processButton, timeout: 10)
        reviewScreen.processButton.tap()

        //Transaction docs may appear before no-results — tap through it if present
        if transactionDocsScreen.onlyForThisTransaction.waitForExistence(timeout: 10) {
            transactionDocsScreen.onlyForThisTransaction.tap()
        }

        XCTAssertTrue(noResultsScreen.waitForExistence(timeout: 30),
                      "No-Results screen should be shown when CX analysis returns no crossBorderPayment extractions.")

        XCTAssertFalse(transactionSummaryScreen.doneButton.exists,
                       "Transfer Summary should not appear when there are no CX extractions.")

        noResultsScreen.backToCameraButton.tap()
        XCTAssertTrue(captureScreen.captureButton.waitForExistence(timeout: 10),
                      "Camera capture screen should appear after tapping Back to camera from No-Results.")
    }

    // MARK: - E2: No-Results retry returns to camera

    func testCXNoResultsRetryAction() throws {
        setupCXMode()

        mainScreen.photoPaymentButton.tap()
        mainScreen.handleCameraPermission(answer: true)
        onboadingScreen.skipOnboardingScreens()

        provideImageAndReachReviewScreen(imageName: TestFixtures.Camera.ppInvoice)

        XCTAssertTrue(reviewScreen.processButton.waitForExistence(timeout: 15),
                      "Process button should appear in review screen")
        reviewScreen.waitForElementToBecomeEnabled(reviewScreen.processButton, timeout: 10)
        reviewScreen.processButton.tap()

        //Transaction docs may appear before no-results — tap through it if present
        if transactionDocsScreen.onlyForThisTransaction.waitForExistence(timeout: 10) {
            transactionDocsScreen.onlyForThisTransaction.tap()
        }

        XCTAssertTrue(noResultsScreen.waitForExistence(timeout: 30),
                      "No-Results screen should be shown when CX analysis returns no crossBorderPayment extractions.")

        noResultsScreen.backToCameraButton.tap()

        XCTAssertTrue(captureScreen.captureButton.waitForExistence(timeout: 10),
                      "Camera capture screen should appear after tapping Back to camera from No-Results.")
        XCTAssertTrue(captureScreen.captureButton.isHittable,
                      "Capture button should be hittable after returning from No-Results via retry.")
    }

    // MARK: - QR code not processed as payment in CX mode
    //
    // Prerequisites:
    //   Place "QR_Code_Payment" in the device Files app (local) or add
    //   "QR_Code_Payment.png" to TestSamplesForBS/ and upload it to BrowserStack
    //   with custom_id=QRCaptureInjection in bs_build_and_upload.sh.
    //
    // Verifies that a QR-code image in CX mode is treated as a regular document
    // (not a QR payment), so no SEPA IBAN pre-fill appears.

    func testCXQRCodeImageNotProcessedAsQRPayment() throws {
        setupCXMode()

        mainScreen.photoPaymentButton.tap()
        mainScreen.handleCameraPermission(answer: true)
        onboadingScreen.skipOnboardingScreens()

        provideImageAndReachReviewScreen(imageName: TestFixtures.Camera.qrCodePayment)

        XCTAssertTrue(reviewScreen.processButton.waitForExistence(timeout: 15),
                      "Process button should appear in review screen")
        reviewScreen.waitForElementToBecomeEnabled(reviewScreen.processButton, timeout: 10)
        reviewScreen.processButton.tap()

        //SEPA QR payment result (IBAN pre-fill) must NOT appear
        let ibanContainer = app.otherElements.containing(.staticText, identifier: "iban").firstMatch
        XCTAssertFalse(ibanContainer.waitForExistence(timeout: 10),
                       "QR payment IBAN container should NOT appear in CX mode — QR must not be processed as payment.")

        //Flow must end at Transaction Docs → CX extraction screen, OR at No-Results
        let reachedDocsScreen = transactionDocsScreen.onlyForThisTransaction.waitForExistence(timeout: 10)
        let reachedNoResults = noResultsScreen.waitForExistence(timeout: 5)

        XCTAssertTrue(reachedDocsScreen || reachedNoResults,
                      "CX flow should reach either Transaction Docs or No-Results — not a QR payment screen.")

        if reachedDocsScreen {
            transactionDocsScreen.onlyForThisTransaction.tap()
            XCTAssertTrue(cxExtractionScreen.waitForExistence(timeout: 10),
                          "CX extraction screen should appear after Transaction Docs in QR test.")
            cxExtractionScreen.tapDoneButton()
        }

        XCTAssertTrue(mainScreen.photoPaymentButton.waitForExistence(timeout: 10),
                      "Should return to main screen after completing CX QR flow.")
    }
}
