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
    var currentPageIndex = 0

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
        var flatPaperPage = OnboardingPage(imageName: DefaultOnboardingPage.flatPaper.imageName,
                                           title: DefaultOnboardingPage.flatPaper.title,
                                           description: DefaultOnboardingPage.flatPaper.description)
        flatPaperPage.analyticsScreen = AnalyticsScreen.onboardingFlatPaper
        let flatPaperPageModel = (page: flatPaperPage,
                                  illustrationAdapter: giniConfiguration.onboardingAlignCornersIllustrationAdapter)

        var goodLightingPage = OnboardingPage(imageName: DefaultOnboardingPage.lighting.imageName,
                                              title: DefaultOnboardingPage.lighting.title,
                                              description: DefaultOnboardingPage.lighting.description)
        goodLightingPage.analyticsScreen = AnalyticsScreen.onboardingLighting

        let goodLightingPageModel = (page: goodLightingPage,
                                     illustrationAdapter: giniConfiguration.onboardingLightingIllustrationAdapter)

        pageModels = [flatPaperPageModel, goodLightingPageModel]

        if giniConfiguration.multipageEnabled {
            var multiPage = OnboardingPage(imageName: DefaultOnboardingPage.multipage.imageName,
                                           title: DefaultOnboardingPage.multipage.title,
                                           description: DefaultOnboardingPage.multipage.description)
            multiPage.analyticsScreen = AnalyticsScreen.onboardingMultipage

            let multiPageModel = (page: multiPage,
                                  illustrationAdapter: giniConfiguration.onboardingMultiPageIllustrationAdapter)
            pageModels.append(multiPageModel)
        }

        if giniConfiguration.qrCodeScanningEnabled {
            var qrCodePage = OnboardingPage(imageName: DefaultOnboardingPage.qrcode.imageName,
                                            title: DefaultOnboardingPage.qrcode.title,
                                            description: DefaultOnboardingPage.qrcode.description)
            qrCodePage.analyticsScreen = AnalyticsScreen.onboardingQRcode
            let qrCodePageModel = (page: qrCodePage,
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
        let index = IndexPath(row: currentPageIndex, section: 0)
        let attr = collectionView.layoutAttributesForItem(at: index)
        return attr?.frame.origin ?? CGPoint.zero
    }

    private var isInitialScroll = true

    // MARK: - Display the page number in page controll of collection view Cell
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // this method is called twice when the screen is displyed for the first time
        guard !isInitialScroll else {
            isInitialScroll = false
            return
        }

        let page = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
        currentPageIndex = page
        delegate?.didScroll(page: page)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("DEBUG - scrollViewDidEndDecelerating")
        let pageWidth = scrollView.frame.size.width
        let currentPage = Int(scrollView.contentOffset.x / pageWidth)

        // Track an event for the current page
        trackEventForPage(currentPage)
    }

    func trackEventForPage(_ page: Int) {
        // Track your event based on the page
        // Trigger your event tracking code here
        if let nextPageAnalyticsScreen = pageModels[page].page.analyticsScreen{
            AnalyticsManager.trackScreenShown(screenName: nextPageAnalyticsScreen)
//            print("DEBUG - trackEventForPage =", nextPageAnalyticsScreen)
            //TODO: need to keep track of the event already sent because when the user reaches the last page can still scroll and because of the bounce we send more events
        }
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}
