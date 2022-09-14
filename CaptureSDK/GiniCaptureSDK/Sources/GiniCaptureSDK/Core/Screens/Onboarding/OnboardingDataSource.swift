//
//  OnboardingPagesDataSource.swift
//  
//
//  Created by Nadya Karaban on 14.09.22.
//

import Foundation
import UIKit
protocol BaseTableViewDataSource: UITableViewDelegate, UITableViewDataSource {
    init(
        configuration: GiniConfiguration
    )
}

protocol BaseCollectionViewDataSource: UICollectionViewDelegate, UICollectionViewDataSource {
    init(
        configuration: GiniConfiguration
    )
}

class OnboardingDataSource: NSObject, BaseCollectionViewDataSource {
    var items: [OnboardingPageNew] = []
    let giniConfiguration: GiniConfiguration
    required init(configuration: GiniConfiguration) {
        giniConfiguration = configuration
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        itemSections.count
    }
    private func configureCell(cell: OnboardingPageCell, indexPath: IndexPath) {
        let item = itemSections[indexPath.row]
        let image = UIImageNamedPreferred(named: item.imageName)
        cell.iconView.icon = image
        cell.fullText.text = item.description
        cell.title.text = item.title
    }
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingPageCell.identifier,
                                                         for: indexPath) as? OnboardingPageCell {
            configureCell(cell: cell, indexPath: indexPath)
            return cell
        }
        fatalError("OnboardingPageCell wasn't initialized")
    }
    lazy var itemSections: [OnboardingPageNew] = {
        var sections: [OnboardingPageNew] =  [
            OnboardingPageNew(imageName: "onboardingPage1", title: NSLocalizedStringPreferredFormat(
                    "ginicapture.onboarding.firstPage",
                    comment: "supported format for section 1 title"), description: NSLocalizedStringPreferredFormat(
                    "ginicapture.help.supportedFormats.section.1.title",
                    comment: "supported format for section 1 title")),
            OnboardingPageNew(imageName: "onboardingPage2", title: NSLocalizedStringPreferredFormat(
                    "ginicapture.onboarding.secondPage",
                    comment: "supported format for section 1 title"), description: NSLocalizedStringPreferredFormat(
                    "ginicapture.help.supportedFormats.section.1.title",
                    comment: "supported format for section 1 title"))
        ]
        if giniConfiguration.multipageEnabled {
                sections.append(
                    OnboardingPageNew(imageName: "onboardingPage3", title: NSLocalizedStringPreferredFormat(
                            "ginicapture.onboarding.thirdPage",
                            comment: "supported format for section 1 title"),
                                      description: NSLocalizedStringPreferredFormat(
                            "ginicapture.help.supportedFormats.section.1.title",
                            comment: "supported format for section 1 title")))
        }
        if giniConfiguration.qrCodeScanningEnabled {
            sections.append(
                OnboardingPageNew(imageName: "onboardingPage4", title: NSLocalizedStringPreferredFormat(
                        "ginicapture.onboarding.thirdPage",
                        comment: "supported format for section 1 title"), description: NSLocalizedStringPreferredFormat(
                        "ginicapture.help.supportedFormats.section.1.title",
                        comment: "supported format for section 1 title")))
    }
        return sections
    }()
}
