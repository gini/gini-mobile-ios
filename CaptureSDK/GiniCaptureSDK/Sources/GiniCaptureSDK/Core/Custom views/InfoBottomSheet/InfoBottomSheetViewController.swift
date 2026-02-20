//
//  InfoBottomSheetViewController.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//
import UIKit

/**
 A bottom sheet view controller that displays informational content with an icon, title, description, and action buttons.

 This view controller extends `GiniBottomSheetViewController` to provide a standardized way to present
 informational dialogs with customizable content and actions. The class conforms to `GiniBottomSheetPresentable`,
 which is a convenience typealias combining `UIViewController` with `GiniBottomSheetPresentable` protocol,
 allowing any conforming controller to present itself as a configurable bottom sheet.
*/
public class InfoBottomSheetViewController: GiniBottomSheetViewController {
    private let viewModel: InfoBottomSheetViewModel
    private let buttonsViewModel: InfoBottomSheetButtonsViewModel

    private lazy var configuration = GiniConfiguration.shared

    private let contentScrollView = GiniScrollViewContainer()

    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Constants.contentStackViewSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let imageContainer = UIView()

    private let imageRoundContainer: UIView = {
        let imageContainerView = UIView()
        imageContainerView.backgroundColor = GiniColor(light: .GiniCapture.warning5,
                                                       dark: .GiniCapture.warning5).uiColor()
        imageContainerView.round(radius: Constants.imageContainerSize / 2)
        return imageContainerView
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.adjustsImageSizeForAccessibilityContentSizeCategory = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let textContentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Constants.textContentStackViewSpacing
        return stack
    }()

    private let headerLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = GiniConfiguration.shared.textStyleFonts[.title2]
        label.textColor = GiniColor(light: .GiniCapture.dark1,
                                    dark: .GiniCapture.light1).uiColor()
        label.adjustsFontForContentSizeCategory = true
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = GiniConfiguration.shared.textStyleFonts[.body]
        label.textColor = GiniColor(light: .GiniCapture.dark6,
                                    dark: .GiniCapture.dark7).uiColor()
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var buttonsViewContainer: ButtonsView = {
        let view = ButtonsView(secondaryButtonTitle: buttonsViewModel.secondaryTitle ?? "",
                               primaryButtonTitle: buttonsViewModel.primaryTitle ?? "")
        view.secondaryButton.isHidden = buttonsViewModel.secondaryTitle == nil
        view.primaryButton.isHidden = buttonsViewModel.primaryTitle == nil

        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    // MARK: GiniBottomSheetPresentable protocol
    public var shouldShowDragIndicator: Bool {
        false
    }

    public var shouldShowInFullScreenInLandscapeMode: Bool {
        true
    }

    // MARK: - View Lifecycle

    init(viewModel: InfoBottomSheetViewModel,
         buttonsViewModel: InfoBottomSheetButtonsViewModel) {
        self.viewModel = viewModel
        self.buttonsViewModel = buttonsViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if UIDevice.current.isIpad && !GiniAccessibility.isFontSizeAtLeastAccessibilityMedium {
            updateBottomSheetHeight(to: Constants.bottomSheetHeightIPad)
        }
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureAccessibility()

        // Notify VoiceOver that screen changed and set focus
        UIAccessibility.post(notification: .screenChanged, argument: iconImageView)
    }

    public override func loadView() {
        super.loadView()

        setupView()
        adjustPhoneLayoutForCurrentOrientation()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // On devices without a notch (i.e., no safe area insets at the top),
        // viewSafeAreaInsetsDidChange() is not called on first appearance.
        // So we manually trigger the layout adjustment here as a fallback.
        if !UIDevice.current.hasNotch {
            adjustPhoneLayoutForCurrentOrientation()
        }
    }

    // This is reliably called on devices that do have a notch
    // (i.e., have safe area insets)
    public override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        adjustPhoneLayoutForCurrentOrientation()
    }

