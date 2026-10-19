//
//  AppDelegate.swift
//  Example Swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import UIKit
import GiniBankSDK
import GiniCaptureSDK
import Firebase

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
#if DEBUG
        applyUITestCleanStateLaunchArguments()
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil { return true }
#endif
        FirebaseApp.configure()
        return true
    }

    #if DEBUG
    /// The whole helper is UI-test scaffolding — its only caller is behind `#if DEBUG`
    /// above, and it references `UITestCustomLoadingIndicator` /
    /// `UITestDelegateObservers` which live in `UITestMockBackend.swift` (also `#if
    /// DEBUG`-only). Gating the method body ensures Release / Archive builds do not
    /// try to resolve those types.
    private func applyUITestCleanStateLaunchArguments() {
        if CommandLine.arguments.contains("-StartFromCleanState") {
            if let bundleID = Bundle.main.bundleIdentifier {
                UserDefaults.standard.removePersistentDomain(forName: bundleID)
                UserDefaults.standard.synchronize()
            }
            if let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
               let contents = try? FileManager.default.contentsOfDirectory(at: docs, includingPropertiesForKeys: nil) {
                // Preserve PDF test fixtures and the Custom_Files folder BrowserStack places at launch; wipe everything else so tests start clean.
                contents
                    .filter { $0.pathExtension.lowercased() != "pdf" && $0.lastPathComponent.lowercased() != "custom_files" }
                    .forEach { try? FileManager.default.removeItem(at: $0) }
            }
        }
        if CommandLine.arguments.contains("-ResetCaptureOnboarding") {
            UserDefaults.standard.removeObject(forKey: "ginicapture.defaults.onboardingShowed")
        }
        if CommandLine.arguments.contains("-DisableReturnAssistant") {
            GiniBankConfiguration.shared.returnAssistantEnabled = false
        }
        if let idx = CommandLine.arguments.firstIndex(of: "-paymentDueHintThresholdDaysOverride"),
           idx + 1 < CommandLine.arguments.count,
           let value = Int(CommandLine.arguments[idx + 1]) {
            GiniBankConfiguration.shared.paymentDueHintThresholdDays = value
        }
        if CommandLine.arguments.contains("-UITestMockResetEducationCount") {
            /// Mirrors `GiniCaptureUserDefaultsStorage.captureInvoiceEducationMessageDisplayCount` (internal, so hard-coded).
            UserDefaults.standard.removeObject(
                forKey: "ginicapture.defaults.captureInvoice.educationMessageDisplayCount"
            )
            /// Education flow is gated by qrCodeEducationEnabled; turn it on for the test.
            GiniCaptureUserDefaultsStorage.qrCodeEducationEnabled = true
        }
        if CommandLine.arguments.contains("-UITestInjectCustomLoadingIndicator") {
            GiniBankConfiguration.shared.customLoadingIndicator = UITestCustomLoadingIndicator()
        }
        if CommandLine.arguments.contains("-UITestInstallDelegateObservers") {
            UITestDelegateObservers.install()
        }
    }
    #endif

}
