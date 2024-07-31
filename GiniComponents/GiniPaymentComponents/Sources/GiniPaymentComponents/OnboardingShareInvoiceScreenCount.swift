//
//  OnboardingShareInvoiceScreenCount.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation

public struct OnboardingShareInvoiceScreenCount: Codable {
    var providerCounts: [String: Int] // Dictionary to store count for each provider
}

extension OnboardingShareInvoiceScreenCount {
    // UserDefaults key for storing onboarding presentation counts
    private static let onboardingShareScreenCountKey = "OnboardingShareInvoiceScreenCount"

    // Load onboarding presentation counts from UserDefaults
    public static func load() -> OnboardingShareInvoiceScreenCount {
        if let data = UserDefaults.standard.data(forKey: onboardingShareScreenCountKey),
           let counts = try? JSONDecoder().decode(OnboardingShareInvoiceScreenCount.self, from: data) {
            return counts
        }
        return OnboardingShareInvoiceScreenCount(providerCounts: [:])
    }

    // Save onboarding presentation counts to UserDefaults
    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: OnboardingShareInvoiceScreenCount.onboardingShareScreenCountKey)
        }
    }

    // Get presentation count for a specific provider
    public func presentationCount(forProvider providerID: String?) -> Int {
        guard let providerID else { return 0 }
        return providerCounts[providerID] ?? 0
    }

    // Increment presentation count for a specific provider
    public mutating func incrementPresentationCount(forProvider providerID: String?) {
        guard let providerID else { return }
        if let count = providerCounts[providerID] {
            providerCounts[providerID] = count + 1
        } else {
            providerCounts[providerID] = 1
        }
        save() // Save updated counts to UserDefaults
    }
}
