//
//  QRCodeOverlay.swift
//  
//
//  Created by David Vizaknai on 01.11.2022.
//

import UIKit

final class CorrectQRCodeTextContainer: UIView {
    private let configuration = GiniConfiguration.shared

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = configuration.textStyleFonts[.caption2]
        label.textAlignment = .center
        label.textColor = .GiniCapture.light1
        label.text = NSLocalizedStringPreferredFormat("ginicapture.QRscanning.correct",
                                                      comment: "QR Detected")
        label.enableScaling()
        return label
    }()

    init() {
        super.init(frame: .zero)
        backgroundColor = .GiniCapture.success2
        addSubview(titleLabel)
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.spacing / 2),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.spacing)
        ])
    }
}

final class IncorrectQRCodeTextContainer: UIView {
    private let configuration = GiniConfiguration.shared

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = configuration.textStyleFonts[.footnoteBold]
        label.textColor = .GiniCapture.dark1
        label.text = NSLocalizedStringPreferredFormat("ginicapture.QRscanning.incorrect.title",
                                                      comment: "Unknown QR")
        label.enableScaling()
        label.numberOfLines = 0
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = configuration.textStyleFonts[.footnote]
        label.textColor = .GiniCapture.dark1
        label.numberOfLines = 0
        label.text = NSLocalizedStringPreferredFormat("ginicapture.QRscanning.incorrect.description",
                                                      comment: "No content")
        label.enableScaling()
        return label
    }()

    private lazy var textStackView: UIStackView = {
        let textStackView = UIStackView()
        configureTextStackView(textStackView)
        return textStackView
    }()

    private func configureTextStackView(_ stackView: UIStackView) {
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = Constants.spacing
        stackView.backgroundColor = .GiniCapture.warning3
        stackView.layer.cornerRadius = Constants.cornerRadius
        stackView.translatesAutoresizingMaskIntoConstraints = false

        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = Constants.stackViewMargins
    }

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    init() {
        super.init(frame: .zero)

        backgroundColor = .clear
        addSubview(scrollView)
        scrollView.addSubview(textStackView)
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(descriptionLabel)
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            // textStackView inside scrollView
            textStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            textStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            textStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            textStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            textStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
}

final class QRCodeOverlay: UIView {
    private let configuration = GiniConfiguration.shared

    private lazy var correctQRFeedback: CorrectQRCodeTextContainer = {
        let view = CorrectQRCodeTextContainer()
        view.layer.cornerRadius = Constants.spacing
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    private lazy var incorrectQRFeedback: IncorrectQRCodeTextContainer = {
        let view = IncorrectQRCodeTextContainer()
        view.layer.cornerRadius = Constants.spacing
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    private lazy var checkMarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImageNamedPreferred(named: "greenCheckMark")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }()

    private lazy var loadingIndicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView()
        indicatorView.hidesWhenStopped = true
        indicatorView.style = .large
        return indicatorView
    }()

    private lazy var loadingIndicatorText: UILabel = {
        var loadingIndicatorText = UILabel()
        loadingIndicatorText.font = configuration.textStyleFonts[.bodyBold]
        loadingIndicatorText.textAlignment = .center
        loadingIndicatorText.adjustsFontForContentSizeCategory = true
        loadingIndicatorText.textColor = .GiniCapture.light1
        loadingIndicatorText.isAccessibilityElement = true
        loadingIndicatorText.numberOfLines = 0
        loadingIndicatorText.text = NSLocalizedStringPreferredFormat("ginicapture.QRscanning.loading",
                                                                     comment: "Retrievenig invoice")
        return loadingIndicatorText
    }()

    private lazy var loadingContainer: UIStackView = {
        let textStackView = UIStackView()
        textStackView.axis = .vertical
        textStackView.distribution = .fillProportionally
        textStackView.spacing = Constants.expandedSpacing
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        textStackView.isHidden = true
        return textStackView
    }()

