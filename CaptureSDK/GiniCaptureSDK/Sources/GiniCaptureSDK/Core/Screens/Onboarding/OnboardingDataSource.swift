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

    weak var delegate: OnboardingScreen?
    var isProgrammaticScroll = false

    private let giniConfiguration: GiniConfiguration
    private(set) var currentPageIndex = 0
    private var isInitialScroll = true

    lazy var pageModels: [OnboardingPageModel] = {
        if let customPages = giniConfiguration.customOnboardingPages {
            return customOnboardingPagesDataSource(from: customPages)
        } else {
            return defaultOnboardingPagesDataSource()
        }
    }()

    private lazy var pagesTracker: OnboardingPageTracker = {
        return OnboardingPageTracker(pages: pageModels)
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
        cell.titleLabel.text = pageModel.page.title
    }

    private func defaultOnboardingPagesDataSource() -> [OnboardingPageModel] {
        var pageModels = [OnboardingPageModel]()
        let flatPaperPage = OnboardingPage(imageName: DefaultOnboardingPage.flatPaper.imageName,
                                           title: DefaultOnboardingPage.flatPaper.title,
                                           description: DefaultOnboardingPage.flatPaper.description)
        let flatPaperIllustrationAdapter = giniConfiguration.onboardingAlignCornersIllustrationAdapter
        let flatPaperPageModel = OnboardingPageModel(page: flatPaperPage,
                                                     illustrationAdapter: flatPaperIllustrationAdapter,
                                                     analyticsScreen: GiniAnalyticsScreen.onboardingFlatPaper.rawValue)

        let goodLightingPage = OnboardingPage(imageName: DefaultOnboardingPage.lighting.imageName,
                                              title: DefaultOnboardingPage.lighting.title,
                                              description: DefaultOnboardingPage.lighting.description)
        let goodlightingIllustrationAdapter = giniConfiguration.onboardingLightingIllustrationAdapter
        let goodLightingScreenAnalyticValue = GiniAnalyticsScreen.onboardingLighting.rawValue
        let goodLightingPageModel = OnboardingPageModel(page: goodLightingPage,
                                                        illustrationAdapter: goodlightingIllustrationAdapter,
                                                        analyticsScreen: goodLightingScreenAnalyticValue)

        pageModels = [flatPaperPageModel, goodLightingPageModel]

        if giniConfiguration.multipageEnabled {
            let multiPage = OnboardingPage(imageName: DefaultOnboardingPage.multipage.imageName,
                                           title: DefaultOnboardingPage.multipage.title,
                                           description: DefaultOnboardingPage.multipage.description)
            let multiPageIllustrationAdapter = giniConfiguration.onboardingMultiPageIllustrationAdapter
            let multiPageModel = OnboardingPageModel(page: multiPage,
                                                     illustrationAdapter: multiPageIllustrationAdapter,
                                                     analyticsScreen: GiniAnalyticsScreen.onboardingMultipage.rawValue)
            pageModels.append(multiPageModel)
        }

        if giniConfiguration.qrCodeScanningEnabled {
            let qrCodePage = OnboardingPage(imageName: DefaultOnboardingPage.qrcode.imageName,
                                            title: DefaultOnboardingPage.qrcode.title,
                                            description: DefaultOnboardingPage.qrcode.description)
            let qrCodeIllustrationAdapter = giniConfiguration.onboardingQRCodeIllustrationAdapter
            let qrCodePageModel = OnboardingPageModel(page: qrCodePage,
                                                      illustrationAdapter: qrCodeIllustrationAdapter,
                                                      analyticsScreen: GiniAnalyticsScreen.onboardingQRcode.rawValue)
            pageModels.append(qrCodePageModel)
        }

        return pageModels
    }

    private func customOnboardingPagesDataSource(from customPages: [OnboardingPage]) -> [OnboardingPageModel] {
        return customPages.enumerated().map { index, page in
            let analyticsScreen = "\(GiniAnalyticsScreen.onboardingCustom.rawValue)\(index + 1)"
            return OnboardingPageModel(page: page,
                                       analyticsScreen: analyticsScreen,
                                       isCustom: true)
        }
    }

    private func trackEventForPage(_ pageModel: OnboardingPageModel) {
        guard !pagesTracker.seenAllPages else { return }
        guard pagesTracker.isPageNotSeen(pageModel) else { return }
        var eventProperties = [GiniAnalyticsProperty]()
        if pageModel.isCustom {
            eventProperties.append(.init(key: .customOnboardingTitle, value: pageModel.page.title))
        }
        let hasCustomItems = giniConfiguration.customOnboardingPages?.isNotEmpty ?? false
        eventProperties.append(GiniAnalyticsProperty(key: .hasCustomItems,
                                                     value: hasCustomItems))
        GiniAnalyticsManager.trackScreenShown(screenNameString: pageModel.analyticsScreen,
                                              properties: eventProperties)
        pagesTracker.markPageAsSeen(pageModel)
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let isIphoneLandscape = UIDevice.current.isIphone && collectionView.currentInterfaceOrientation.isLandscape
        let isIphoneSmall = UIDevice.current.isSmallIphone
        let suffix = isIphoneSmall ? "iphoneland-small" : "iphoneland"
        let cellIdentifier = OnboardingPageCell.reuseIdentifier
        let reuseId = isIphoneLandscape ? cellIdentifier + suffix : cellIdentifier
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId,
                                                         for: indexPath) as? OnboardingPageCell {
            configureCell(cell: cell, indexPath: indexPath)
            cell.updateConstraintsForCurrentTraits()
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

    // MARK: - Display the page number in page control of collection view cell
    private func updateCurrentPage(_ scrollView: UIScrollView) {
        guard scrollView.frame.width > 0 else { return }

        let pageWidth = scrollView.frame.width
        let contentOffsetX = scrollView.contentOffset.x
        let pageIndex = Int(round(contentOffsetX / pageWidth))
        currentPageIndex = max(0, pageIndex)
        delegate?.didScroll(pageIndex: currentPageIndex)
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isProgrammaticScroll = false
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        isProgrammaticScroll = false
        updateCurrentPage(scrollView)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateCurrentPage(scrollView)
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}
