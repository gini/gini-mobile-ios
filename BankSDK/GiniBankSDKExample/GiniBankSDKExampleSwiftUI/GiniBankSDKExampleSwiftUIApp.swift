//
//  GiniBankSDKExampleSwiftUIApp.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import SwiftUI
import GiniCaptureSDK

@main
struct GiniBankSDKExampleSwiftUIApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(delegate: AppDelegate.shared, clientId: clientID)
        }
    }
}

class AppDelegate: ContentViewDelegate {
    
    static let shared = AppDelegate()
    
    func didSelectEntryPoint(_ entryPoint: GiniCaptureSDK.GiniConfiguration.GiniEntryPoint) {
        // Handle entry point selection
        print("Selected entry point: \(entryPoint)")
    }
    
    func didSelectSettings() {
        // Handle settings tap
        print("Settings tapped")
    }
    
    func didTapTransactionList() {
        // Handle transaction list tap
        print("Transaction list tapped")
    }
}
