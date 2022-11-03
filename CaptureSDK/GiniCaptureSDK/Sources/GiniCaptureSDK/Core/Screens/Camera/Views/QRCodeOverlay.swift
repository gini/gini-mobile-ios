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
        label.text = "QR code detected"
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
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])
    }
}

final class IncorrectQRCodeTextContainer: UIView {
    private let configuration = GiniConfiguration.shared

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = configuration.textStyleFonts[.footnoteBold]
        label.textColor = .GiniCapture.dark1
        label.text = "Unkown QR code"
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = configuration.textStyleFonts[.footnote]
        label.textColor = .GiniCapture.dark1
        label.numberOfLines = 0
        label.text = "This code does not carry any information that can be processed."
        return label
    }()

    private lazy var textStackView: UIStackView = {
        let textStackView = UIStackView()
        textStackView.axis = .vertical
        textStackView.distribution = .fillProportionally
        textStackView.spacing = 5
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        return textStackView
    }()

    init() {
        super.init(frame: .zero)

        backgroundColor = .GiniCapture.warning3
        addSubview(textStackView)
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(descriptionLabel)
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            textStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            textStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            textStackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            textStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16)
        ])
    }
}

final class QRCodeOverlay: UIView {
    private let configuration = GiniConfiguration.shared

    private lazy var correctQRFeedback: CorrectQRCodeTextContainer = {
        let view = CorrectQRCodeTextContainer()
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    private lazy var incorrectQRFeedback: IncorrectQRCodeTextContainer = {
        let view = IncorrectQRCodeTextContainer()
        view.layer.cornerRadius = 8
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
        indicatorView.style = .whiteLarge
        return indicatorView
    }()

    private lazy var loadingIndicatorText: UILabel = {
        var loadingIndicatorText = UILabel()
        loadingIndicatorText.font = configuration.textStyleFonts[.bodyBold]
        loadingIndicatorText.textAlignment = .center
        loadingIndicatorText.adjustsFontForContentSizeCategory = true
        loadingIndicatorText.textColor = .GiniCapture.light1
        loadingIndicatorText.isAccessibilityElement = true
        loadingIndicatorText.text = "Retrieving invoice"
        return loadingIndicatorText
    }()

    private lazy var loadingContainer: UIStackView = {
        let textStackView = UIStackView()
        textStackView.axis = .vertical
        textStackView.distribution = .fillProportionally
        textStackView.spacing = 16
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

        if let customLoadingIndicator = configuration.analysisScreenLoadingIndicator?.injectedView() {
            loadingIndicator = customLoadingIndicator
        } else {
            loadingIndicator = loadingIndicatorView
        }

        addSubview(loadingContainer)
        loadingContainer.addArrangedSubview(loadingIndicator)
        loadingContainer.addArrangedSubview(loadingIndicatorText)
    }

    func layoutViews(centeringBy cameraFrame: UIView) {
        NSLayoutConstraint.activate([
            incorrectQRFeedback.topAnchor.constraint(equalTo: cameraFrame.topAnchor, constant: 8),
            incorrectQRFeedback.leadingAnchor.constraint(equalTo: cameraFrame.leadingAnchor, constant: 8),
            incorrectQRFeedback.trailingAnchor.constraint(equalTo: cameraFrame.trailingAnchor, constant: -8),

            correctQRFeedback.centerXAnchor.constraint(equalTo: cameraFrame.centerXAnchor),
            correctQRFeedback.centerYAnchor.constraint(equalTo: cameraFrame.topAnchor),
            correctQRFeedback.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 16),
            correctQRFeedback.widthAnchor.constraint(greaterThanOrEqualToConstant: 106),
            correctQRFeedback.heightAnchor.constraint(greaterThanOrEqualToConstant: 26),

            checkMarkImageView.centerXAnchor.constraint(equalTo: cameraFrame.centerXAnchor),
            checkMarkImageView.centerYAnchor.constraint(equalTo: cameraFrame.centerYAnchor),
            checkMarkImageView.heightAnchor.constraint(equalToConstant: 56),
            checkMarkImageView.widthAnchor.constraint(equalToConstant: 56),

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

        if let loadingIndicator = configuration.analysisScreenLoadingIndicator {
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

        if let loadingIndicator = configuration.analysisScreenLoadingIndicator {
            loadingIndicator.stopAnimation()
        } else {
            loadingIndicatorView.stopAnimating()
        }
    }
}
