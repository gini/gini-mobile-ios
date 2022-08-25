//
//  GiniScreenAPICoordinator+Analysis.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 4/4/18.
//

import Foundation

// MARK: - Analysis Screen

extension GiniScreenAPICoordinator {
    func createAnalysisScreen(withDocument document: GiniCaptureDocument) -> AnalysisViewController {
        let viewController = AnalysisViewController(document: document)
        viewController.setupNavigationItem(usingResources: self.cancelButtonResource,
                                           selector: #selector(back),
                                           position: .left,
                                           target: self)
        return viewController
    }
}

// MARK: - ImageAnalysisNoResults screen

extension GiniScreenAPICoordinator {
    func createImageAnalysisNoResultsScreen(type: NoResultScreenViewController.NoResultType) -> NoResultScreenViewController {
        let vm: NoResultScreenViewModel
        let viewController: NoResultScreenViewController
        let isCameraViewControllerLoaded: Bool = {
            guard let cameraViewController = cameraViewController else {
                return false
            }
            return screenAPINavigationController.viewControllers.contains(cameraViewController)
        }()
        
        if isCameraViewControllerLoaded {
            vm = NoResultScreenViewModel { [weak self] in
                self?.backToCamera()
            } manuallyPressed: { [weak self] in
                //TODO: the same as cancel
                self?.closeScreenApi()
            } cancellPressed: { [weak self] in
                self?.backToCamera()
            }
            
        } else {
            vm = NoResultScreenViewModel { [weak self] in
                //TODO: check if this make sense
                self?.closeScreenApi()
            } manuallyPressed: { [weak self] in
                //TODO: check if this make sense
                self?.closeScreenApi()
            } cancellPressed: { [weak self] in
                self?.closeScreenApi()
            }
        }
        viewController = NoResultScreenViewController(giniConfiguration: giniConfiguration, type: .image, viewModel: vm)
        
        return viewController
    }
}

// MARK: - AnalysisDelegate

extension GiniScreenAPICoordinator: AnalysisDelegate {
    public func displayError(withMessage message: String?, andAction action: (() -> Void)?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                let message = message,
                let action = action else { return }
            
            if let analysisViewController = self.analysisViewController {
                analysisViewController.showError(with: message, action: { [weak self] in
                    guard let self = self else { return }
                    self.analysisErrorAndAction = nil
                    action()
                })
            } else {
                self.analysisErrorAndAction = (message, action)
            }

        }
    }
    
    public func tryDisplayNoResultsScreen() -> Bool {
        if pages.type == .image {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.imageAnalysisNoResultsViewController = self.createImageAnalysisNoResultsScreen(type: .image)
                self.screenAPINavigationController.pushViewController(self.imageAnalysisNoResultsViewController!,
                                                                      animated: true)
            }
            
            return true
        } else if pages.type == .pdf {
            //TODO: no results for pdf
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.imageAnalysisNoResultsViewController = self.createImageAnalysisNoResultsScreen(type: .pdf)
                self.screenAPINavigationController.pushViewController(self.imageAnalysisNoResultsViewController!,
                                                                      animated: true)
            }
        }
        return false
    }    
}
