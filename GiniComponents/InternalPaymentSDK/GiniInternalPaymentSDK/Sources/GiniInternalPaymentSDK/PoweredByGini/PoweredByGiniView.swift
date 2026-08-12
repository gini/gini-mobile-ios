//
//  PoweredByGiniView.swift
//  GiniInternalPaymentSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniUtilites

public final class PoweredByGiniView: UIView {
    private let viewModel: PoweredByGiniViewModel
    private let mainContainer = AccessibleView()

    private lazy var poweredByGiniLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = viewModel.strings.poweredByGiniText
        label.textColor = viewModel.configuration.poweredByGiniLabelAccentColor
        label.font = viewModel.configuration.poweredByGiniLabelFont
        label.numberOfLines = Constants.textNumberOfLines
        label.adjustsFontSizeToFitWidth = true
        label.isAccessibilityElement = false
        label.textAlignment = .right
        return label
    }()
    
    private lazy var giniImageView: UIImageView = {
        let imageView = UIImageView(image: viewModel.configuration.giniIcon)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.isAccessibilityElement = false
        return imageView
    }()

    /// Constraints active in the default horizontal layout (label leading → image trailing).
    private var horizontalLayoutConstraints: [NSLayoutConstraint] = []
    /// Constraints active in the vertical/accessibility layout (image leading → label trailing).
    private var verticalLayoutConstraints: [NSLayoutConstraint] = []

    public init(viewModel: PoweredByGiniViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
        setupAccessibility()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        mainContainer.addSubview(poweredByGiniLabel)
        mainContainer.addSubview(giniImageView)
        self.addSubview(mainContainer)

        NSLayoutConstraint.activate([
            mainContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainContainer.topAnchor.constraint(equalTo: topAnchor),
            mainContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            giniImageView.centerYAnchor.constraint(equalTo: mainContainer.centerYAnchor),
            giniImageView.widthAnchor.constraint(equalToConstant: Constants.widthGiniLogo),
            giniImageView.heightAnchor.constraint(equalToConstant: Constants.heightGiniLogo),
            // Label top+bottom pins drive mainContainer.height so the scroll view
            // content size is computed correctly at all accessibility font sizes.
            poweredByGiniLabel.topAnchor.constraint(equalTo: mainContainer.topAnchor, constant: Constants.imageTopBottomPadding),
            poweredByGiniLabel.bottomAnchor.constraint(equalTo: mainContainer.bottomAnchor, constant: -Constants.imageTopBottomPadding)
        ])

        horizontalLayoutConstraints = [
            poweredByGiniLabel.leadingAnchor.constraint(equalTo: mainContainer.leadingAnchor),
            giniImageView.leadingAnchor.constraint(equalTo: poweredByGiniLabel.trailingAnchor, constant: Constants.spacingImageText),
            giniImageView.trailingAnchor.constraint(equalTo: mainContainer.trailingAnchor)
        ]

        verticalLayoutConstraints = [
            poweredByGiniLabel.leadingAnchor.constraint(equalTo: mainContainer.leadingAnchor),
            giniImageView.leadingAnchor.constraint(equalTo: poweredByGiniLabel.trailingAnchor, constant: Constants.spacingImageText),
            giniImageView.trailingAnchor.constraint(lessThanOrEqualTo: mainContainer.trailingAnchor)
        ]

        NSLayoutConstraint.activate(horizontalLayoutConstraints)
    }
    
    /**
     UIView does not derive `intrinsicContentSize` from subview constraints. This override
     returns the correct height driven by the label so UIStackView allocates sufficient
     space at all font sizes.
     */
    public override var intrinsicContentSize: CGSize {
        let labelHeight = poweredByGiniLabel.intrinsicContentSize.height
        return CGSize(width: UIView.noIntrinsicMetric,
                      height: max(labelHeight + 2 * Constants.imageTopBottomPadding, Constants.heightGiniLogo))
    }

    private func setupAccessibility() {
        mainContainer.isAccessibilityElement = true
        mainContainer.accessibilityLabel = viewModel.strings.poweredByGiniText + "Gini"
        mainContainer.accessibilityElements = [poweredByGiniLabel, giniImageView]
    }

    /**
     Switches between a compact leading-aligned layout and the default full-width layout.
     When `isVertical` is `true`, the label starts at the leading edge and the logo follows it
     without stretching to the trailing edge. When `false`, the label fills the available width
     and the logo is pinned to the trailing edge.
     */
    func configureForVerticalLayout(_ isVertical: Bool) {
        if isVertical {
            NSLayoutConstraint.deactivate(horizontalLayoutConstraints)
            NSLayoutConstraint.activate(verticalLayoutConstraints)
            poweredByGiniLabel.textAlignment = .natural
        } else {
            NSLayoutConstraint.deactivate(verticalLayoutConstraints)
            NSLayoutConstraint.activate(horizontalLayoutConstraints)
            poweredByGiniLabel.textAlignment = .right
        }
    }
}

extension PoweredByGiniView {
    private enum Constants {
        static let imageTopBottomPadding = 3.0
        static let spacingImageText = 4.0
        static let widthGiniLogo = 28.0
        static let heightGiniLogo = 18.0
        static let textNumberOfLines = 1
    }
}
