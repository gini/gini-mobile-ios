//
//  GiniHealthSDKExampleUITests.swift
//  GiniHealthSDKExampleUITests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import XCTest

/**
 Base class for every Health SDK XCUITest suite.

 Responsibilities:
 - Launches `GiniHealthSDKExample` with a clean state.
 - Instantiates every page object (`mainScreen`, `paymentReviewScreen`, …) so
   subclass tests read as plain English instructions.
 - Seeds the host app's `Documents/` directory with the fixtures used by the
   Files-import flows (local simulator only — on BrowserStack the Custom_Files
   folder is seeded by `uploadMedia` in `bs_run_*.sh`).
 - Attaches a last-screen screenshot on every test, failing or passing, so a
   BrowserStack session with no explicit assertion failure still carries visual
   evidence of what the device saw.
 */
class GiniHealthSDKExampleUITests: XCTestCase {

    var app: XCUIApplication!
    var mainScreen: MainScreen!
    var paymentReviewScreen: PaymentReviewScreen!
    var bankSelectionBottomSheet: BankSelectionBottomSheet!
    var captureImportFlow: CaptureImportFlow!
    var invoicesListScreen: InvoicesListScreen!
    var ordersListScreen: OrdersListScreen!
    var orderDetailsScreen: OrderDetailsScreen!
    var paymentComponentScreen: PaymentComponentScreen!
    var paymentInfoScreen: PaymentInfoScreen!

    override func setUpWithError() throws {
        /// Tests that need BrowserStack-staged media (Photos gallery, Custom_Files)
        /// skip inside their own method via `XCTSkip` — see HEAL-282. Tests that
        /// enter through the `invoicesList` or `startWithTestDocument` buttons
        /// (HEAL-285, HEAL-286, …) run on both simulator and device because the
        /// host app seeds the Invoices List itself via `HardcodedInvoicesController`.
        continueAfterFailure = false
        copyFixturesToSimulator()
        app = XCUIApplication()
        app.resetAuthorizationStatus(for: .camera)
        app.resetAuthorizationStatus(for: .photos)
        app.launchArguments = ["-StartFromCleanState", "YES"]
        app.launch()
        let locale = Locale.current.language.languageCode?.identifier ?? "en"
        mainScreen = MainScreen(app: app)
        paymentReviewScreen = PaymentReviewScreen(app: app)
        bankSelectionBottomSheet = BankSelectionBottomSheet(app: app)
        captureImportFlow = CaptureImportFlow(app: app, locale: locale)
        invoicesListScreen = InvoicesListScreen(app: app)
        ordersListScreen = OrdersListScreen(app: app)
        orderDetailsScreen = OrderDetailsScreen(app: app)
        paymentComponentScreen = PaymentComponentScreen(app: app)
        paymentInfoScreen = PaymentInfoScreen(app: app)
    }

    override func tearDownWithError() throws {
        #if !targetEnvironment(simulator)
            let screenshot = XCUIScreen.main.screenshot()
            let attachment = XCTAttachment(screenshot: screenshot)
            attachment.lifetime = .deleteOnSuccess
            add(attachment)
            app.terminate()
        #endif
    }

    // MARK: - Fixture seeding

    /**
     Copies every PDF in `TestSamples/TestSamplesForBS/` into the running app's
     `Documents/` directory so the Files picker lists them under
     "On My iPhone → GiniHealthSDKExample".

     The test runner lives in a sibling container to the app, so we walk one level
     up from `NSHomeDirectory()` and identify the app's container by its
     `MCMMetadataIdentifier` plist entry. BrowserStack serves the same fixtures
     via `uploadMedia` → Custom_Files, so on BS this becomes a no-op (the PDFs
     reside in the OS-provided Custom_Files folder, not the app's Documents).
     */
    private func copyFixturesToSimulator() {
        let fileManager = FileManager.default
        let applicationDir = URL(fileURLWithPath: NSHomeDirectory())
            .deletingLastPathComponent().path
        guard let appFolders = try? fileManager.contentsOfDirectory(atPath: applicationDir) else { return }
        let fixturesURL = URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .appendingPathComponent("TestSamples/TestSamplesForBS")
        let pdfs = ((try? fileManager.contentsOfDirectory(at: fixturesURL,
                                                          includingPropertiesForKeys: nil,
                                                          options: .skipsHiddenFiles)) ?? [])
            .filter { $0.pathExtension == "pdf" }
        guard !pdfs.isEmpty else { return }
        for folder in appFolders {
            let metaPath = "\(applicationDir)/\(folder)/.com.apple.mobile_container_manager.metadata.plist"
            guard let metadata = NSDictionary(contentsOfFile: metaPath),
                  let bundleID = metadata["MCMMetadataIdentifier"] as? String,
                  bundleID == "net.gini.healthsdk.example" else { continue }
            let docsURL = URL(fileURLWithPath: "\(applicationDir)/\(folder)/Documents")
            try? fileManager.createDirectory(at: docsURL, withIntermediateDirectories: true)
            for pdf in pdfs {
                let dest = docsURL.appendingPathComponent(pdf.lastPathComponent)
                try? fileManager.copyItem(at: pdf, to: dest)
            }
            return
        }
    }
}

