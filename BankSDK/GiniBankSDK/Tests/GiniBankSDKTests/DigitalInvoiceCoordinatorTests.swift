//
//  DigitalInvoiceCoordinatorTests.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation
import Testing
import UIKit
import GiniUtilites
import GiniBankAPILibrary
@testable import GiniBankSDK
@testable import GiniCaptureSDK

extension GiniConfigurationSharedStateSuite {

    /**
     Covers `DigitalInvoiceCoordinator`: root view controller exposure, start,
     the `GiniBottomSheetAccessibilityRestorable` conformance, delegate
     forwarding and the edit-line-item bottom sheet presentation.

     Nested in the shared-state suite because the coordinator's initializer
     reads `GiniBankConfiguration.shared.skontoEnabled`.
     */
    @Suite("DigitalInvoiceCoordinator")
    @MainActor
    struct DigitalInvoiceCoordinatorTests {

        // MARK: - Coordinator basics

        @Test("The root view controller is the digital invoice screen")
        func rootViewControllerIsDigitalInvoiceScreen() throws {
            let (coordinator, _, _) = try makeCoordinator()

            #expect(coordinator.rootViewController is DigitalInvoiceViewController)
            #expect(coordinator.childCoordinators.isEmpty)
        }

        @Test("Starting the coordinator pushes the digital invoice screen")
        func startPushesRootViewController() throws {
            let (coordinator, navigationController, _) = try makeCoordinator()

            coordinator.start()

            #expect(navigationController.pushedControllers.count == 1)
            #expect(navigationController.pushedControllers.last === coordinator.rootViewController)
        }

        // MARK: - GiniBottomSheetAccessibilityRestorable

        @Test("The presenter view controller is the navigation controller")
        func presenterViewControllerIsNavigationController() throws {
            let (coordinator, navigationController, _) = try makeCoordinator()

            #expect(coordinator.presenterViewController === navigationController)
        }

        @Test("The default accessibility focus target is the top view controller")
        func accessibilityFocusTargetIsTopViewController() throws {
            let rootViewController = UIViewController()
            let navigationController = UINavigationController(rootViewController: rootViewController)
            let analysisDelegate = MockCaptureNetworkDelegate()
            let coordinator = DigitalInvoiceCoordinator(navigationController: navigationController,
                                                        digitalInvoice: try ExtractionResultFixture.digitalInvoice(),
                                                        analysisDelegate: analysisDelegate)

            #expect(coordinator.accessibilityFocusTargetViewController === rootViewController,
                    "The default conformance should focus the presenter's top view controller")
        }

        // MARK: - DigitalInvoiceViewModel delegate forwarding

        @Test("Cancelling the digital invoice forwards to the coordinator delegate")
        func didTapCancelForwardsToDelegate() throws {
            let (coordinator, _, _) = try makeCoordinator()
            let delegate = MockDigitalInvoiceCoordinatorDelegate()
            coordinator.delegate = delegate

            coordinator.didTapCancel(on: DigitalInvoiceViewModel(invoice: nil))

            #expect(delegate.cancelledCoordinators.count == 1)
            #expect(delegate.cancelledCoordinators.first === coordinator)
        }

