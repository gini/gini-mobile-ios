//
//  GiniBankConfigurationCaptureTransferTests.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation
import Testing
import UIKit
@testable import GiniBankSDK
@testable import GiniCaptureSDK

extension GiniConfigurationSharedStateSuite {

    /**
     Fills coverage gaps of `GiniBankConfiguration.captureConfiguration()` that
     `GiniBankConfigurationFeatureFlagsTests` does not exercise: product tag,
     entry point, status bar style, file import types, localization table and
     the bank-only credit-note/payment-hint flags that must stay bank-side.
     */
    @Suite("GiniBankConfiguration captureConfiguration transfer gaps")
    struct GiniBankConfigurationCaptureTransferTests {

        @Test("Capture configuration transfers the SEPA product tag")
        func transfersSepaProductTag() {
            let configuration = GiniBankConfiguration()
            configuration.productTag = .sepaExtractions

            let captureConfiguration = configuration.captureConfiguration()

            #expect(captureConfiguration.productTag == .sepaExtractions)
        }

        @Test("Capture configuration transfers the cross-border product tag")
        func transfersCrossBorderProductTag() {
            let configuration = GiniBankConfiguration()
            configuration.productTag = .cxExtractions

            let captureConfiguration = configuration.captureConfiguration()

            #expect(captureConfiguration.productTag == .cxExtractions)
        }

        @Test("Capture configuration transfers the entry point")
        func transfersEntryPoint() {
            let configuration = GiniBankConfiguration()
            configuration.entryPoint = .field

            let captureConfiguration = configuration.captureConfiguration()

            #expect(captureConfiguration.entryPoint == .field)
        }

        @Test("Capture configuration transfers the status bar style")
        func transfersStatusBarStyle() {
            let configuration = GiniBankConfiguration()
            configuration.statusBarStyle = .darkContent

            let captureConfiguration = configuration.captureConfiguration()

            #expect(captureConfiguration.statusBarStyle == .darkContent)
        }

        @Test("Capture configuration transfers the supported file import types")
        func transfersFileImportSupportedTypes() {
            let configuration = GiniBankConfiguration()
            configuration.fileImportSupportedTypes = .pdf_and_images

            let captureConfiguration = configuration.captureConfiguration()

            #expect(captureConfiguration.fileImportSupportedTypes == .pdf_and_images)
        }

        @Test("Capture configuration transfers the localized strings table name")
        func transfersLocalizedStringsTableName() {
            let configuration = GiniBankConfiguration()
            configuration.localizedStringsTableName = "CustomLocalizable"

            let captureConfiguration = configuration.captureConfiguration()

            #expect(captureConfiguration.localizedStringsTableName == "CustomLocalizable")
        }

        @Test("Capture configuration transfers the open-with app name")
        func transfersOpenWithAppNameForTexts() {
            let configuration = GiniBankConfiguration()
            configuration.openWithAppNameForTexts = "Gini Test Bank"

            let captureConfiguration = configuration.captureConfiguration()

            #expect(captureConfiguration.openWithAppNameForTexts == "Gini Test Bank")
        }

        @Test("Building the capture configuration keeps the bank-only hint flags untouched")
        func captureConfigurationKeepsBankOnlyHintFlags() {
            let configuration = GiniBankConfiguration()
            configuration.creditNoteHintEnabled = false
            configuration.alreadyPaidHintEnabled = false
            configuration.paymentDueHintEnabled = false
            configuration.paymentDueHintThresholdDays = 12

            _ = configuration.captureConfiguration()

            /// The hint flags live only on the bank configuration and must survive the transfer unchanged.
            #expect(!configuration.creditNoteHintEnabled)
            #expect(!configuration.alreadyPaidHintEnabled)
            #expect(!configuration.paymentDueHintEnabled)
            #expect(configuration.paymentDueHintThresholdDays == 12)
        }
    }
}