    public override func viewWillTransition(to size: CGSize,
                                            with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        // Called only during device orientation changes (e.g., portrait ↔ landscape),
        // and allows animating layout updates alongside the rotation.

        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.adjustPhoneLayoutForCurrentOrientation()
        })
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        // Called when any UI trait changes (e.g., orientation, size class, text size, dark mode)
        // not necessarily tied to device rotation. Use this for general layout updates.
        // when the font size changes >= .accessibilityMedium, we need to update the bottom sheet to be full screen
        configureBottomSheet(shouldIncludeLargeDetent: shouldForceFullScreen)
        adjustPhoneLayoutForCurrentOrientation()
        configureAccessibility()
    }

    // MARK: - Setup UI
    private var shouldForceFullScreen: Bool {
        // always full screen for accessibility font size both for iPad and iPhone
        if GiniAccessibility.isFontSizeAtLeastAccessibilityMedium {
            return true
        }

        // Force full screen on devices without notch or with small screens
        guard UIDevice.current.isNonNotchSmallScreen() else { return false }

        return true
    }

    private func setupView() {
        // this is needed to ensure that the bottom sheet is displayed full screen when the font size is at least accessibility medium.
        configureBottomSheet(shouldIncludeLargeDetent: shouldForceFullScreen)
        view.backgroundColor = GiniColor(light: .GiniCapture.light1,
                                         dark: .GiniCapture.dark3).uiColor()

        iconImageView.image = viewModel.image
        iconImageView.tintColor = viewModel.imageTintColor
        headerLabel.text = viewModel.title
        descriptionLabel.text = viewModel.description

        view.addSubview(contentScrollView)
        view.addSubview(buttonsViewContainer)

        contentScrollView.addContentSubview(contentStackView)

        contentStackView.addArrangedSubview(imageContainer)
        contentStackView.addArrangedSubview(textContentStackView)

        imageContainer.addSubview(imageRoundContainer)
        imageRoundContainer.addSubview(iconImageView)
        textContentStackView.addArrangedSubview(headerLabel)
        textContentStackView.addArrangedSubview(descriptionLabel)

        configureButtons()
    }

    private func adjustPhoneLayoutForCurrentOrientation() {
        guard UIDevice.current.isIphone else { return }
        let isLandscape = UIDevice.current.isLandscape
        let hasNotch = UIDevice.current.hasNotch
        imageContainer.isHidden = isLandscape

        if isLandscape {
            contentScrollViewTopConstraint?.constant = hasNotch
            ? Constants.contentScrollViewLandscapeTopPadding.withNotch
            : Constants.contentScrollViewLandscapeTopPadding.withoutNotch

            let contentScrollViewHorizontalPadding = hasNotch
            ? Constants.contentScrollViewLandscapeHorizontalPadding.withNotch
            : Constants.contentScrollViewLandscapeHorizontalPadding.withoutNotch

            contentScrollViewLeadingConstraint?.constant = contentScrollViewHorizontalPadding
            contentScrollViewTrailingConstraint?.constant = -contentScrollViewHorizontalPadding

            let buttonsViewContainerHorizontalPadding = hasNotch
            ? Constants.buttonsViewContainerLandscapeHorizontalPadding.withNotch
            : Constants.buttonsViewContainerLandscapeHorizontalPadding.withoutNotch

            buttonsViewContainerLeadingConstraint?.constant = buttonsViewContainerHorizontalPadding
            buttonsViewContainerTrailingConstraint?.constant = -buttonsViewContainerHorizontalPadding
        } else {
            contentScrollViewTopConstraint?.constant = Constants.contentScrollViewTopPaddingPortrait
            contentScrollViewLeadingConstraint?.constant = Constants.contentScrollViewHorizontalPaddingPortrait
            contentScrollViewTrailingConstraint?.constant = -Constants.contentScrollViewHorizontalPaddingPortrait

            buttonsViewContainerLeadingConstraint?.constant = Constants.buttonsViewContainerHorizontalPaddingPortrait
            buttonsViewContainerTrailingConstraint?.constant = -Constants.buttonsViewContainerHorizontalPaddingPortrait
        }

        view.layoutIfNeeded()
    }

    // MARK: - Setup Constraints
    private var contentScrollViewTopConstraint: NSLayoutConstraint?
    private var contentScrollViewLeadingConstraint: NSLayoutConstraint?
    private var contentScrollViewTrailingConstraint: NSLayoutConstraint?
    private var buttonsViewContainerLeadingConstraint: NSLayoutConstraint?
    private var buttonsViewContainerTrailingConstraint: NSLayoutConstraint?

    private func setupConstraints() {
        let contentScrollViewConstraints = contentScrollView.giniMakeConstraints {
            $0.top.equalTo(view.safeTop).constant(Constants.contentScrollViewTopPaddingPortrait)
            $0.horizontal.equalToSuperview().constant(Constants.contentScrollViewHorizontalPaddingPortrait)
            // HARD limit: spacing must be ≤ 40
            $0.bottom.greaterThanOrEqualTo(buttonsViewContainer.top)
                .constant(-Constants.buttonContainerViewTopPadding.max)
                .priority(.required)

            // PREFERENCE: spacing = 20 (can be relaxed if needed)
            $0.bottom.equalTo(buttonsViewContainer.top)
                .constant(-Constants.buttonContainerViewTopPadding.min)
                .priority(.defaultHigh) // 750
        }

        contentScrollViewTopConstraint = contentScrollViewConstraints.first { $0.firstAttribute == .top }
        contentScrollViewLeadingConstraint = contentScrollViewConstraints.first { $0.firstAttribute == .leading }
        contentScrollViewTrailingConstraint = contentScrollViewConstraints.first { $0.firstAttribute == .trailing }

        let buttonsViewContainerConstraints = buttonsViewContainer.giniMakeConstraints {
            $0.horizontal.equalToSuperview().constant(Constants.buttonsViewContainerHorizontalPaddingPortrait)
            $0.bottom.equalTo(view.safeBottom).constant(-Constants.contentStackViewBottomPadding)
        }

        buttonsViewContainer.setContentHuggingPriority(.required, for: .vertical)
        buttonsViewContainer.setContentCompressionResistancePriority(.required, for: .vertical)

        buttonsViewContainerLeadingConstraint = buttonsViewContainerConstraints.first {
            $0.firstAttribute == .leading
        }
        buttonsViewContainerTrailingConstraint = buttonsViewContainerConstraints.first {
            $0.firstAttribute == .trailing
        }

        contentStackView.giniMakeConstraints {
            $0.edges.equalToSuperview()
        }

        imageRoundContainer.giniMakeConstraints {
            $0.vertical.equalToSuperview()
            $0.size.equalTo(Constants.imageContainerSize)
            $0.centerX.equalToSuperview()
        }

        iconImageView.giniMakeConstraints {
            $0.size.equalTo(Constants.iconSize)
            $0.center.equalToSuperview()
        }
    }

    private func configureButtons() {
        buttonsViewContainer.secondaryButton.addTarget(self,
                                                       action: #selector(didPressSecondary),
                                                       for: .touchUpInside)
        buttonsViewContainer.primaryButton.addTarget(self,
                                                     action: #selector(didPressPrimary),
                                                     for: .touchUpInside)
    }

    @objc func didPressSecondary() {
       buttonsViewModel.didPressSecondary()
    }

    @objc func didPressPrimary() {
        buttonsViewModel.didPressPrimary()
    }

    private func configureAccessibility() {
        view.isAccessibilityElement = false
        view.shouldGroupAccessibilityChildren = true

        // Configure icon
        iconImageView.isAccessibilityElement = true
        iconImageView.accessibilityLabel = viewModel.title
        iconImageView.accessibilityTraits = .image

        // Configure header
        headerLabel.isAccessibilityElement = true
        headerLabel.accessibilityTraits = .header

        // Configure description
        descriptionLabel.isAccessibilityElement = true
        descriptionLabel.accessibilityTraits = .staticText

        let isIphoneAndLandscape = UIDevice.current.isIphoneAndLandscape
        // Set explicit VoiceOver navigation order
        var elements: [Any] = isIphoneAndLandscape ? [] : [iconImageView]
        elements += [
            headerLabel,
            descriptionLabel,
            buttonsViewContainer.primaryButton,
            buttonsViewContainer.secondaryButton
        ]
        view.accessibilityElements = elements.compactMap { $0 }
    }
}
extension InfoBottomSheetViewController {
    // MARK: - Constants
    typealias NotchConditionalPadding = (withNotch: CGFloat, withoutNotch: CGFloat)
    typealias MinMaxPadding = (min: CGFloat, max: CGFloat)
    private struct Constants {
        static let textContentStackViewSpacing: CGFloat = 12
        static let contentScrollViewTopPaddingPortrait: CGFloat = 40
        static let contentScrollViewHorizontalPaddingPortrait: CGFloat = 24
        static let contentScrollViewLandscapeTopPadding: NotchConditionalPadding = (108, 81)
        static let contentScrollViewLandscapeHorizontalPadding: NotchConditionalPadding = (186, 61)

        static let contentStackViewSpacing: CGFloat = 40
        static let contentStackViewBottomPadding: CGFloat = 19

        static let buttonsViewContainerHorizontalPaddingPortrait: CGFloat = 24
        static let buttonContainerViewTopPadding: MinMaxPadding = (20, 40)
        static let buttonsViewContainerLandscapeHorizontalPadding: NotchConditionalPadding = (56, 16)

        static let iconSize: CGFloat = 24
        static let imageContainerSize: CGFloat = 40

        static let bottomSheetHeightIPad: CGFloat = 439
        static let smallScreenMaxHeight: CGFloat = 736
    }
}
