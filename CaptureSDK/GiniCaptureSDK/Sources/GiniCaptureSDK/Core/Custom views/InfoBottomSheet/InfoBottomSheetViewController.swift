//
//  InfoBottomSheetViewController.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//
import UIKit
import Combine

public class InfoBottomSheetViewController: GiniBottomSheetViewController {
    private let viewModel: InfoBottomSheetViewModel
    private let buttonsViewModel: InfoBottomSheetButtonsViewModel

    private lazy var configuration = GiniConfiguration.shared

    private let contentScrollView = GiniScrollViewContainer()
    private var cancellables = Set<AnyCancellable>()

    private let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Constants.contentStackViewSpacing
        return stack
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
        stack.spacing = 12
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

    // MARK: - Buttons Container
    lazy var buttonsViewContainer: ButtonsView = {
        let view = ButtonsView(secondaryButtonTitle: buttonsViewModel.secondaryTitle ?? "",
                               primaryButtonTitle: buttonsViewModel.primaryTitle ?? "")
        view.secondaryButton.isHidden = buttonsViewModel.secondaryTitle == nil
        view.primaryButton.isHidden = buttonsViewModel.primaryTitle == nil

        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    public var shouldShowDragIndicator: Bool {
        false
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
        setupView()
        setupConstraints()
    }

    public override func viewWillTransition(to size: CGSize,
                                            with coordinator: any UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.updateViewOrientation()
        })
    }

    // MARK: - Setup UI

    private func setupView() {

        // TODO: add a bit of explanation here
        configureBottomSheet(shouldIncludeLargeDetent: GiniAccessibility.isFontSizeAtLeastAccessibilityMedium)
        view.backgroundColor = GiniColor(light: .GiniCapture.light1,
                                         dark: .GiniCapture.dark3).uiColor()

        iconImageView.image = viewModel.image
        iconImageView.tintColor = viewModel.imageTintColor
        headerLabel.text = viewModel.title
        descriptionLabel.text = viewModel.description

        view.addSubview(contentScrollView)
        view.addSubview(buttonsViewContainer)

        contentScrollView.addSubview(contentStackView)

        contentStackView.addArrangedSubview(imageContainer)
        contentStackView.addArrangedSubview(textContentStackView)

        imageContainer.addSubview(imageRoundContainer)
        imageRoundContainer.addSubview(iconImageView)
        textContentStackView.addArrangedSubview(headerLabel)
        textContentStackView.addArrangedSubview(descriptionLabel)

    }

    private func updateViewOrientation() {
        configureBottomSheet(shouldIncludeLargeDetent: GiniAccessibility.isFontSizeAtLeastAccessibilityMedium)
    }

    // MARK: - Setup Constraints

    private func setupConstraints() {
        contentScrollView.giniMakeConstraints {
            $0.top.equalTo(view.safeTop).constant(Constants.contentScrollViewTopPadding)
            $0.horizontal.equalToSuperview().constant(Constants.contentStackViewHorizontalPadding)
        }

        buttonsViewContainer.giniMakeConstraints {
            $0.top.equalTo(contentScrollView.bottom + Constants.contentStackViewTopPadding)
            $0.leading.equalToSuperview().constant(Constants.contentStackViewHorizontalPadding)
            $0.trailing.equalToSuperview().constant(-Constants.contentStackViewHorizontalPadding)
            $0.bottom.equalTo(view.safeBottom).constant(-Constants.contentStackViewBottomPadding)
        }
        imageRoundContainer.giniMakeConstraints {
            $0.vertical.equalToSuperview()
            $0.size.equalTo(Constants.imageContainerSize)
            $0.centerX.equalToSuperview()
        }

        contentStackView.giniMakeConstraints {
            $0.edges.equalToSuperview()
        }

        iconImageView.giniMakeConstraints {
            $0.size.equalTo(Constants.iconSize)
            $0.center.equalToSuperview()
        }
    }

    private func configureButtons() {
        buttonsViewContainer.secondaryButton.addTarget(self,
                                                       action: #selector(buttonsViewModel.didPressSecondary),
                                                       for: .touchUpInside)
        buttonsViewContainer.primaryButton.addTarget(self,
                                                     action: #selector(buttonsViewModel.didPressPrimary),
                                                     for: .touchUpInside)
    }
}
extension InfoBottomSheetViewController {
    // MARK: - Constants
    private struct Constants {
        static let contentScrollViewTopPadding: CGFloat = 40
        static let contentStackViewSpacing: CGFloat = 40
        static let iconSize: CGFloat = 24
        static let safeLeadingPadding: CGFloat = 35
        static let contentStackViewTopPadding: CGFloat = 40
        static let contentStackViewBottomPadding: CGFloat = 19
        static let contentStackViewHorizontalPadding: CGFloat = 24
        static let buttonSpacing: CGFloat = 12
        static let imageContainerSize: CGFloat = 40
        static let imageViewPadding: CGFloat = 8
    }
}
