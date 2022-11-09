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
        if giniConfiguration.bottomNavigationBarEnabled {
            viewController.navigationItem.setHidesBackButton(true, animated: false)
            viewController.setupNavigationItem(usingResources: self.cancelButtonResource,
                                               selector: #selector(back),
                                               position: .right,
                                               target: self)
        } else {
            viewController.setupNavigationItem(usingResources: self.cancelButtonResource,
                                               selector: #selector(back),
                                               position: .left,
                                               target: self)
        }

        return viewController
    }
}

// MARK: - ImageAnalysisNoResults screen

extension GiniScreenAPICoordinator {
    func createImageAnalysisNoResultsScreen(
            type: NoResultScreenViewController.NoResultType,
            resultDelegate: GiniCaptureResultsDelegate? = nil
        ) -> NoResultScreenViewController {
        let viewModel: NoResultScreenViewModel
        let viewController: NoResultScreenViewController
        switch type {
        case .image:
            if pages.contains(where: { $0.document.isImported == false }) {
                // if there is a photo captured with camera
                viewModel = NoResultScreenViewModel(
                    retakeBlock: { [weak self] in
                        self?.pages = []
                        self?.backToCamera()
                    },
                    manuallyPressed: { [weak self, weak resultDelegate] in
                        if let delegate = resultDelegate {
                            delegate.giniCaptureDidEnterManually()
                        } else {
                            self?.screenAPINavigationController.dismiss(animated: true)
                        }
                    }, cancelPressed: { [weak self] in
                    self?.backToCamera()
                })
            } else {
                viewModel = NoResultScreenViewModel(
                    manuallyPressed: { [weak self, weak resultDelegate] in
                        if let delegate = resultDelegate {
                            delegate.giniCaptureDidEnterManually()
                        } else {
                            self?.screenAPINavigationController.dismiss(animated: true)
                        }
                    }, cancelPressed: { [weak self] in
                    self?.backToCamera()
                })
            }
        default:
            viewModel = NoResultScreenViewModel(
                manuallyPressed: { [weak self] in
                    self?.screenAPINavigationController.dismiss(animated: true)
                }, cancelPressed: { [weak self] in
                self?.closeScreenApi()
            })
        }
        viewController = NoResultScreenViewController(
            giniConfiguration: giniConfiguration,
            type: type,
            viewModel: viewModel)

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

    public func tryDisplayNoResultsScreen(
        resultDelegate: GiniCaptureResultsDelegate?
    ) -> Bool {
        var shouldDisplay = false
        var noResultType: NoResultScreenViewController.NoResultType?
        switch pages.type {
        case .image:
            noResultType = .image
            shouldDisplay = true
        case .pdf:
            noResultType = .pdf
            shouldDisplay = true
        default:
            shouldDisplay = false
        }

        if shouldDisplay, let type = noResultType {
            let noResultsScreen = self.createImageAnalysisNoResultsScreen(type: type)
            DispatchQueue.main.async {
                self.imageAnalysisNoResultsViewController = noResultsScreen
                self.screenAPINavigationController.pushViewController(
                    noResultsScreen, animated: true)
            }
        }
        return shouldDisplay
    }
}
