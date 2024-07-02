//
//  OnboardingPageTracker.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

class OnboardingPageTracker {
    private var pages: [OnboardingPageModel]

    init(pages: [OnboardingPageModel]) {
        self.pages = pages
    }

    func isPageNotSeen(_ page: OnboardingPageModel) -> Bool {
        pages.contains(page)
    }

    func markPageAsSeen(_ page: OnboardingPageModel) {
        pages = pages.filter { $0 != page }
    }

    var seenAllPages: Bool {
        pages.isEmpty
    }
}
