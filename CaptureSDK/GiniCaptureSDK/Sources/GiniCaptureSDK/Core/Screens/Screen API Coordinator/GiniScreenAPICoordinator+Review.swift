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
            closeScreen()
        }
    }

    public func review(_ viewController: ReviewViewController,
                         didTapRetryUploadFor page: GiniCapturePage) {
        update(page.document, withError: nil, isUploaded: false)
        visionDelegate?.didCapture(document: page.document, networkDelegate: self)
    }
    
    public func reviewDidTapAddImage(_ controller: ReviewViewController) {
        closeScreen()
    }

    func createReviewScreenContainer(with pages: [GiniCapturePage])
        -> ReviewViewController {
            let vc = ReviewViewController(pages: pages,
                                          giniConfiguration: giniConfiguration)
            vc.delegate = self
            vc.setupNavigationItem(usingResources: backButtonResource,
                                   selector: #selector(closeScreen),
                                   position: .left,
                                   target: self)
            
            vc.setupNavigationItem(usingResources: nextButtonResource,
                                   selector: #selector(showAnalysisScreen),
                                   position: .right,
                                   target: self)
            
            vc.navigationItem.rightBarButtonItem?.isEnabled = false
            return vc
    }
    
    @objc fileprivate func closeScreen() {
        trackingDelegate?.onReviewScreenEvent(event: Event(type: .back))
        
        self.screenAPINavigationController.popViewController(animated: true)
    }

    public func reviewDidTapProcess(_ viewController: ReviewViewController) {
        showAnalysisScreen()
    }
    
    func showReview() {
        if !screenAPINavigationController.viewControllers.contains(reviewViewController) {
            screenAPINavigationController.pushViewController(reviewViewController,
                                                             animated: true)
        }
    }
    
    func refreshReviewNextButton(with pages: [GiniCapturePage]) {
        reviewViewController.navigationItem
            .rightBarButtonItem?
            .isEnabled = pages.allSatisfy { $0.isUploaded }
    }

    public func review(_ viewController: ReviewViewController, didSelectPage page: GiniCapturePage) {
        let viewController = ReviewZoomViewController(page: page)
        self.screenAPINavigationController.present(viewController, animated: true)
    }
}
