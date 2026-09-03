//
//  InfoBottomSheetViewControllerTests.swift
//  GiniCaptureSDK
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import UIKit
@testable import GiniCaptureSDK

// MARK: - Mock

private struct MockInfoBottomSheetViewModel: InfoBottomSheetViewModel {
    var image: UIImage? = UIImage(systemName: "info.circle")
    var imageTintColor: UIColor? = .systemRed
    var title: String = "Mock bottom sheet title"
    var description: String = "Mock bottom sheet description"
    var imageBackgroundColor: UIColor? = .systemYellow
}

// MARK: - Suite

@Suite("InfoBottomSheetViewController")
struct InfoBottomSheetViewControllerTests {

    private typealias Helper = ViewHierarchyTestHelper

    @MainActor
    private func makeSUT(viewModel: InfoBottomSheetViewModel = MockInfoBottomSheetViewModel(),
                         buttonsViewModel: InfoBottomSheetButtonsViewModel,
                         buttonOrder: [ButtonsView.ButtonType] = [.primary, .secondary]) -> InfoBottomSheetViewController {
        let sut = InfoBottomSheetViewController(viewModel: viewModel,
                                                buttonsViewModel: buttonsViewModel,
                                                buttonOrder: buttonOrder)
        sut.loadViewIfNeeded()
        return sut
    }

    @MainActor
    private func makeButtonsViewModel(onPrimary: @escaping () -> Void = {},
                                      onSecondary: @escaping () -> Void = {}) -> InfoBottomSheetButtonsViewModel {
        InfoBottomSheetButtonsViewModel(.init(title: "Primary action", action: onPrimary),
                                        .init(title: "Secondary action", action: onSecondary))
    }

    // MARK: - Content

