//
//  GiniScreenAPICoordinator+Review.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

// MARK: - Review screen

extension GiniScreenAPICoordinator: ReviewViewControllerDelegate {
    public func review(
        _ controller: ReviewViewController,
        didDelete page: GiniCapturePage) {
        removeFromDocuments(document: page.document)
        visionDelegate?.didCancelReview(for: page.document)

        if pages.isEmpty {
            backToCamera()
        }
    }

    public func review(
        _ viewController: ReviewViewController,
        didTapRetryUploadFor page: GiniCapturePage) {
        update(page.document, withError: nil, isUploaded: false)
        visionDelegate?.didCapture(document: page.document, networkDelegate: self)
    }

    public func reviewDidTapAddImage(_ controller: ReviewViewController) {
        backToCamera()
    }

    func createReviewScreenContainer(with pages: [GiniCapturePage])
        -> ReviewViewController {
            let vc = ReviewViewController(pages: pages,
                                          giniConfiguration: giniConfiguration)
            vc.delegate = self

            let cancelButton = GiniBarButton(ofType: .cancel)
            cancelButton.addAction(self, #selector(closeScreen))

            if giniConfiguration.bottomNavigationBarEnabled {
                vc.navigationItem.rightBarButtonItem = cancelButton.barButton
            } else {
                vc.navigationItem.leftBarButtonItem = cancelButton.barButton
            }
            return vc
    }

    @objc fileprivate func closeScreen() {
        setOnboardingShownStatus()
        trackingDelegate?.onReviewScreenEvent(event: Event(type: .back))
        GiniAnalyticsManager.track(event: .closeTapped, screenName: .review)
        screenAPINavigationController.dismiss(animated: true)
    }

    public func reviewDidTapProcess(_ viewController: ReviewViewController, shouldSaveToGallery: Bool) {
        showAnalysisScreen(shouldSaveToGallery: shouldSaveToGallery)
    }

    @objc func popBackToReview() {
        if let reviewVC = screenAPINavigationController.viewControllers.first as? ReviewViewController {
            reviewVC.resetToEnd = true
        }
        showReview()
    }

    @objc func showReview() {
        screenAPINavigationController.popToRootViewController(animated: true)
    }

    public func review(_ viewController: ReviewViewController, didSelectPage page: GiniCapturePage) {
        let viewController = ReviewZoomViewController(page: page)
        self.screenAPINavigationController.present(viewController, animated: true)
    }
}
