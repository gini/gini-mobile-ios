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
        textStackView.axis = .vertical
        textStackView.distribution = .fill
        textStackView.spacing = Constants.spacing
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
            textStackView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.spacing * 2),
            textStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.spacing * 2)
        ])
    }
}

final class QRCodeOverlay: UIView {
    private let configuration = GiniConfiguration.shared
    private var educationViewModel: QREducationLoadingViewModel?
    private var customLoadingView: QREducationLoadingView?
    private let useCustomLoadingView: Bool = true
    private var educationTask: Task<Void, Never>?
    private var educationFlowController: EducationFlowController?

    /**
     The currently running education flow task, if any.
     
     This task represents the education flow started by `showAnimation()`
     when the QR code education view is shown.
     */
    public var currentEducationTask: Task<Void, Never>? {
        educationTask
    }

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
        textStackView.spacing = Constants.spacing * 2
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
        let shouldDisplayEducation = configuration.qrCodeScanningEnabled &&
                                     !configuration.onlyQRCodeScanningEnabled &&
                                     configuration.fileImportSupportedTypes != .none
        let controller = EducationFlowController.qrCodeFlowController(displayIfNeeded: shouldDisplayEducation)
        educationFlowController = controller

        let nextState = controller.nextState()
        switch nextState {
        case .showMessage(let messageIndex):
            addEducationLoadingView(messageIndex: messageIndex)
        case .showOriginalFlow:
            addOriginalLoadingView()
        }
    }

    private func addEducationLoadingView(messageIndex: Int) {
        let loadingItems = EducationFlowContent.qrCode(messageIndex: messageIndex).items

        let viewModel = QREducationLoadingViewModel(items: loadingItems)
        educationViewModel = viewModel

        let customViewStyle = QREducationLoadingView.Style(textColor: .GiniCapture.light1,
                                                           analysingTextColor: .GiniCapture.light6)
        let customView = QREducationLoadingView(viewModel: viewModel, style: customViewStyle)
        customView.translatesAutoresizingMaskIntoConstraints = false
        customLoadingView = customView
        addSubview(customView)
    }

    private func addOriginalLoadingView() {
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
                                                       constant: Constants.spacing * 2),

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
                                                          constant: -Constants.spacing)
        ])
    }

    private func layoutLoadingIndicator(centeringBy cameraFrame: UIView) {
        if let customLoadingView {
            layoutCustomLoadingView(customLoadingView, cameraFrame: cameraFrame)
        } else {
            layoutOriginalLoadingContainer(cameraFrame: cameraFrame)
        }
    }

    private func layoutCustomLoadingView(_ view: UIView, cameraFrame: UIView) {
        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: cameraFrame.centerXAnchor),
            view.centerYAnchor.constraint(greaterThanOrEqualTo: cameraFrame.centerYAnchor),
            view.leadingAnchor.constraint(greaterThanOrEqualTo: cameraFrame.leadingAnchor,
                                          constant: Constants.educationLoadingViewPadding),
            view.trailingAnchor.constraint(lessThanOrEqualTo: cameraFrame.trailingAnchor,
                                           constant: -Constants.educationLoadingViewPadding),
            view.topAnchor.constraint(greaterThanOrEqualTo: correctQRFeedback.topAnchor,
                                      constant: Constants.educationLoadingViewTopPadding)
        ])
    }

    private func layoutOriginalLoadingContainer(cameraFrame: UIView) {
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

        if let educationViewModel {
            educationTask = Task { [weak self] in
                await educationViewModel.start()
                self?.educationFlowController?.markMessageAsShown()
            }
            customLoadingView?.isHidden = false
        } else {
            loadingContainer.isHidden = false
            if let loadingIndicator = configuration.customLoadingIndicator {
                loadingIndicator.startAnimation()
            } else {
                loadingIndicatorView.startAnimating()
            }
        }
    }

    /**
     Hides the loading activity indicator. Should be called when invoice retrieving is finished.
     */
    public func hideAnimation() {
        checkMarkImageView.isHidden = true
        if let customLoadingView {
            customLoadingView.isHidden = true
        } else {
            loadingContainer.isHidden = true
            if let customIndicator = configuration.customLoadingIndicator {
                customIndicator.stopAnimation()
            } else {
                loadingIndicatorView.stopAnimating()
            }
        }
    }
}

private enum Constants {
    static let spacing: CGFloat = 8
    static let educationLoadingViewPadding: CGFloat = 28
    static let educationLoadingViewTopPadding: CGFloat = 6
    static let topSpacing: CGFloat = 2
    static let iconSize = CGSize(width: 56, height: 56)
}
