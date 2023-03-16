//
//  GiniScreenAPICoordinator+Review.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 4/4/18.
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

            let cancelButton = GiniCancelBarButton()
            cancelButton.addAction(self, #selector(closeScreen))

            if giniConfiguration.bottomNavigationBarEnabled {
                vc.navigationItem.rightBarButtonItem = cancelButton.barButton
            } else {
                vc.navigationItem.leftBarButtonItem = cancelButton.barButton
            }
            return vc
    }

    @objc fileprivate func closeScreen() {
        trackingDelegate?.onReviewScreenEvent(event: Event(type: .back))
        screenAPINavigationController.dismiss(animated: true)
    }

    public func reviewDidTapProcess(_ viewController: ReviewViewController) {
        showAnalysisScreen()
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
