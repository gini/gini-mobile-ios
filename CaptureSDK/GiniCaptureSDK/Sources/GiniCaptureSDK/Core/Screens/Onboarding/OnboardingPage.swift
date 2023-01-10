//
//  OnboardingPage.swift
//  
//
//  Created by Nadya Karaban on 15.09.22.
//

import Foundation

/**
 `OnboardingPageNew` represents the onboarding page with all it's properties.
 */

public struct OnboardingPageNew {
    let imageName: String
    let title: String
    let description: String

    /**
     *  Creates an `OnboardingPageNew` instance.
     *
     * - Parameter imageName:   a String representing the name of an image associated with the onboarding page.
     * - Parameter title:       a String representing the title of the onboarding page
     * - Parameter description: a String representing a short description of the onboarding page
     */

    public init(imageName: String, title: String, description: String) {
        self.imageName = imageName
        self.title = title
        self.description = description
    }
}
