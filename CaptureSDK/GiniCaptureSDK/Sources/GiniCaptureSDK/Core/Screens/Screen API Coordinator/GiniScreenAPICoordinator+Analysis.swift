//
//  GiniScreenAPICoordinator+Analysis.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

// MARK: - Analysis Screen

extension GiniScreenAPICoordinator {
    func createAnalysisScreen(withDocument document: GiniCaptureDocument,
                              shouldSaveToGallery: Bool = false) -> AnalysisViewController {
        let viewController = AnalysisViewController(document: document)
        viewController.shouldSaveToGallery = shouldSaveToGallery

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
typealias NoResultType = NoResultScreenViewController.NoResultType
extension GiniScreenAPICoordinator {
    func createImageAnalysisNoResultsScreen(type: NoResultType) -> NoResultScreenViewController {
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
                    viewModel = createDefaultButtonsViewModel()
                }
            default:
                viewModel = createDefaultButtonsViewModel()
            }
            viewController = NoResultScreenViewController(giniConfiguration: giniConfiguration,
                                                          type: type,
                                                          viewModel: viewModel)
            return viewController
        }

    private func createDefaultButtonsViewModel() -> BottomButtonsViewModel {
        BottomButtonsViewModel(
            manuallyPressed: { [weak self] in
                self?.finishWithEnterManually()
            },
            backPressed: { [weak self] in
                self?.finishWithRetake()
        })
    }

    private func createRetakeAndEnterManuallyButtonsViewModel() -> BottomButtonsViewModel {
        return BottomButtonsViewModel(
            retakeBlock: { [weak self] in
                self?.finishWithRetake()
            },
            manuallyPressed: { [weak self] in
                self?.finishWithEnterManually()
            },
            backPressed: { [weak self] in
                self?.finishWithRetake()
        })
    }
}

// MARK: - AnalysisDelegate

extension GiniScreenAPICoordinator: AnalysisDelegate {

    public func displayError(errorType: ErrorType, animated: Bool) {
        let viewModel: BottomButtonsViewModel
        switch pages.type {
        case .image:
            if self.pages.contains(where: { $0.document.isImported == false }) {
                // if there is a photo captured with camera
                viewModel = createRetakeAndEnterManuallyButtonsViewModel()
            } else {
                viewModel = createDefaultButtonsViewModel()
            }
        default:
                viewModel = createDefaultButtonsViewModel()
        }

        self.trackingDelegate?.onAnalysisScreenEvent(event: Event(type: .error))
        let viewController = ErrorScreenViewController(giniConfiguration: giniConfiguration,
                                                       type: errorType,
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
        case .xml:
            noResultType = .xml
            shouldDisplay = true
        default:
            shouldDisplay = false
        }

        if shouldDisplay, let type = noResultType {
            let noResultsScreen = self.createImageAnalysisNoResultsScreen(type: type)
            DispatchQueue.main.async {
                self.noResultsViewController = noResultsScreen
                self.trackingDelegate?.onAnalysisScreenEvent(event: Event(type: .noResults))
                self.screenAPINavigationController.pushViewController(
                    noResultsScreen, animated: true)
            }
        }
    }
}
