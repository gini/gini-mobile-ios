//
//  OnboardingPagesDataSource.swift
//  
//
//  Created by Nadya Karaban on 14.09.22.
//

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

    typealias OnboardingPageModel = (page: OnboardingPage, illustrationAdapter: OnboardingIllustrationAdapter?)
    private let giniConfiguration: GiniConfiguration
    weak var delegate: OnboardingScreen?
    var currentPage = 0

    lazy var pageModels: [OnboardingPageModel] = {
        if let customPages = giniConfiguration.customOnboardingPages {
            return customPages.map { page in
                return (page: page, illustrationAdapter: nil)
            }
        } else {
            return defaultOnboardingPagesDataSource()
        }
    }()

    required init(configuration: GiniConfiguration) {
        giniConfiguration = configuration
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pageModels.count
    }

    private func configureCell(cell: OnboardingPageCell, indexPath: IndexPath) {
        let pageModel = pageModels[indexPath.row]

        if giniConfiguration.customOnboardingPages == nil {
            if let adapter = pageModel.illustrationAdapter {
                cell.iconView.illustrationAdapter = adapter
                cell.iconView.setupView()
            } else {
                cell.iconView.icon = UIImageNamedPreferred(named: pageModel.page.imageName)
            }
        } else {
            cell.iconView.icon = UIImageNamedPreferred(named: pageModel.page.imageName)
        }
        cell.iconView.accessibilityValue = pageModel.page.title

        cell.descriptionLabel.text = pageModel.page.description
        cell.descriptionLabel.accessibilityValue = pageModel.page.description
        cell.titleLabel.text = pageModel.page.title
        cell.titleLabel.accessibilityValue = pageModel.page.title
    }

    private func defaultOnboardingPagesDataSource() -> [OnboardingPageModel] {
        var pageModels = [OnboardingPageModel]()

        let flatPaperPageModel = (page: OnboardingPage(imageName: DefaultOnboardingPage.flatPaper.imageName,
                                                       title: DefaultOnboardingPage.flatPaper.title,
                                                       description: DefaultOnboardingPage.flatPaper.description),
                                  illustrationAdapter: giniConfiguration.onboardingAlignCornersIllustrationAdapter)

        let goodLightingPageModel = (page: OnboardingPage(imageName: DefaultOnboardingPage.lighting.imageName,
                                                          title: DefaultOnboardingPage.lighting.title,
                                                          description: DefaultOnboardingPage.lighting.description),
                                     illustrationAdapter: giniConfiguration.onboardingLightingIllustrationAdapter)

        pageModels = [flatPaperPageModel, goodLightingPageModel]

        if giniConfiguration.multipageEnabled {
            let multiPageModel = (page: OnboardingPage(imageName: DefaultOnboardingPage.multipage.imageName,
                                                       title: DefaultOnboardingPage.multipage.title,
                                                       description: DefaultOnboardingPage.multipage.description),
                                  illustrationAdapter: giniConfiguration.onboardingMultiPageIllustrationAdapter)
            pageModels.append(multiPageModel)
        }

        if giniConfiguration.qrCodeScanningEnabled {
            let qrCodePageModel = (page: OnboardingPage(imageName: DefaultOnboardingPage.qrcode.imageName,
                                                        title: DefaultOnboardingPage.qrcode.title,
                                                        description: DefaultOnboardingPage.qrcode.description),
                                   illustrationAdapter: giniConfiguration.onboardingQRCodeIllustrationAdapter)
            pageModels.append(qrCodePageModel)
        }

        return pageModels
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

    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        let pageModel = pageModels[indexPath.row]
        if let adapter = pageModel.illustrationAdapter {
            adapter.pageDidAppear()
        }
    }

    func collectionView( _ collectionView: UICollectionView,
                         didEndDisplaying cell: UICollectionViewCell,
                         forItemAt indexPath: IndexPath) {
        let pageModel = pageModels[indexPath.row]
        if let adapter = pageModel.illustrationAdapter {
            adapter.pageDidDisappear()
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        let index = IndexPath(row: currentPage, section: 0)
        let attr = collectionView.layoutAttributesForItem(at: index)
        return attr?.frame.origin ?? CGPoint.zero
    }

    // MARK: - Display the page number in page controll of collection view Cell
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
        currentPage = page
        delegate?.didScroll(page: page)
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }

}

enum DefaultOnboardingPage {
    case flatPaper
    case lighting
    case multipage
    case qrcode

    var imageName: String {
        switch self {
        case .flatPaper:
            return "onboardingFlatPaper"
        case .lighting:
            return "onboardingGoodLighting"
        case .multipage:
            return "onboardingMultiPages"
        case .qrcode:
            return "onboardingQRCode"
        }
    }

    var title: String {
        switch self {
        case .flatPaper:
            return NSLocalizedStringPreferredFormat("ginicapture.onboarding.flatPaper.title",
                                                    comment: "onboarding flat paper title")
        case .lighting:
            return NSLocalizedStringPreferredFormat("ginicapture.onboarding.goodLighting.title",
                                                    comment: "onboarding good lighting title")
        case .multipage:
            return NSLocalizedStringPreferredFormat("ginicapture.onboarding.multiPages.title",
                                                    comment: "onboarding multi pages title")
        case .qrcode:
            return NSLocalizedStringPreferredFormat("ginicapture.onboarding.qrCode.title",
                                                    comment: "onboarding qrcode title")
        }
    }

    var description: String {
        switch self {
        case .flatPaper:
            return NSLocalizedStringPreferredFormat("ginicapture.onboarding.flatPaper.description",
                                                    comment: "onboarding flat paper description")
        case .lighting:
            return NSLocalizedStringPreferredFormat("ginicapture.onboarding.goodLighting.description",
                                                    comment: "onboarding good lighting description")
        case .multipage:
            return NSLocalizedStringPreferredFormat("ginicapture.onboarding.multiPages.description",
                                                    comment: "onboarding multi pages description")
        case .qrcode:
            return NSLocalizedStringPreferredFormat("ginicapture.onboarding.qrCode.description",
                                                    comment: "onboarding qrcode description")
        }
    }
}
