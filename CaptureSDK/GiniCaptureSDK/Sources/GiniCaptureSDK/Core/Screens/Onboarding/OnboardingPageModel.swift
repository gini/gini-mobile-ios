//
//  OnboardingPageModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

protocol OnboardingPageAnalytics {
    var analyticsScreen: String { get }
    var isCustom: Bool { get }
}

struct OnboardingPageModel: OnboardingPageAnalytics {
    let page: OnboardingPage
    let illustrationAdapter: OnboardingIllustrationAdapter?
    var analyticsScreen: String
    var isCustom: Bool

    init(page: OnboardingPage,
         illustrationAdapter: OnboardingIllustrationAdapter? = nil,
         analyticsScreen: String,
         isCustom: Bool = false) {
        self.page = page
        self.illustrationAdapter = illustrationAdapter
        self.analyticsScreen = analyticsScreen
        self.isCustom = isCustom
    }
}

extension OnboardingPageModel: Equatable {
    static func == (lhs: OnboardingPageModel, rhs: OnboardingPageModel) -> Bool {
        return lhs.page.title == rhs.page.title &&
        lhs.page.imageName == rhs.page.imageName &&
        lhs.page.description == rhs.page.description &&
        lhs.analyticsScreen == rhs.analyticsScreen &&
        lhs.isCustom == rhs.isCustom
    }
}
