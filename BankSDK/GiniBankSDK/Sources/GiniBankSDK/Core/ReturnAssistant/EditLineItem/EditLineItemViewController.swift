//
//  EditLineItemViewController.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Combine
import GiniCaptureSDK
import UIKit
import GiniUtilites

final class EditLineItemViewController: GiniBottomSheetViewController {

    // MARK: - Views

    private let scrollView = EmptyScrollView()
    private let contentView = EmptyView()

    private lazy var editLineItemView: EditLineItemView = {
        let view = EditLineItemView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Properties

    private var cancellables = Set<AnyCancellable>()
    private weak var activeTextField: UITextField?

    private var portraitConstraints: [NSLayoutConstraint] = []
    private var landscapeConstraints: [NSLayoutConstraint] = []

    // MARK: - GiniBottomSheetPresentable

    var shouldShowDragIndicator: Bool { false }
    var shouldShowInFullScreenInLandscapeMode: Bool { true }

    /// Called when the bottom sheet is dismissed (by any means)
    var onDismiss: (() -> Void)?

    // MARK: - Initialization

    init(lineItemViewModel: EditLineItemViewModel) {
        super.init(nibName: nil, bundle: nil)
        editLineItemView.viewModel = lineItemViewModel
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupScrollView()
        setupContent()
        setupInitialLayout()
        setupAccessibility()
        configureBottomSheet(shouldIncludeLargeDetent: true)
        bindToSizeUpdates()
        GiniAnalyticsManager.trackScreenShown(screenName: .editReturnAssistant)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        notifyAccessibilityLayoutChanged()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cancellables.removeAll()
        // Notify that the bottom sheet was dismissed
        onDismiss?()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate { [weak self] _ in
            guard let self else { return }

            if UIDevice.isPortrait() {
                self.setupPortraitConstraints()
            } else {
                self.setupLandscapeConstraints()
            }

            self.view.endEditing(true)
            self.view.layoutIfNeeded()
        } completion: { [weak self] _ in
            self?.activeTextField?.becomeFirstResponder()
        }
    }

    // MARK: - Setup

    private func setupView() {
        view.backgroundColor = GiniColor(light: .GiniBank.light1, dark: .GiniBank.dark1).uiColor()
    }

    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.giniMakeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func setupContent() {
        scrollView.addContentSubview(contentView)

        contentView.giniMakeConstraints {
            $0.edges.equalToSuperview()
        }

        contentView.addSubview(editLineItemView)
        editLineItemView.giniMakeConstraints {
            $0.vertical.equalTo(contentView)
        }
    }

    // MARK: - Accessibility
    private func setupAccessibility() {
        // Allow scrollView to pass through accessibility
        scrollView.isAccessibilityElement = false
        scrollView.shouldGroupAccessibilityChildren = false

        // Allow contentView to pass through accessibility
        contentView.isAccessibilityElement = false
        contentView.shouldGroupAccessibilityChildren = false

        // EditLineItemView contains the actual accessible elements
        editLineItemView.isAccessibilityElement = false
        editLineItemView.shouldGroupAccessibilityChildren = false
    }

    private func notifyAccessibilityLayoutChanged() {
        /// This is to notify VoiceOver that the layout changed. The delay is needed to ensure that
        /// VoiceOver has already finished processing the UI changes.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self else { return }
            UIAccessibility.post(notification: .layoutChanged,
                                 argument: self.editLineItemView)
        }
    }

    // MARK: - Orientation Layout

    private func setupInitialLayout() {
        if UIDevice.isPortrait() {
            setupPortraitConstraints()
        } else {
            setupLandscapeConstraints()
        }
    }

    private func setupPortraitConstraints() {
        deactivateAllConstraints()
        portraitConstraints = editLineItemView.giniUpdateConstraints {
            $0.leading.equalTo(contentView).constant(Constants.portraitPadding)
            $0.trailing.equalTo(contentView).constant(-Constants.portraitPadding)
        }
    }

    private func setupLandscapeConstraints() {
        deactivateAllConstraints()
        landscapeConstraints = editLineItemView.giniUpdateConstraints {
            $0.leading.equalTo(contentView).constant(Constants.landscapePadding)
            $0.trailing.equalTo(contentView).constant(-Constants.landscapePadding)
        }
    }

    private func deactivateAllConstraints() {
        NSLayoutConstraint.deactivate(portraitConstraints + landscapeConstraints)
    }

    // MARK: - Size Binding

    private func bindToSizeUpdates() {
        scrollView.$size
            .receive(on: DispatchQueue.main)
            .sink { [weak self] size in
                guard let self, size.height > 0 else { return }
                let maxHeight = UIScreen.main.bounds.height - Constants.topSafeAreaInset
                self.updateBottomSheetHeight(min(size.height, maxHeight))
            }
            .store(in: &cancellables)
    }
}

// MARK: - Constants

private extension EditLineItemViewController {
    enum Constants {
        static let portraitPadding: CGFloat = 0
        static let landscapePadding: CGFloat = 32
        static let topSafeAreaInset: CGFloat = 64
    }
}
