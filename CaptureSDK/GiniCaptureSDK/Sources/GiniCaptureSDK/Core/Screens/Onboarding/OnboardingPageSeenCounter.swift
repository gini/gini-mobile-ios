//
//  OnboardingPageSeenCounter.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

class OnboardingPageSeenCounter {
    private var pages: [OnboardingPageModel]

    init(pages: [OnboardingPageModel]) {
        self.pages = pages
    }

    func pageNotSeen(_ page: OnboardingPageModel) -> Bool {
        let initialPages = pages
        return initialPages.contains(page)
    }

    func markPageAsSeen(_ page: OnboardingPageModel) {
        pages = pages.filter { $0 != page }
    }

    var seenAllPages: Bool {
        return pages.isEmpty
    }
}
