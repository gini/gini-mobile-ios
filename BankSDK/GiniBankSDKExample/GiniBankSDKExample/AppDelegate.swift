//
//  AppDelegate.swift
//  Example Swift
//
//  Created by Nadya Karaban on 18.02.21.
//

import UIKit
import GiniBankSDK
import Firebase

@UIApplicationMain
    final class AppDelegate: UIResponder, UIApplicationDelegate {
    private let appSheme = "BankSDKExtension://"
    private let appGroupName = "group.bank.extension.test"
    private let imageUrlKey = "incomingURL"
    var coordinator: AppCoordinator!
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
#if DEBUG
        applyUITestCleanStateLaunchArguments()
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil { return true }
        // UI tests: XCTestConfigurationFilePath isn't set in the app-under-test process, so
        // reuse -StartFromCleanState to skip Firebase — committed GoogleService-Info.plist
        // has API_KEY="" and would trip FIRInstallations validateAPIKey: on launch.
        let skipFirebase = CommandLine.arguments.contains("-StartFromCleanState")
#else
        let skipFirebase = false
#endif
        if !skipFirebase { FirebaseApp.configure() }

        window = UIWindow(frame: UIScreen.main.bounds)
        coordinator = AppCoordinator(window: window ?? UIWindow())
        coordinator.start()
        return true
    }

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
    }

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
		guard GiniBankConfiguration.shared.openWithEnabled else {
			coordinator.displayOpenWithAlertView()
			return false
		}
        // Coming from Photos extension app
        if url.absoluteString == appSheme {
            if let userDefaults = UserDefaults(suiteName: appGroupName) {
                // Getting urlString for the image
                if let imageUrlString = userDefaults.value(forKey: imageUrlKey), let imageUrl = URL(string: imageUrlString as! String) {
                    coordinator.processExternalDocumentFromPhotos(withUrl: imageUrl, sourceApplication: options[.sourceApplication] as? String)
                }
            }
        } else {
            // Coming from Files share functionality
                coordinator.processExternalDocument(withUrl: url, sourceApplication: options[.sourceApplication] as? String)
        }
        return true
    }
}