// MARK: - XCUIElement helpers

extension XCUIElement {
    /**
     Complement to `waitForExistence(timeout:)` — returns `true` if the element disappears in time.
     */
    func waitForNonExistence(timeout: TimeInterval) -> Bool {
        let gonePredicate = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: gonePredicate, object: self)
        return XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
    }
}

// MARK: - Shared payment-flow helpers

extension GiniHealthSDKExampleUITests {

    /**
     Drives the modal Payment Component sheet all the way to the Payment
     Review Screen when it appears: taps Select-bank, picks any available bank,
     then taps Continue to overview (with the coordinate-tap fallback for the
     iOS 26 safe-area quirk).

     Two post-TransferDirectly paths exist:
     1. **Payment Component sheet** — first-time flow with no bank selected.
        Drive Select-bank → bank cell → Continue to overview.
     2. **Direct to Payment Review Screen** — a bank was previously selected
        (persisted across launches in the same runner session, or auto-chosen
        by extraction) and the Payment Component intermediate is skipped.

     Both paths are raced for up to ~60 s. If the Payment Review Screen opened
     directly, this returns immediately with nothing to drive; the caller still
     runs `assertPaymentReviewReachedWithPopulatedFields` to verify fields.
     */
    func drivePaymentFlowThroughBankSelectionToPaymentReview() {
        let selectBank = paymentComponentScreen.selectBankButton
        let ibanField = paymentReviewScreen.ibanField
        let deadline = Date().addingTimeInterval(60)
        while Date() < deadline {
            if ibanField.exists { return }
            if selectBank.exists { break }
            Thread.sleep(forTimeInterval: 0.5)
        }
        XCTAssertTrue(selectBank.exists,
                      "Neither Payment Component bottom sheet nor Payment Review Screen appeared after Transfer directly.")
        selectBank.tap()
        let bankCell = bankSelectionBottomSheet.anyBankCell
        XCTAssertTrue(bankCell.waitForExistence(timeout: 10),
                      "No bank cells found in the Bank Selection sheet — Select-bank tap may not have opened the sheet, or client config returned no payment providers.")
        bankCell.tap()
        XCTAssertTrue(paymentComponentScreen.continueToOverviewButton.waitForExistence(timeout: 10),
                      "Continue to overview button did not appear on the Payment Component after bank selection.")
        paymentComponentScreen.tapContinueToOverview()
    }

    /**
     Asserts the Payment Review Screen reached, all four payment fields
     (IBAN, Recipient, Amount, Reference) carry non-empty extracted
     values, and the Pay button is reachable (handoff setup is complete).

     Each field value is **polled** rather than read once because the SwiftUI
     `TextField`s render immediately with their binding target
     (`viewModel.<field>InputState.text`) still empty — the viewModel's async
     load happens shortly after. 15 s per field is well over the typical load
     (<2 s) and still fails fast if the extraction model never arrived.
     */
    func assertPaymentReviewReachedWithPopulatedFields() {
        XCTAssertTrue(paymentReviewScreen.ibanField.waitForExistence(timeout: 30),
                      "Payment Review Screen did not appear after Continue to overview.")
        for field in [paymentReviewScreen.ibanField,
                      paymentReviewScreen.recipientField,
                      paymentReviewScreen.amountField,
                      paymentReviewScreen.referenceField] {
            let deadline = Date().addingTimeInterval(15)
            while Date() < deadline, paymentReviewScreen.value(of: field).isEmpty {
                Thread.sleep(forTimeInterval: 0.3)
            }
            XCTAssertFalse(paymentReviewScreen.value(of: field).isEmpty,
                           "Payment Review field \(field.identifier) still empty 15 s after screen appeared — extraction model may not have arrived.")
        }
        XCTAssertTrue(paymentReviewScreen.payButton.waitForExistence(timeout: 10),
                      "Pay button not reachable after bank selection — handoff setup incomplete.")
    }

    /**
     Convenience entry for screen tests: taps Invoices List on the main
     screen, seeds the hardcoded invoices if the list is empty, taps the
     first "Transfer directly" button, and drives through to the Payment
     Review Screen using the adaptive helper.

     On return, the Payment Review Screen is reached (ibanField exists) but
     field values may still be settling — callers should poll via
     `paymentReviewScreen.value(of:)` or call
     `assertPaymentReviewReachedWithPopulatedFields` if they also need the
     fields verified.
     */
    func reachPaymentReviewFromInvoicesList() {
        XCTAssertTrue(mainScreen.invoicesListButton.waitForExistence(timeout: 10),
                      "Main screen did not render — host app launch failed.")
        mainScreen.invoicesListButton.tap()
        invoicesListScreen.seedIfEmpty()
        invoicesListScreen.transferDirectlyButton.tap()
        drivePaymentFlowThroughBankSelectionToPaymentReview()
    }
}
