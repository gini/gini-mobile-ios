//
//  OnboardingPagesDataSource.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

protocol BaseCollectionViewDataSource: UICollectionViewDelegate,
                                       UICollectionViewDataSource,
                                       UICollectionViewDelegateFlowLayout {

    init(configuration: GiniConfiguration)
}

protocol OnboardingScreen: AnyObject {
    func didScroll(pageIndex: Int)
}

class OnboardingDataSource: NSObject, BaseCollectionViewDataSource {

    private let giniConfiguration: GiniConfiguration
    weak var delegate: OnboardingScreen?
    private (set) var currentPageIndex = 0

    lazy var pageModels: [OnboardingPageModel] = {
        if let customPages = giniConfiguration.customOnboardingPages {
            return customPages.enumerated().map { index, page in
                let analyticsScreen = "\(AnalyticsScreen.onboardingCustom.rawValue)\(index + 1)"
                return OnboardingPageModel(page: page,
                                           analyticsScreen: analyticsScreen,
                                           isCustom: true)
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
        let flatPaperPage = OnboardingPage(imageName: DefaultOnboardingPage.flatPaper.imageName,
                                           title: DefaultOnboardingPage.flatPaper.title,
                                           description: DefaultOnboardingPage.flatPaper.description)
        let flatPaperPageModel = OnboardingPageModel(page: flatPaperPage,
                                                     illustrationAdapter: giniConfiguration.onboardingAlignCornersIllustrationAdapter,
                                                     analyticsScreen: AnalyticsScreen.onboardingFlatPaper.rawValue)

        let goodLightingPage = OnboardingPage(imageName: DefaultOnboardingPage.lighting.imageName,
                                              title: DefaultOnboardingPage.lighting.title,
                                              description: DefaultOnboardingPage.lighting.description)
        let goodLightingPageModel = OnboardingPageModel(page: goodLightingPage,
                                                        illustrationAdapter: giniConfiguration.onboardingLightingIllustrationAdapter,
                                                        analyticsScreen: AnalyticsScreen.onboardingLighting.rawValue)

        pageModels = [flatPaperPageModel, goodLightingPageModel]

        if giniConfiguration.multipageEnabled {
            let multiPage = OnboardingPage(imageName: DefaultOnboardingPage.multipage.imageName,
                                           title: DefaultOnboardingPage.multipage.title,
                                           description: DefaultOnboardingPage.multipage.description)
            let multiPageModel = OnboardingPageModel(page: multiPage,
                                                     illustrationAdapter: giniConfiguration.onboardingMultiPageIllustrationAdapter,
                                                     analyticsScreen: AnalyticsScreen.onboardingMultipage.rawValue)
            pageModels.append(multiPageModel)
        }

        if giniConfiguration.qrCodeScanningEnabled {
            let qrCodePage = OnboardingPage(imageName: DefaultOnboardingPage.qrcode.imageName,
                                            title: DefaultOnboardingPage.qrcode.title,
                                            description: DefaultOnboardingPage.qrcode.description)
            let qrCodePageModel = OnboardingPageModel(page: qrCodePage,
                                                      illustrationAdapter: giniConfiguration.onboardingQRCodeIllustrationAdapter,
                                                      analyticsScreen: AnalyticsScreen.onboardingQRcode.rawValue)
            pageModels.append(qrCodePageModel)
        }

        return pageModels
    }

    private lazy var pagesCounter: OnboardingPageSeenCounter = {
        return OnboardingPageSeenCounter(pages: pageModels)
    }()

    private func trackEventForPage(_ pageModel: OnboardingPageModel) {
        guard !pagesCounter.seenAllPages else { return }
        guard pagesCounter.pageNotSeen(pageModel) else { return }
        var eventProperties = [AnalyticsProperty]()
        if pageModel.isCustom {
            eventProperties.append(.init(key: .customOnboardingTitle, value: pageModel.page.title))
        }
        AnalyticsManager.trackScreenShown(screenNameString: pageModel.analyticsScreen,
                                          properties: eventProperties)
        pagesCounter.markPageAsSeen(pageModel)
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

        trackEventForPage(pageModel)
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
        let index = IndexPath(row: currentPageIndex, section: 0)
        let attr = collectionView.layoutAttributesForItem(at: index)
        return attr?.frame.origin ?? CGPoint.zero
    }

    private var isInitialScroll = true

    // MARK: - Display the page number in page control of collection view Cell
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // this method is called twice when the screen is displayed for the first time
        guard !isInitialScroll else {
            isInitialScroll = false
            return
        }
        guard scrollView.frame.width > 0 else { return }

        let pageWidth = scrollView.frame.width
        let contentOffsetX = scrollView.contentOffset.x
        let adjustedContentOffsetX = max(0, contentOffsetX)
        let pageIndex = Int((adjustedContentOffsetX + pageWidth / 2) / pageWidth)
        currentPageIndex = max(0, pageIndex)
        delegate?.didScroll(pageIndex: pageIndex)
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}
