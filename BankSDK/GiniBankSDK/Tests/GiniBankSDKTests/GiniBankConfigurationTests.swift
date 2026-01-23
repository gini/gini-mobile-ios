//
//  GiniBankConfigurationTests.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import Testing
@testable import GiniBankSDK
@testable import GiniCaptureSDK

@Suite("GiniBankConfiguration Feature Flags")
struct GiniBankConfigurationFeatureFlagsTests {

    // MARK: - Default Flag Values

    @Test("Default flag values are correct")
    func defaultFlagValues() {
        let configuration = GiniBankConfiguration()

        #expect(!configuration.bottomNavigationBarEnabled, "Expected bottomNavigationBarEnabled to be false by default")
        #expect(!configuration.multipageEnabled, "Expected multipageEnabled to be false by default")
        #expect(!configuration.qrCodeScanningEnabled, "Expected qrCodeScanningEnabled to be false by default")
        #expect(!configuration.onlyQRCodeScanningEnabled, "Expected onlyQRCodeScanningEnabled to be false by default")
        #expect(!configuration.flashToggleEnabled, "Expected flashToggleEnabled to be false by default")
        #expect(!configuration.flashOnByDefault, "Expected flashOnByDefault to be false by default")
        #expect(!configuration.onboardingShowAtLaunch, "Expected onboardingShowAtLaunch to be false by default")
        #expect(configuration.onboardingShowAtFirstLaunch, "Expected onboardingShowAtFirstLaunch to be true by default")
        #expect(!configuration.openWithEnabled, "Expected openWithEnabled to be false by default")
        #expect(configuration.returnAssistantEnabled, "Expected returnAssistantEnabled to be true by default")
        #expect(!configuration.enableReturnReasons, "Expected enableReturnReasons to be false by default")
        #expect(configuration.skontoEnabled, "Expected skontoEnabled to be true by default")
        #expect(configuration.transactionDocsEnabled, "Expected transactionDocsEnabled to be true by default")
        #expect(configuration.alreadyPaidHintEnabled, "Expected alreadyPaidHintEnabled to be true by default")
        #expect(configuration.savePhotosLocallyEnabled, "Expected savePhotosLocallyEnabled to be true by default")
        #expect(configuration.shouldShowSupportedFormatsScreen, "Expected shouldShowSupportedFormatsScreen to be true by default")
        #expect(configuration.shouldShowDragAndDropTutorial, "Expected shouldShowDragAndDropTutorial to be true by default")
        #expect(configuration.giniErrorLoggerIsOn, "Expected giniErrorLoggerIsOn to be true by default")
        #expect(!configuration.debugModeOn, "Expected debugModeOn to be false by default")
    }

    // MARK: - Multipage Feature

    @Test("Multipage feature can be enabled and disabled")
    func multipageEnabled() {
        var configuration = GiniBankConfiguration()

        configuration.multipageEnabled = true
        #expect(configuration.multipageEnabled, "Expected multipageEnabled to be true after enabling")

        configuration.multipageEnabled = false
        #expect(!configuration.multipageEnabled, "Expected multipageEnabled to be false after disabling")
    }

    // MARK: - QR Code Scanning

    @Test("QR code scanning can be enabled and disabled")
    func qrCodeScanningEnabled() {
        var configuration = GiniBankConfiguration()
        
        configuration.qrCodeScanningEnabled = true
        #expect(configuration.qrCodeScanningEnabled, "Expected qrCodeScanningEnabled to be true after enabling")

        configuration.qrCodeScanningEnabled = false
        #expect(!configuration.qrCodeScanningEnabled, "Expected qrCodeScanningEnabled to be false after disabling")
    }

    @Test("Only QR code scanning can be enabled and disabled")
    func onlyQRCodeScanningEnabled() {
        var configuration = GiniBankConfiguration()

        configuration.onlyQRCodeScanningEnabled = true
        #expect(configuration.onlyQRCodeScanningEnabled, "Expected onlyQRCodeScanningEnabled to be true after enabling")

        configuration.onlyQRCodeScanningEnabled = false
        #expect(!configuration.onlyQRCodeScanningEnabled, "Expected onlyQRCodeScanningEnabled to be false after disabling")
    }

    @Test("Both QR code scanning flags can be enabled together")
    func qrCodeScanningFlagsBothEnabled() {
        var configuration = GiniBankConfiguration()

        configuration.qrCodeScanningEnabled = true
        configuration.onlyQRCodeScanningEnabled = true

        #expect(configuration.qrCodeScanningEnabled, "Expected qrCodeScanningEnabled to be true")
        #expect(configuration.onlyQRCodeScanningEnabled, "Expected onlyQRCodeScanningEnabled to be true")
    }

    // MARK: - Flash Toggle