    @Test("Title and description labels are populated from the view model")
    @MainActor func labelsPopulatedFromViewModel() throws {
        let viewModel = MockInfoBottomSheetViewModel()
        let sut = makeSUT(viewModel: viewModel, buttonsViewModel: makeButtonsViewModel())

        let titleLabel = try #require(Helper.firstLabel(withText: viewModel.title, in: sut.view),
                                      "Title label should show the view model title")
        let descriptionLabel = try #require(Helper.firstLabel(withText: viewModel.description, in: sut.view),
                                            "Description label should show the view model description")
        #expect(titleLabel.numberOfLines == 0)
        #expect(descriptionLabel.numberOfLines == 0)
    }

    @Test("Icon image view is populated from the view model")
    @MainActor func iconPopulatedFromViewModel() throws {
        let viewModel = MockInfoBottomSheetViewModel()
        let sut = makeSUT(viewModel: viewModel, buttonsViewModel: makeButtonsViewModel())

        let imageView = try #require(Helper.firstView(ofType: UIImageView.self, in: sut.view))
        #expect(imageView.image == viewModel.image)
        #expect(Helper.colorsEqual(imageView.tintColor, viewModel.imageTintColor))
        #expect(Helper.colorsEqual(imageView.superview?.backgroundColor, viewModel.imageBackgroundColor))
    }

    // MARK: - Buttons

    @Test("Button titles come from the buttons view model")
    @MainActor func buttonTitlesComeFromButtonsViewModel() {
        let sut = makeSUT(buttonsViewModel: makeButtonsViewModel())

        #expect(sut.buttonsViewContainer.primaryButton.title(for: .normal) == "Primary action")
        #expect(sut.buttonsViewContainer.secondaryButton.title(for: .normal) == "Secondary action")
        #expect(!sut.buttonsViewContainer.primaryButton.isHidden)
        #expect(!sut.buttonsViewContainer.secondaryButton.isHidden)
    }

    @Test("Buttons without a title are hidden")
    @MainActor func buttonsWithoutTitleAreHidden() {
        let buttonsViewModel = InfoBottomSheetButtonsViewModel(.init(title: "Primary only", action: {}), nil)
        let sut = makeSUT(buttonsViewModel: buttonsViewModel)

        #expect(!sut.buttonsViewContainer.primaryButton.isHidden)
        #expect(sut.buttonsViewContainer.secondaryButton.isHidden)
    }

    @Test("Button order is forwarded to the buttons container",
          arguments: [[ButtonsView.ButtonType.primary, .secondary],
                      [ButtonsView.ButtonType.secondary, .primary]])
    @MainActor func buttonOrderIsForwarded(order: [ButtonsView.ButtonType]) throws {
        let sut = makeSUT(buttonsViewModel: makeButtonsViewModel(), buttonOrder: order)

        let stack = try #require(Helper.firstView(ofType: UIStackView.self,
                                                  in: sut.buttonsViewContainer))
        let expectedButtons: [UIButton] = order.map {
            $0 == .primary ? sut.buttonsViewContainer.primaryButton : sut.buttonsViewContainer.secondaryButton
        }
        for (arranged, expected) in zip(stack.arrangedSubviews, expectedButtons) {
            #expect(arranged === expected)
        }
    }

    @Test("Tapping the primary button invokes the primary action")
    @MainActor func primaryButtonTapInvokesPrimaryAction() {
        var primaryCallCount = 0
        let sut = makeSUT(buttonsViewModel: makeButtonsViewModel(onPrimary: { primaryCallCount += 1 }))

        Helper.tap(sut.buttonsViewContainer.primaryButton)

        #expect(primaryCallCount == 1)
    }

    @Test("Tapping the secondary button invokes the secondary action")
    @MainActor func secondaryButtonTapInvokesSecondaryAction() {
        var secondaryCallCount = 0
        let sut = makeSUT(buttonsViewModel: makeButtonsViewModel(onSecondary: { secondaryCallCount += 1 }))

        Helper.tap(sut.buttonsViewContainer.secondaryButton)

        #expect(secondaryCallCount == 1)
    }

    @Test("didPress methods forward to the buttons view model")
    @MainActor func didPressForwardsToButtonsViewModel() {
        var primaryCallCount = 0
        var secondaryCallCount = 0
        let sut = makeSUT(buttonsViewModel: makeButtonsViewModel(onPrimary: { primaryCallCount += 1 },
                                                                 onSecondary: { secondaryCallCount += 1 }))

        sut.didPressPrimary()
        sut.didPressSecondary()

        #expect(primaryCallCount == 1)
        #expect(secondaryCallCount == 1)
    }

    // MARK: - Bottom sheet configuration

    @Test("Bottom sheet hides the drag indicator and fills the screen in landscape")
    @MainActor func bottomSheetPresentationFlags() {
        let sut = makeSUT(buttonsViewModel: makeButtonsViewModel())

        #expect(sut.shouldShowDragIndicator == false)
        #expect(sut.shouldShowInFullScreenInLandscapeMode == true)
        #expect(sut.modalPresentationStyle == .pageSheet)
    }

    // MARK: - Accessibility

    @Test("Accessibility elements are ordered icon, title, description, then buttons")
    @MainActor func accessibilityElementsOrder() throws {
        let viewModel = MockInfoBottomSheetViewModel()
        let sut = makeSUT(viewModel: viewModel, buttonsViewModel: makeButtonsViewModel())

        sut.viewDidAppear(false)

        let elements = try #require(sut.view.accessibilityElements)
        let isIphoneAndLandscape = UIDevice.current.isIphoneAndLandscape
        let expectedCount = isIphoneAndLandscape ? 4 : 5
        #expect(elements.count == expectedCount)

        if !isIphoneAndLandscape {
            let icon = try #require(elements.first as? UIImageView,
                                    "First accessibility element should be the icon in portrait")
            #expect(icon.accessibilityLabel == viewModel.title)
            #expect(icon.accessibilityTraits.contains(.image))
        }

        let labels = elements.compactMap { $0 as? UILabel }
        #expect(labels.map { $0.text } == [viewModel.title, viewModel.description])
        #expect(labels.first?.accessibilityTraits.contains(.header) == true)

        let buttons = elements.compactMap { $0 as? UIButton }
        #expect(buttons.first === sut.buttonsViewContainer.primaryButton)
        #expect(buttons.last === sut.buttonsViewContainer.secondaryButton)
    }

    @Test("Reversed button order is reflected in the accessibility elements")
    @MainActor func accessibilityElementsRespectReversedButtonOrder() throws {
        let sut = makeSUT(buttonsViewModel: makeButtonsViewModel(),
                          buttonOrder: [.secondary, .primary])

        sut.viewDidAppear(false)

        let elements = try #require(sut.view.accessibilityElements)
        let buttons = elements.compactMap { $0 as? UIButton }
        #expect(buttons.first === sut.buttonsViewContainer.secondaryButton)
        #expect(buttons.last === sut.buttonsViewContainer.primaryButton)
    }

    // MARK: - Lifecycle

    @Test("Lifecycle callbacks re-apply layout without side effects")
    @MainActor func lifecycleCallbacksAreSafe() {
        let sut = makeSUT(buttonsViewModel: makeButtonsViewModel())

        /// Exercise the lifecycle overrides that adjust layout and accessibility.
        sut.viewWillAppear(false)
        sut.viewSafeAreaInsetsDidChange()
        sut.viewDidLayoutSubviews()
        sut.traitCollectionDidChange(nil)

        #expect(sut.view.shouldGroupAccessibilityChildren)
        #expect(!sut.view.isAccessibilityElement)
    }
}
