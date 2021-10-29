//
//  GiniScreenAPICoordinator+Review.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 4/4/18.
//

import UIKit

// MARK: - Review Screen

extension GiniScreenAPICoordinator: ReviewViewControllerDelegate {
    
    public func review(_ viewController: ReviewViewController, didReview document: GiniCaptureDocument) {
        updateDocument(for: document)
    }
    
    func createReviewScreen(withDocument document: GiniCaptureDocument,
                            isFirstScreen: Bool = false) -> ReviewViewController {
        let reviewViewController = ReviewViewController(document: document,
                                                        giniConfiguration: giniConfiguration)
        reviewViewController.delegate = self
        reviewViewController.title = .localized(resource: NavigationBarStrings.reviewTitle)
        reviewViewController.setupNavigationItem(usingResources: nextButtonResource,
                                                 selector: #selector(showAnalysisScreen),
                                                 position: .right,
                                                 target: self)
        
        let backResource = isFirstScreen ? closeButtonResource : backButtonResource
        reviewViewController.setupNavigationItem(usingResources: backResource,
                                                 selector: #selector(back),
                                                 position: .left,
                                                 target: self)
        
        return reviewViewController
    }
}

// MARK: - Multipage Review screen

extension GiniScreenAPICoordinator: MultipageReviewViewControllerDelegate {
    public func multipageReview(_ controller: MultipageReviewViewController,
                         didRotate page: GiniCapturePage) {
        updateDocument(for: page.document)
    }
    
    public func multipageReview(_ controller: MultipageReviewViewController,
                         didDelete page: GiniCapturePage) {
        removeFromDocuments(document: page.document)
        visionDelegate?.didCancelReview(for: page.document)
        
        if pages.isEmpty {
            closeMultipageScreen()
        }
    }
    
    public func multipageReview(_ controller: MultipageReviewViewController,
                         didReorder pages: [GiniCapturePage]) {
        replaceDocuments(with: pages)
    }
    
    public func multipageReview(_ viewController: MultipageReviewViewController,
                         didTapRetryUploadFor page: GiniCapturePage) {
        update(page.document, withError: nil, isUploaded: false)
        visionDelegate?.didCapture(document: page.document, networkDelegate: self)
    }
    
    public func multipageReviewDidTapAddImage(_ controller: MultipageReviewViewController) {
        closeMultipageScreen()
    }

    func createMultipageReviewScreenContainer(with pages: [GiniCapturePage])
        -> MultipageReviewViewController {
            let vc = MultipageReviewViewController(pages: pages,
                                                   giniConfiguration: giniConfiguration)
            vc.delegate = self
            vc.setupNavigationItem(usingResources: backButtonResource,
                                   selector: #selector(closeMultipageScreen),
                                   position: .left,
                                   target: self)
            
            vc.setupNavigationItem(usingResources: nextButtonResource,
                                   selector: #selector(showAnalysisScreen),
                                   position: .right,
                                   target: self)
            
            vc.navigationItem.rightBarButtonItem?.isEnabled = false
            return vc
    }
    
    @objc fileprivate func closeMultipageScreen() {
        
        trackingDelegate?.onReviewScreenEvent(event: Event(type: .back))
        
        self.screenAPINavigationController.popViewController(animated: true)
    }
    
    func showMultipageReview() {
        if !screenAPINavigationController.viewControllers.contains(multiPageReviewViewController) {
            screenAPINavigationController.pushViewController(multiPageReviewViewController,
                                                             animated: true)
        }
    }
    
    func refreshMultipageReviewNextButton(with pages: [GiniCapturePage]) {
        
        multiPageReviewViewController.navigationItem
            .rightBarButtonItem?
            .isEnabled = pages.allSatisfy { $0.isUploaded }
    }
}