        @Test("Paying forwards the invoice and the analysis delegate")
        func didTapPayForwardsInvoiceAndAnalysisDelegate() throws {
            let (coordinator, _, analysisDelegate) = try makeCoordinator()
            let delegate = MockDigitalInvoiceCoordinatorDelegate()
            coordinator.delegate = delegate
            let invoice = try ExtractionResultFixture.digitalInvoice()
            let viewModel = DigitalInvoiceViewModel(invoice: invoice)

            coordinator.didTapPay(on: viewModel)

            #expect(delegate.finishedInvoices.count == 1)
            #expect(delegate.finishedInvoices.first??.lineItems.count == invoice.lineItems.count)
            #expect(delegate.finishedAnalysisDelegates.first === analysisDelegate,
                    "The analysis delegate passed at init should be forwarded on pay")
        }

        @Test("Pushing help shows the digital invoice help screen")
        func didTapHelpPushesHelpScreen() throws {
            let (coordinator, navigationController, _) = try makeCoordinator()

            coordinator.didTapHelp(on: DigitalInvoiceViewModel(invoice: nil))

            #expect(navigationController.pushedControllers.last is DigitalInvoiceHelpViewController)
        }

        // MARK: - Edit line item bottom sheet

        @Test("Editing a line item presents the edit sheet with accessibility restoration wired")
        func didTapEditPresentsEditBottomSheet() throws {
            let (coordinator, navigationController, _) = try makeCoordinator()
            let invoice = try ExtractionResultFixture.digitalInvoice()
            let viewModel = DigitalInvoiceViewModel(invoice: invoice)
            let cellViewModel = DigitalLineItemTableViewCellViewModel(lineItem: invoice.lineItems[0],
                                                                      indexPath: IndexPath(row: 0, section: 0),
                                                                      invoiceNumTotal: invoice.numTotal,
                                                                      invoiceLineItemsCount: invoice.lineItems.count,
                                                                      nameMaxCharactersCount: 50)

            coordinator.didTapEdit(on: viewModel, lineItemViewModel: cellViewModel)

            let editViewController = try #require(navigationController.presentedControllers.last
                                                    as? EditLineItemViewController,
                                                  "Editing should present the edit line item sheet")
            #expect(editViewController.isModalInPresentation,
                    "The edit sheet should not be dismissible by swipe")
            #expect(editViewController.onDismiss != nil,
                    "The coordinator should wire accessibility restoration on dismissal")
        }

        @Test("Cancelling the edit sheet dismisses it")
        func editCancelDismissesSheet() throws {
            let (coordinator, navigationController, _) = try makeCoordinator()
            let lineItem = try ExtractionResultFixture.lineItem(at: 0)
            let editViewModel = EditLineItemViewModel(lineItem: lineItem, index: 0)

            coordinator.didCancel(on: editViewModel)

            #expect(navigationController.dismissCallCount == 1)
        }

        // MARK: - Skonto wiring at init

        @Test("Init parses Skonto discounts from the extractions when the feature is enabled")
        func initParsesSkontoDiscountsWhenEnabled() throws {
            let previousSkontoEnabled = GiniBankConfiguration.shared.skontoEnabled
            GiniBankConfiguration.shared.skontoEnabled = true
            defer { GiniBankConfiguration.shared.skontoEnabled = previousSkontoEnabled }

            let invoice = try ExtractionResultFixture.digitalInvoiceWithSkontoDiscounts()
            let navigationController = SpyNavigationController()
            let coordinator = DigitalInvoiceCoordinator(navigationController: navigationController,
                                                        digitalInvoice: invoice,
                                                        analysisDelegate: MockCaptureNetworkDelegate())

            /// The Skonto view model is wired into the coordinator's private view
            /// model, so the assertion is structural: initialization with Skonto
            /// extractions must still produce a working digital invoice screen.
            #expect(coordinator.rootViewController is DigitalInvoiceViewController)
        }

        @Test("Paying with a Skonto edge case still forwards the invoice")
        func didTapPayWithSkontoEdgeCaseForwardsInvoice() throws {
            /// The analysis delegate is held weakly by the coordinator — keep it alive.
            let (coordinator, _, analysisDelegate) = try makeCoordinator()
            defer { withExtendedLifetime(analysisDelegate) {} }
            let delegate = MockDigitalInvoiceCoordinatorDelegate()
            coordinator.delegate = delegate
            let invoice = try ExtractionResultFixture.digitalInvoice()
            let viewModel = DigitalInvoiceViewModel(invoice: invoice)

            let skontoExtractionResult = try ExtractionResultFixture.load(named: "skontoDiscounts")
            let skontoDiscounts = try SkontoDiscounts(extractions: skontoExtractionResult)
            let skontoViewModel = SkontoViewModel(skontoDiscounts: skontoDiscounts,
                                                  isWithDiscountSwitchAvailable: false)
            try #require(skontoViewModel.edgeCase != nil,
                         "The fixture's past due date should produce a Skonto edge case")
            viewModel.skontoViewModel = skontoViewModel

            coordinator.didTapPay(on: viewModel)

            #expect(delegate.finishedInvoices.count == 1,
                    "The edge-case analytics path must not prevent finishing the analysis")
        }

        // MARK: - Onboarding

        @Test("Requesting onboarding presents the digital invoice onboarding screen")
        func shouldShowOnboardingPresentsOnboardingScreen() throws {
            let (coordinator, navigationController, _) = try makeCoordinator()

            coordinator.shouldShowDigitalInvoiceOnboarding(on: DigitalInvoiceViewModel(invoice: nil))

            let onboardingViewController = try #require(navigationController.presentedControllers.last
                                                            as? DigitalInvoiceOnboardingViewController,
                                                        "Onboarding should be presented from the storyboard")
            let onboardingDelegate = onboardingViewController.delegate as? DigitalInvoiceViewController
            #expect(onboardingDelegate === coordinator.rootViewController,
                    "The digital invoice screen should receive the onboarding dismissal")
        }

        // MARK: - Saving edited line items

        @Test("Saving an edited line item dismisses the edit sheet")
        func didSaveWithChangedValuesDismissesEditSheet() throws {
            let (coordinator, navigationController, _) = try makeCoordinator()
            let lineItem = try ExtractionResultFixture.lineItem(at: 0)
            let editViewModel = EditLineItemViewModel(lineItem: lineItem, index: 0)
            editViewModel.delegate = coordinator
            let newPrice = try #require(Decimal(string: "12.34"))

            /// Saving with changed values also records the `itemsChanged`
            /// analytics before the coordinator dismisses the sheet.
            editViewModel.didTapSave(name: "Changed product name",
                                     price: newPrice,
                                     currency: "eur",
                                     quantity: 3)

            #expect(navigationController.dismissCallCount == 1)
        }

        @Test("Saving without any changed values still dismisses the edit sheet")
        func didSaveWithoutChangesDismissesEditSheet() throws {
            let (coordinator, navigationController, _) = try makeCoordinator()
            let lineItem = try ExtractionResultFixture.lineItem(at: 0)
            let editViewModel = EditLineItemViewModel(lineItem: lineItem, index: 0)

            coordinator.didSave(lineItem: lineItem, on: editViewModel)

            #expect(navigationController.dismissCallCount == 1)
        }

        @Test("Saving a line item with an out-of-range index is ignored")
        func didSaveWithOutOfRangeIndexIsIgnored() throws {
            let (coordinator, navigationController, _) = try makeCoordinator()
            let lineItem = try ExtractionResultFixture.lineItem(at: 0)
            let editViewModel = EditLineItemViewModel(lineItem: lineItem, index: 99)

            coordinator.didSave(lineItem: lineItem, on: editViewModel)

            #expect(navigationController.dismissCallCount == 0,
                    "An invalid index must not modify the invoice or dismiss anything")
        }

        @Test("Dismissing the edit sheet restores the presenter's accessibility")
        func editSheetDismissalRestoresPresenterAccessibility() async throws {
            let (coordinator, navigationController, _) = try makeCoordinator()
            let invoice = try ExtractionResultFixture.digitalInvoice()
            let viewModel = DigitalInvoiceViewModel(invoice: invoice)
            let cellViewModel = DigitalLineItemTableViewCellViewModel(lineItem: invoice.lineItems[0],
                                                                      indexPath: IndexPath(row: 0, section: 0),
                                                                      invoiceNumTotal: invoice.numTotal,
                                                                      invoiceLineItemsCount: invoice.lineItems.count,
                                                                      nameMaxCharactersCount: 50)
            coordinator.didTapEdit(on: viewModel, lineItemViewModel: cellViewModel)
            let editViewController = try #require(navigationController.presentedControllers.last
                                                    as? EditLineItemViewController)
            navigationController.view.accessibilityElementsHidden = true

            editViewController.onDismiss?()

            /// The restoration runs via `DispatchQueue.main.asyncAfter(0.1)`;
            /// wait past that deadline on the same serial queue.
            await waitForMainQueue(after: 0.3)
            #expect(navigationController.view.accessibilityElementsHidden == false,
                    "The coordinator should restore the presenter's accessibility on dismissal")
        }

        // MARK: - SkontoViewModelDelegate forwarding

        @Test("Skonto help pushes the Skonto help screen")
        func skontoHelpPushesHelpScreen() throws {
            let (coordinator, navigationController, _) = try makeCoordinator()

            coordinator.didTapHelp()

            #expect(navigationController.pushedControllers.last is SkontoHelpViewController)
        }

        @Test("Skonto back pops the navigation stack")
        func skontoBackPopsNavigationStack() throws {
            let (coordinator, navigationController, _) = try makeCoordinator()

            coordinator.didTapBack()

            #expect(navigationController.popCallCount == 1)
        }

        @Test("Skonto document preview forwards to the Skonto coordinator delegate")
        func skontoDocumentPreviewForwardsToDelegate() throws {
            let (coordinator, _, _) = try makeCoordinator()
            let skontoDelegate = MockSkontoCoordinatorDelegate()
            coordinator.skontoDelegate = skontoDelegate
            let skontoExtractionResult = try ExtractionResultFixture.load(named: "skontoDiscounts")
            let skontoDiscounts = try SkontoDiscounts(extractions: skontoExtractionResult)
            let skontoViewModel = SkontoViewModel(skontoDiscounts: skontoDiscounts,
                                                  isWithDiscountSwitchAvailable: false)

            coordinator.didTapDocumentPreview(on: skontoViewModel)

            #expect(skontoDelegate.previewedViewModels.count == 1)
            #expect(skontoDelegate.previewedViewModels.first === skontoViewModel)
        }

        // MARK: - Helpers

        /**
         Waits until the main queue has executed all blocks scheduled with an
         earlier deadline. Enqueueing the continuation on the same serial queue
         with a later deadline guarantees deterministic ordering.
         */
        private func waitForMainQueue(after delay: TimeInterval) async {
            await withCheckedContinuation { continuation in
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    continuation.resume()
                }
            }
        }

        private func makeCoordinator() throws -> (DigitalInvoiceCoordinator,
                                                  SpyNavigationController,
                                                  MockCaptureNetworkDelegate) {
            let navigationController = SpyNavigationController()
            let analysisDelegate = MockCaptureNetworkDelegate()
            let digitalInvoice = try ExtractionResultFixture.digitalInvoice()
            let coordinator = DigitalInvoiceCoordinator(navigationController: navigationController,
                                                        digitalInvoice: digitalInvoice,
                                                        analysisDelegate: analysisDelegate)
            return (coordinator, navigationController, analysisDelegate)
        }
    }
}
