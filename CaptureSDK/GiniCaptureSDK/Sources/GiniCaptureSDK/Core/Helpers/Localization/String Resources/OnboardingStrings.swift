//
//  OnboardingStrings.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 7/31/18.
//

import Foundation

public enum OnboardingStrings: LocalizableStringResource {
    
    case onboardingFirstPageText, onboardingSecondPageText, onboardingThirdPageText, onboardingFourthPageText,
    onboardingFifthPageText
    
    public var tableName: String {
        return "onboarding"
    }
    
    public var tableEntry: LocalizationEntry {
        switch self {
        case .onboardingFirstPageText:
            return ("firstPage", "Text on the first page of the onboarding screen")
        case .onboardingSecondPageText:
            return ("secondPage", "Text on the second page of the onboarding screen")
        case .onboardingThirdPageText:
            return ("thirdPage", "Text on the third page of the onboarding screen")
        case .onboardingFourthPageText:
            return ("fourthPage", "Text on the fouth page of the onboarding screen")
        case .onboardingFifthPageText:
            return ("fifthPage", "Text on the fifth page of the onboarding screen")
        }
    }
    
    public var isCustomizable: Bool {
        switch self {
        case .onboardingFirstPageText, .onboardingSecondPageText, .onboardingThirdPageText, .onboardingFourthPageText,
             .onboardingFifthPageText:
            return true
        }
    }
    
    public var fallbackTableEntry: String {
        switch self {
        default:
            return ""
        }
    }
    
}