    @Test("Flash toggle can be enabled and disabled")
    func flashToggleEnabled() {
        var configuration = GiniBankConfiguration()

        configuration.flashToggleEnabled = true
        #expect(configuration.flashToggleEnabled, "Expected flashToggleEnabled to be true after enabling")
        
        configuration.flashToggleEnabled = false
        #expect(!configuration.flashToggleEnabled, "Expected flashToggleEnabled to be false after disabling")
    }

    @Test("Flash on by default can be enabled and disabled")
    func flashOnByDefault() {
        var configuration = GiniBankConfiguration()

        configuration.flashOnByDefault = true
        #expect(configuration.flashOnByDefault, "Expected flashOnByDefault to be true after enabling")

        configuration.flashOnByDefault = false
        #expect(!configuration.flashOnByDefault, "Expected flashOnByDefault to be false after disabling")
    }

    // MARK: - Onboarding

    @Test("Onboarding show at launch can be enabled and disabled")
    func onboardingShowAtLaunch() {
        var configuration = GiniBankConfiguration()

        configuration.onboardingShowAtLaunch = true
        #expect(configuration.onboardingShowAtLaunch, "Expected onboardingShowAtLaunch to be true after enabling")
        
        configuration.onboardingShowAtLaunch = false
        #expect(!configuration.onboardingShowAtLaunch, "Expected onboardingShowAtLaunch to be false after disabling")
    }

    @Test("Onboarding show at first launch can be enabled and disabled")
    func onboardingShowAtFirstLaunch() {
        var configuration = GiniBankConfiguration()

        configuration.onboardingShowAtFirstLaunch = false
        #expect(!configuration.onboardingShowAtFirstLaunch, "Expected onboardingShowAtFirstLaunch to be false after disabling")

        configuration.onboardingShowAtFirstLaunch = true
        #expect(configuration.onboardingShowAtFirstLaunch, "Expected onboardingShowAtFirstLaunch to be true after enabling")
    }

    // MARK: - Open With Feature

    @Test("Open with feature can be enabled and disabled")
    func openWithEnabled() {
        var configuration = GiniBankConfiguration()
        
        configuration.openWithEnabled = true
        #expect(configuration.openWithEnabled, "Expected openWithEnabled to be true after enabling")

        configuration.openWithEnabled = false
        #expect(!configuration.openWithEnabled, "Expected openWithEnabled to be false after disabling")
    }

    // MARK: - Return Assistant

    @Test("Return assistant can be enabled and disabled")
    func returnAssistantEnabled() {
        var configuration = GiniBankConfiguration()
        
        configuration.returnAssistantEnabled = false
        #expect(!configuration.returnAssistantEnabled, "Expected returnAssistantEnabled to be false after disabling")

        configuration.returnAssistantEnabled = true
        #expect(configuration.returnAssistantEnabled, "Expected returnAssistantEnabled to be true after enabling")
    }

    @Test("Return reasons can be enabled and disabled")
    func enableReturnReasons() {
        var configuration = GiniBankConfiguration()

        configuration.enableReturnReasons = true
        #expect(configuration.enableReturnReasons, "Expected enableReturnReasons to be true after enabling")

        configuration.enableReturnReasons = false
        #expect(!configuration.enableReturnReasons, "Expected enableReturnReasons to be false after disabling")
    }

    // MARK: - Skonto Feature

    @Test("Skonto feature can be enabled and disabled")
    func skontoEnabled() {
        var configuration = GiniBankConfiguration()

        configuration.skontoEnabled = false
        #expect(!configuration.skontoEnabled, "Expected skontoEnabled to be false after disabling")
        
        configuration.skontoEnabled = true
        #expect(configuration.skontoEnabled, "Expected skontoEnabled to be true after enabling")
    }

    // MARK: - Transaction Docs

    @Test("Transaction docs can be enabled and disabled")
    func transactionDocsEnabled() {
        var configuration = GiniBankConfiguration()

        configuration.transactionDocsEnabled = false
        #expect(!configuration.transactionDocsEnabled, "Expected transactionDocsEnabled to be false after disabling")
        
        configuration.transactionDocsEnabled = true
        #expect(configuration.transactionDocsEnabled, "Expected transactionDocsEnabled to be true after enabling")
    }

    // MARK: - Payment Hints

    @Test("Payment hints can be enabled and disabled")
    func alreadyPaidHintEnabled() {
        var configuration = GiniBankConfiguration()
        
        configuration.alreadyPaidHintEnabled = false
        #expect(!configuration.alreadyPaidHintEnabled, "Expected alreadyPaidHintEnabled to be false after disabling")
        
        configuration.alreadyPaidHintEnabled = true
        #expect(configuration.alreadyPaidHintEnabled, "Expected alreadyPaidHintEnabled to be true after enabling")
    }

    // MARK: - Save Photos Locally