    init() {
        super.init(frame: .zero)
        addSubview(correctQRFeedback)
        addSubview(checkMarkImageView)
        addSubview(incorrectQRFeedback)

        addLoadingView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addLoadingView() {
        let loadingIndicator: UIView

        if let customLoadingIndicator = configuration.customLoadingIndicator?.injectedView() {
            loadingIndicator = customLoadingIndicator
        } else {
            loadingIndicator = loadingIndicatorView
        }

        addSubview(loadingContainer)
        loadingContainer.addArrangedSubview(loadingIndicator)
        loadingContainer.addArrangedSubview(loadingIndicatorText)
    }

    func layoutViews(centeringBy cameraFrame: UIView, on viewController: UIViewController) {
        layoutCorrectQRCode(centeringBy: cameraFrame, on: viewController)
        layoutIncorrectQRCode(centeringBy: cameraFrame)
        layoutLoadingIndicator(centeringBy: cameraFrame)
    }

    private func layoutCorrectQRCode(centeringBy cameraFrame: UIView, on viewController: UIViewController) {
        let correctQRCenterYAnchor = correctQRFeedback.centerYAnchor.constraint(equalTo: cameraFrame.topAnchor)
        correctQRCenterYAnchor.priority = .defaultLow

        NSLayoutConstraint.activate([
            correctQRFeedback.centerXAnchor.constraint(equalTo: cameraFrame.centerXAnchor),
            correctQRCenterYAnchor,
            correctQRFeedback.topAnchor.constraint(greaterThanOrEqualTo: viewController.view.topAnchor,
                                                   constant: Constants.topSpacing),
            correctQRFeedback.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor,
                                                       constant: Constants.expandedSpacing),

            checkMarkImageView.centerXAnchor.constraint(equalTo: cameraFrame.centerXAnchor),
            checkMarkImageView.centerYAnchor.constraint(equalTo: cameraFrame.centerYAnchor),
            checkMarkImageView.heightAnchor.constraint(equalToConstant: Constants.iconSize.height),
            checkMarkImageView.widthAnchor.constraint(equalToConstant: Constants.iconSize.width)
        ])
    }

    private func layoutIncorrectQRCode(centeringBy cameraFrame: UIView) {
        NSLayoutConstraint.activate([
            incorrectQRFeedback.topAnchor.constraint(equalTo: cameraFrame.topAnchor, constant: Constants.spacing),
            incorrectQRFeedback.leadingAnchor.constraint(equalTo: cameraFrame.leadingAnchor,
                                                         constant: Constants.spacing),
            incorrectQRFeedback.trailingAnchor.constraint(equalTo: cameraFrame.trailingAnchor,
                                                          constant: -Constants.spacing),
            incorrectQRFeedback.bottomAnchor.constraint(greaterThanOrEqualTo: cameraFrame.bottomAnchor,
                                                        constant: -Constants.spacing)
        ])
    }

    private func layoutLoadingIndicator(centeringBy cameraFrame: UIView) {
        NSLayoutConstraint.activate([
            loadingContainer.centerXAnchor.constraint(equalTo: cameraFrame.centerXAnchor),
            loadingContainer.centerYAnchor.constraint(equalTo: cameraFrame.centerYAnchor),
            loadingContainer.leadingAnchor.constraint(equalTo: cameraFrame.leadingAnchor),
            loadingContainer.topAnchor.constraint(greaterThanOrEqualTo: cameraFrame.topAnchor)
        ])
    }

    func configureQrCodeOverlay(withCorrectQrCode isQrCodeCorrect: Bool) {
        if isQrCodeCorrect {
            backgroundColor = .GiniCapture.dark3.withAlphaComponent(0.8)
            correctQRFeedback.isHidden = false
            checkMarkImageView.isHidden = false
            incorrectQRFeedback.isHidden = true
        } else {
            backgroundColor = .clear
            correctQRFeedback.isHidden = true
            checkMarkImageView.isHidden = true
            incorrectQRFeedback.isHidden = false
        }
    }

    func viewWillDisappear() {
        hideAnimation()
    }

    // MARK: Toggle animation
    /**
     Displays a loading activity indicator. Should be called when invoice retrieving is started.
     */
    public func showAnimation() {
        checkMarkImageView.isHidden = true
        loadingContainer.isHidden = false

        if let loadingIndicator = configuration.customLoadingIndicator {
            loadingIndicator.startAnimation()
        } else {
            loadingIndicatorView.startAnimating()
        }
    }

    /**
     Hides the loading activity indicator. Should be called when invoice retrieving is finished.
     */
    public func hideAnimation() {
        checkMarkImageView.isHidden = true
        loadingContainer.isHidden = true

        if let loadingIndicator = configuration.customLoadingIndicator {
            loadingIndicator.stopAnimation()
        } else {
            loadingIndicatorView.stopAnimating()
        }
    }
}

private enum Constants {
    static let spacing: CGFloat = 8
    static let cornerRadius: CGFloat = 8
    static let topSpacing: CGFloat = 2
    static let expandedSpacing: CGFloat = 16
    static let iconSize = CGSize(width: 56, height: 56)
    static let stackViewMargins = UIEdgeInsets(top: expandedSpacing,
                                               left: expandedSpacing,
                                               bottom: expandedSpacing,
                                               right: expandedSpacing)
}
