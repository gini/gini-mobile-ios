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

        let cancelButton = GiniBarButton(ofType: .cancel)
        cancelButton.addAction(self, #selector(back))

        if giniConfiguration.bottomNavigationBarEnabled {
            viewController.navigationItem.setHidesBackButton(true, animated: false)
            viewController.navigationItem.rightBarButtonItem = cancelButton.barButton
        } else {
            viewController.navigationItem.leftBarButtonItem = cancelButton.barButton
        }

        return viewController
    }
}

// MARK: - ImageAnalysisNoResults screen

extension GiniScreenAPICoordinator {
    func createImageAnalysisNoResultsScreen(
            type: NoResultScreenViewController.NoResultType
        ) -> NoResultScreenViewController {
        let viewModel: BottomButtonsViewModel
        let viewController: NoResultScreenViewController
        switch type {
        case .qrCode:
            viewModel = createRetakeAndEnterManuallyButtonsViewModel()
        case .image:
            if pages.contains(where: { $0.document.isImported == false }) {
                // if there is a photo captured with camera
                viewModel = createRetakeAndEnterManuallyButtonsViewModel()
            } else {
                viewModel = BottomButtonsViewModel(
                    manuallyPressed: { [weak self] in
                        if let delegate = self?.visionDelegate {
                            delegate.didPressEnterManually()
                        } else {
                            self?.screenAPINavigationController.dismiss(animated: true)
                        }
                    }, cancelPressed: { [weak self] in
                        self?.closeScreenApi()
                })
            }
        default:
            viewModel = BottomButtonsViewModel(
                manuallyPressed: { [weak self] in
                    self?.screenAPINavigationController.dismiss(animated: true)
                }, cancelPressed: { [weak self] in
                self?.closeScreenApi()
            })
        }
        viewController = NoResultScreenViewController(giniConfiguration: giniConfiguration,
                                                      type: type,
                                                      viewModel: viewModel)
        return viewController
    }

    private func createRetakeAndEnterManuallyButtonsViewModel() -> BottomButtonsViewModel {
        return BottomButtonsViewModel(
            retakeBlock: { [weak self] in
                self?.pages = []
                self?.backToCamera()
            },
            manuallyPressed: { [weak self] in
                if let delegate = self?.visionDelegate {
                    delegate.didPressEnterManually()
                } else {
                    self?.screenAPINavigationController.dismiss(animated: true)
                }
            }, cancelPressed: { [weak self] in
                self?.closeScreenApi()
        })
    }
}

// MARK: - AnalysisDelegate

extension GiniScreenAPICoordinator: AnalysisDelegate {

    public func displayError(
        errorType: ErrorType,
        animated: Bool
    ) {
        let viewModel: BottomButtonsViewModel
        switch pages.type {
        case .image:
            if self.pages.contains(where: { $0.document.isImported == false }) {
                // if there is a photo captured with camera
                viewModel = BottomButtonsViewModel(
                    retakeBlock: { [weak self] in
                        self?.pages = []
                        self?.backToCamera()
                    },
                    manuallyPressed: { [weak self] in
                        if let delegate = self?.visionDelegate {
                            delegate.didPressEnterManually()
                        } else {
                            self?.screenAPINavigationController.dismiss(animated: animated)
                        }
                    }, cancelPressed: { [weak self] in
                        self?.closeScreenApi()
                })
            } else {
                viewModel = BottomButtonsViewModel(
                    manuallyPressed: { [weak self] in
                        if let delegate = self?.visionDelegate {
                            delegate.didPressEnterManually()
                        } else {
                            self?.screenAPINavigationController.dismiss(animated: animated)
                        }
                    }, cancelPressed: { [weak self] in
                    self?.closeScreenApi()
                })
            }
        default:
            viewModel = BottomButtonsViewModel(
                manuallyPressed: { [weak self] in
                    self?.screenAPINavigationController.dismiss(animated: true)
                }, cancelPressed: { [weak self] in
                self?.closeScreenApi()
            })
        }

        let viewController = ErrorScreenViewController(
            giniConfiguration: giniConfiguration,
            type: errorType,
            documentType: pages.type ?? .pdf,
            viewModel: viewModel)

        screenAPINavigationController.pushViewController(viewController, animated: animated)
    }

    public func tryDisplayNoResultsScreen() {
        var shouldDisplay = false
        var noResultType: NoResultScreenViewController.NoResultType?
        switch pages.type {
        case .image:
            noResultType = .image
            shouldDisplay = true
        case .pdf:
            noResultType = .pdf
            shouldDisplay = true
        case .qrcode:
            noResultType = .qrCode
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
    }
}
