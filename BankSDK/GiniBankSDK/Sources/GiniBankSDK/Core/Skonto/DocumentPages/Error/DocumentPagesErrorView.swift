//
//  DocumentPagesErrorView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniCaptureSDK

class DocumentPagesErrorView: UIView {
    private let configuration = GiniBankConfiguration.shared

    lazy var errorHeader: ErrorHeaderView = {
        let header = ErrorHeaderView()
        header.headerLabel.adjustsFontForContentSizeCategory = true
        header.headerLabel.adjustsFontSizeToFitWidth = true
        header.translatesAutoresizingMaskIntoConstraints = false
        return header
    }()

    lazy var button: MultilineTitleButton = {
        let button = MultilineTitleButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(buttonTitle, for: .normal)
        return button
    }()

    lazy var errorContent: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private let buttonTitle: String
    private let buttonAction: (() -> Void)?
    private let errorTitle: String
    private let errorIcon: UIImage?
    private let errorContentText: String

    init(errorTitle: String,
         errorIcon: UIImage?,
         errorContentText: String,
         buttonTitle: String,
         buttonAction: (() -> Void)? = nil) {
        self.buttonTitle = buttonTitle
        self.buttonAction = buttonAction
        self.errorTitle = errorTitle
        self.errorIcon = errorIcon
        self.errorContentText = errorContentText
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        configureErrorHeader()
        configureErrorContent()
        backgroundColor = .GiniCapture.dark2

        addSubview(errorHeader)
        addSubview(scrollView)
        scrollView.addSubview(errorContent)
        addSubview(button)
        configureButton()
        configureConstraints()
    }

    private func configureErrorHeader() {
        errorHeader.headerLabel.text = errorTitle
        errorHeader.headerLabel.font = configuration.textStyleFonts[.subheadline]
        errorHeader.headerLabel.textColor = .GiniCapture.light1
        errorHeader.backgroundColor = .GiniCapture.error1
        errorHeader.iconImageView.image = errorIcon
    }

    private func configureErrorContent() {
        errorContent.text = errorContentText
        errorContent.font = configuration.textStyleFonts[.body]
        errorContent.textColor = .GiniCapture.light6
    }

    private func configureButton() {
        button.titleLabel?.font = configuration.textStyleFonts[.bodyBold]
        button.configure(with: configuration.primaryButtonConfiguration)
        button.addTarget(self, action: #selector(didPressButton), for: .touchUpInside)
    }

    @objc private func didPressButton() {
        buttonAction?()
    }

    private func configureConstraints() {
        configureHeaderConstraints()
        configureScrollViewConstraints()
        configureButtonViewConstraints()
        configureErrorContentConstraints()
    }

    private func configureHeaderConstraints() {
        if UIDevice.current.isIpad {
            NSLayoutConstraint.activate([
                errorHeader.headerStack.widthAnchor.constraint(equalTo: widthAnchor,
                                                               multiplier: Constants.iPadWidthMultiplier),
                errorHeader.headerStack.centerXAnchor.constraint(equalTo: centerXAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                errorHeader.headerStack.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                                 constant: Constants.stackViewLeadingPadding),
                errorHeader.headerStack.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                                  constant: -Constants.sidePadding)
            ])
        }
        errorHeader.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .vertical)
        errorHeader.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        NSLayoutConstraint.activate([
            errorHeader.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            errorHeader.leadingAnchor.constraint(equalTo: leadingAnchor),
            errorHeader.trailingAnchor.constraint(equalTo: trailingAnchor),
            errorHeader.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.errorHeaderMinHeight),
            errorHeader.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor,
                                                multiplier: Constants.errorHeaderHeightMultiplier)
        ])
    }

    private func configureScrollViewConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: errorHeader.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: button.topAnchor)
        ])
    }

    private func configureButtonViewConstraints() {
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.singleButtonHeight),
            button.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -GiniMargins.margin)
        ])
        if UIDevice.current.isIpad {
            NSLayoutConstraint.activate([
                button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: GiniMargins.margin),
                button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -GiniMargins.margin)
            ])
        } else {
            NSLayoutConstraint.activate([
                button.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: GiniMargins.margin),
                button.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -GiniMargins.margin)
            ])
        }
    }

    private func configureErrorContentConstraints() {
        if UIDevice.current.isIpad {
            NSLayoutConstraint.activate([
                errorContent.centerXAnchor.constraint(equalTo: centerXAnchor),
                errorContent.widthAnchor.constraint(equalTo: widthAnchor, multiplier: Constants.iPadWidthMultiplier)
            ])
        } else {
            NSLayoutConstraint.activate([
                errorContent.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.sidePadding),
                errorContent.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                       constant: -Constants.sidePadding)
            ])
        }

        errorContent.setContentHuggingPriority(.required, for: .vertical)
        errorContent.setContentCompressionResistancePriority(.required, for: .vertical)

        NSLayoutConstraint.activate([
            errorContent.topAnchor.constraint(equalTo: scrollView.topAnchor,
                                              constant: Constants.errorContentBottomMargin),
            errorContent.bottomAnchor.constraint(greaterThanOrEqualTo: scrollView.bottomAnchor)
        ])
    }

    private enum Constants {
        static let singleButtonHeight: CGFloat = 50
        static let errorHeaderMinHeight: CGFloat = 62
        static let errorHeaderHeightMultiplier: CGFloat = 0.3
        static let errorContentBottomMargin: CGFloat = 24
        static let stackViewLeadingPadding: CGFloat = 35
        static let sidePadding: CGFloat = 16
        static let iPadWidthMultiplier: CGFloat = 0.7
    }
}
