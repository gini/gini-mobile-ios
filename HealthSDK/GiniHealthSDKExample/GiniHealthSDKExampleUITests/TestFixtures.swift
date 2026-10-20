//
//  TestFixtures.swift
//  GiniHealthSDKExampleUITests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

/**
 Central registry of document fixtures used across Health SDK UI tests.

 - `Files`: names without extension — imported via the Files app
   (On My iPhone → GiniHealthSDKExample, seeded by `copyFixturesToSimulator()`
   on the local simulator, Custom_Files on BrowserStack).
 - `Gallery`: PNG filenames staged into the Photos library on BrowserStack.
   The gallery picker selects by recency (`uploadLatestPhotoFromGallery`), so
   the constant is purely descriptive — the file name is not matched at runtime.
 */
enum TestFixtures {

    /** Files-app documents (no extension — the picker only shows base names). */
    enum Files {
        /**
         Primary health invoice PDF. Extracts a known-good
         IBAN/Recipient/Amount/Reference set — the default fixture for every
         PDF-based smoke journey.
         */
        static let medInvoice = "testMedInvoice"

        /**
         Multi-page invoice PDF used by the pagination-dots smoke check.
         */
        static let multiInvoice = "multi-invoice"
    }

    /** Gallery images staged into the Photos library. */
    enum Gallery {
        /**
         PNG rendering of `Files.medInvoice`'s first page used by the
         image-import gallery flow. Rendered via `sips` from the PDF so the
         extraction output matches the PDF variant.
         */
        static let medInvoice = "testMedInvoice.png"
    }
}
