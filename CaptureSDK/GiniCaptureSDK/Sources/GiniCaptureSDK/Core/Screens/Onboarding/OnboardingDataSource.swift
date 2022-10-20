//
//  OnboardingPagesDataSource.swift
//  
//
//  Created by Nadya Karaban on 14.09.22.
//

import Foundation
import UIKit

protocol BaseCollectionViewDataSource: UICollectionViewDelegate,
    UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    init(
        configuration: GiniConfiguration
    )
}

protocol OnboardingScreen: AnyObject {
    func didScroll(page: Int)
}

class OnboardingDataSource: NSObject, BaseCollectionViewDataSource {
    private enum OnboadingPageType: Int {
        case alignCorners = 0
        case lightning = 1
        case multipage = 2
        case qrcode = 3
    }
    private var adapters: [OnboadingPageType: OnboardingIllustrationAdapter?] = [:]
    private let giniConfiguration: GiniConfiguration
    weak var delegate: OnboardingScreen?

    lazy var itemSections: [OnboardingPageNew] = {
        if let customPages = giniConfiguration.customOnboardingPages {
            return customPages
        } else {
            var sections: [OnboardingPageNew] =
            [
                OnboardingPageNew(imageName: "onboardingFlatPaper", title: NSLocalizedStringPreferredFormat(
                    "ginicapture.onboarding.flatPaper.title",
                    comment: "onboarding flat paper title"), description: NSLocalizedStringPreferredFormat(
                        "ginicapture.onboarding.flatPaper.description",
                        comment: "onboarding flat paper description")),
                OnboardingPageNew(imageName: "onboardingGoodLightning", title: NSLocalizedStringPreferredFormat(
                    "ginicapture.onboarding.goodLightning.title",
                    comment: "onboarding good lightning title"), description: NSLocalizedStringPreferredFormat(
                        "ginicapture.onboarding.goodLightning.description",
                        comment: "onboarding good lightning description"))
            ]
            if giniConfiguration.multipageEnabled {
                sections.append(
                    OnboardingPageNew(imageName: "onboardingMultiPages", title: NSLocalizedStringPreferredFormat(
                        "ginicapture.onboarding.multiPages.title",
                        comment: "onboarding multi pages title"),
                                      description: NSLocalizedStringPreferredFormat(
                                        "ginicapture.onboarding.multiPages.description",
                                        comment: "onboarding multi pages description")))
            } else {
                adapters[.multipage] = nil
            }
            if giniConfiguration.qrCodeScanningEnabled {
                sections.append(
                    OnboardingPageNew(imageName: "onboardingQRCode", title: NSLocalizedStringPreferredFormat(
                        "ginicapture.onboarding.qrCode.title",
                        comment: "onboarding qrcode title"), description: NSLocalizedStringPreferredFormat(
                            "ginicapture.onboarding.qrCode.description",
                            comment: "onboarding qrcode description")))
            } else {
                adapters[.qrcode] = nil
            }
            return sections
        }
    }()

    required init(configuration: GiniConfiguration) {
        giniConfiguration = configuration

        adapters = [
            .alignCorners: giniConfiguration.onboardingAlignCornersIllustrationAdapter,
            .lightning: giniConfiguration.onboardingLightingIllustrationAdapter,
            .multipage: giniConfiguration.onboardingMultiPageIllustrationAdapter,
            .qrcode: giniConfiguration.onboardingQRCodeIllustrationAdapter
        ]
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        itemSections.count
    }

    private func configureCell(cell: OnboardingPageCell, indexPath: IndexPath) {
        let item = itemSections[indexPath.row]
        let image = UIImageNamedPreferred(named: item.imageName)
        guard let onboardingPageType = OnboadingPageType.init(rawValue: indexPath.row) else {
            return
        }
        if let adapter = adapters[onboardingPageType], adapter != nil {
            cell.iconView.illustrationAdapter = adapter
        } else {
            cell.iconView.illustrationAdapter = ImageOnboardingIllustrationAdapter()
            cell.iconView.icon = image
        }
        cell.iconView.setupView()

        cell.fullText.text = item.description
        cell.title.text = item.title
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: OnboardingPageCell.reuseIdentifier,
            for: indexPath) as? OnboardingPageCell {
            configureCell(cell: cell, indexPath: indexPath)
            return cell
        }
        fatalError("OnboardingPageCell wasn't initialized")
    }

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath) {
        if let onboardingPageType = OnboadingPageType.init(rawValue: indexPath.row),
           let adapter = adapters[onboardingPageType] {
            adapter?.pageDidAppear()
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath) {
        if let onboardingPageType = OnboadingPageType.init(rawValue: indexPath.row),
           let adapter = adapters[onboardingPageType] {
            adapter?.pageDidDisappear()
        }
    }

    // MARK: - Display the page number in page controll of collection view Cell

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
        delegate?.didScroll(page: page)
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height
        let width = collectionView.frame.width
        return CGSize(width: width, height: height)
    }
}
