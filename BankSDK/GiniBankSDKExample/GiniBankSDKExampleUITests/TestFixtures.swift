//
//  TestFixtures.swift
//  GiniBankSDKExampleUITests
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

/**
 Central registry of all document fixtures used across UI tests.

 Add new fixtures here when introducing new test invoices or images.
 Never hard-code filenames in individual test files.

 - `Files`: filenames **without** extension — imported via the system Files app.
 Place these on device: **On My iPhone → Downloads** (or any Files-accessible location).

 - `Camera`: filenames **with** `.png` extension — injected via BrowserStack camera,
 or used as the lookup key when falling back to Files import locally
 (extension is stripped automatically by `provideImageAndReachReviewScreen`).
 Place BS media in `TestSamples/TestSamplesForBS/` and upload via `bs_build_and_upload.sh`.
 */
enum TestFixtures {

    // MARK: - Files app documents (no extension)

    enum Files {

        // MARK: CX / Cross-border

        /// CX-compatible invoice with `crossBorderPayment` extractions.
        /// Used in Skonto/RA suppression, Transaction Summary, and Feature Flags tests.
        static let cxInvoice = "cx_invoice"

        /// Document that produces no `crossBorderPayment` extractions in CX mode.
        /// Used in No-Results screen tests.
        static let cxNoResultsInvoice = "cx_no_results_invoice"

        /// Multi-page CX invoice PDF.
        static let cxMultiPageInvoicePDF = "cx_invoice_multi_page"

        /// First page of a multi-page CX invoice PDF.
        static let cxMultiPageInvoicePage1 = "multi_page_invoice_CX_page1"

        /// Second page of a multi-page CX invoice.
        static let cxMultiPageInvoicePage2 = "multi_page_invoice_CX_page2"

        // MARK: SEPA

        /// Standard SEPA invoice used in SEPA regression tests.
        static let sepaInvoice = "sepa_invoice"

        /// SEPA invoice that triggers the AlreadyPaid warning.
        static let sepaAlreadyPaid = "sepa_already_paid"

        /// SEPA invoice with a future payment due date (triggers the Due Date hint).
        static let sepaDueDate = "sepa_due_date"

        // MARK: Skonto

        /// Invoice with a valid (future) Skonto discount.
        static let skontoValid = "skonto_valid"

        /// Invoice with an expired Skonto discount date.
        static let skontoPast = "skonto_past"

        // MARK: Return Assistant

        /// Invoice with line items that trigger the Return Assistant flow.
        static let returnAssistant = "return_asistant"

        // MARK: General

        /// Generic test image for review screen and transaction docs tests.
        static let testImage = "test_image"
    }

    // MARK: - Camera injection images (with .png extension)

    enum Camera {

        /// CX invoice with Swift/ACH routing details and `crossBorderPayment` extractions.
        static let cxInvoice = "Swift_AccNo_routing_DOLL.png"

        /// Standard SEPA Photopayment invoice.
        /// Produces no CX extractions in CX mode — used for No-Results flow.
        static let ppInvoice = "Photopayment_Invoice1.png"

        /// Image containing a QR code payment.
        /// Used to verify QR processing is suppressed in CX mode.
        /// Prerequisite: add `QR_Code_Payment.png` to `TestSamples/TestSamplesForBS/`.
        static let qrCodePayment = "QR_Code_Payment.png"
    }
}


