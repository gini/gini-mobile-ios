//
//  GiniScreenAPICoordinator+Review.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 4/4/18.
//

import UIKit

// MARK: -  Review screen

extension GiniScreenAPICoordinator: ReviewViewControllerDelegate {
    public func review(_ controller: ReviewViewController,
                         didDelete page: GiniCapturePage) {
        removeFromDocuments(document: page.document)
        visionDelegate?.didCancelReview(for: page.document)
        
        if pages.isEmpty {
            backToCamera()
        }
    }

    public func review(_ viewController: ReviewViewController,
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
            let cancel = GiniPreferredButtonResource(
                image: nil, title: "ginicapture.navigationbar.analysis.back",
                                        comment: "Button title in the navigation bar for the cancel button on the review screen",
                                        configEntry: self.giniConfiguration.navigationBarCameraTitleHelpButton)
            vc.setupNavigationItem(usingResources: cancel,
                                   selector: #selector(showReview),
                                   position: .left,
                                   target: self)

            return vc
    }
    
    @objc fileprivate func closeScreen() {
        trackingDelegate?.onReviewScreenEvent(event: Event(type: .back))

        if !giniConfiguration.multipageEnabled {
            removeFromDocuments(document: pages.first!.document)
        }
        
        screenAPINavigationController.dismiss(animated: true)
    }

    public func reviewDidTapProcess(_ viewController: ReviewViewController) {
        showAnalysisScreen()
    }
    
    @objc func showReview() {
        screenAPINavigationController.popToRootViewController(animated: true)
    }
}