    @Test("Save photos locally can be enabled and disabled")
    func savePhotosLocallyEnabled() {
        var configuration = GiniBankConfiguration()
        
        configuration.savePhotosLocallyEnabled = false
        #expect(!configuration.savePhotosLocallyEnabled, "Expected savePhotosLocallyEnabled to be false after disabling")

        configuration.savePhotosLocallyEnabled = true
        #expect(configuration.savePhotosLocallyEnabled, "Expected savePhotosLocallyEnabled to be true after enabling")
    }

    // MARK: - Help Screens

    @Test("Supported formats screen visibility can be toggled")
    func shouldShowSupportedFormatsScreen() {
        var configuration = GiniBankConfiguration()

        configuration.shouldShowSupportedFormatsScreen = false
        #expect(!configuration.shouldShowSupportedFormatsScreen, "Expected shouldShowSupportedFormatsScreen to be false after disabling")

        configuration.shouldShowSupportedFormatsScreen = true
        #expect(configuration.shouldShowSupportedFormatsScreen, "Expected shouldShowSupportedFormatsScreen to be true after enabling")
    }

    @Test("Drag and drop tutorial visibility can be toggled")
    func shouldShowDragAndDropTutorial() {
        var configuration = GiniBankConfiguration()

        configuration.shouldShowDragAndDropTutorial = false
        #expect(!configuration.shouldShowDragAndDropTutorial, "Expected shouldShowDragAndDropTutorial to be false after disabling")
        
        configuration.shouldShowDragAndDropTutorial = true
        #expect(configuration.shouldShowDragAndDropTutorial, "Expected shouldShowDragAndDropTutorial to be true after enabling")
    }

    // MARK: - Error Logging

    @Test("Error logger can be enabled and disabled")
    func giniErrorLoggerIsOn() {
        var configuration = GiniBankConfiguration()

        configuration.giniErrorLoggerIsOn = false
        #expect(!configuration.giniErrorLoggerIsOn, "Expected giniErrorLoggerIsOn to be false after disabling")

        configuration.giniErrorLoggerIsOn = true
        #expect(configuration.giniErrorLoggerIsOn, "Expected giniErrorLoggerIsOn to be true after enabling")
    }

    // MARK: - Debug Mode

    @Test("Debug mode can be enabled and disabled")
    func debugModeOn() {
        var configuration = GiniBankConfiguration()

        configuration.debugModeOn = true
        #expect(configuration.debugModeOn, "Expected debugModeOn to be true after enabling")

        configuration.debugModeOn = false
        #expect(!configuration.debugModeOn, "Expected debugModeOn to be false after disabling")
    }

    // MARK: - Flag Transfer to CaptureConfiguration

    @Test("Capture configuration transfers all flags correctly")
    func captureConfigurationTransfersAllFlags() {
        var configuration = GiniBankConfiguration()

        configuration.multipageEnabled = true
        configuration.qrCodeScanningEnabled = true
        configuration.onlyQRCodeScanningEnabled = true
        configuration.flashToggleEnabled = true
        configuration.flashOnByDefault = true
        configuration.onboardingShowAtLaunch = true
        configuration.onboardingShowAtFirstLaunch = false
        configuration.openWithEnabled = true
        configuration.shouldShowSupportedFormatsScreen = false
        configuration.shouldShowDragAndDropTutorial = false
        configuration.transactionDocsEnabled = false
        configuration.giniErrorLoggerIsOn = false
        configuration.debugModeOn = true

        let config = configuration.captureConfiguration()

        #expect(config.multipageEnabled, "Expected multipageEnabled to be transferred as true")
        #expect(config.qrCodeScanningEnabled, "Expected qrCodeScanningEnabled to be transferred as true")
        #expect(config.onlyQRCodeScanningEnabled, "Expected onlyQRCodeScanningEnabled to be transferred as true")
        #expect(config.flashToggleEnabled, "Expected flashToggleEnabled to be transferred as true")
        #expect(config.flashOnByDefault, "Expected flashOnByDefault to be transferred as true")
        #expect(config.onboardingShowAtLaunch, "Expected onboardingShowAtLaunch to be transferred as true")
        #expect(!config.onboardingShowAtFirstLaunch, "Expected onboardingShowAtFirstLaunch to be transferred as false")
        #expect(config.openWithEnabled, "Expected openWithEnabled to be transferred as true")
        #expect(!config.shouldShowSupportedFormatsScreen, "Expected shouldShowSupportedFormatsScreen to be transferred as false")
        #expect(!config.shouldShowDragAndDropTutorial, "Expected shouldShowDragAndDropTutorial to be transferred as false")
        #expect(!config.transactionDocsEnabled, "Expected transactionDocsEnabled to be transferred as false")
        #expect(!config.giniErrorLoggerIsOn, "Expected giniErrorLoggerIsOn to be transferred as false")
        #expect(config.debugModeOn, "Expected debugModeOn to be transferred as true")
    }
}
