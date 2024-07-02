//
//  OnboardingShareInvoiceScreenCount.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation

struct OnboardingShareInvoiceScreenCount: Codable {
    var providerCounts: [String: Int] // Dictionary to store count for each provider
}

extension OnboardingShareInvoiceScreenCount {
    // UserDefaults key for storing onboarding presentation counts
    private static let onboardingShareScreenCountKey = "OnboardingShareInvoiceScreenCount"

    // Load onboarding presentation counts from UserDefaults
    static func load() -> OnboardingShareInvoiceScreenCount {
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
    func presentationCount(forProvider providerID: String) -> Int {
        return providerCounts[providerID] ?? 0
    }

    // Increment presentation count for a specific provider
    mutating func incrementPresentationCount(forProvider providerID: String) {
        if let count = providerCounts[providerID] {
            providerCounts[providerID] = count + 1
        } else {
            providerCounts[providerID] = 1
        }
        save() // Save updated counts to UserDefaults
    }
}
