//
//  QRCodeOverlay.swift
//  
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit
import GiniUtilites

final class QRCodeOverlay: UIView {
    private let configuration = GiniConfiguration.shared
    private var educationViewModel: QRCodeEducationLoadingViewModel?
    private var educationLoadingView: QRCodeEducationLoadingView?
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
        imageView.image = Images.checkMark
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }()

    private lazy var loadingIndicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView()
        indicatorView.hidesWhenStopped = true
        indicatorView.style = .large
        indicatorView.color = .GiniCapture.light1
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
        loadingIndicatorText.text = Strings.loadingIndicatorText
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

        let viewModel = QRCodeEducationLoadingViewModel(items: loadingItems)
        educationViewModel = viewModel

        let customViewStyle = QRCodeEducationLoadingView.Style(textColor: .GiniCapture.light1,
                                                               analysingTextColor: .GiniCapture.light3)
        let view = QRCodeEducationLoadingView(viewModel: viewModel, style: customViewStyle)
        view.translatesAutoresizingMaskIntoConstraints = false
        educationLoadingView = view
        addSubview(view)
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
        layoutLoadingIndicator(centeringBy: cameraFrame, on: viewController)
    }

    private var isAccessibilityDeviceWithoutNotch: Bool {
        let isAccessibilityCategory = GiniAccessibility.isFontSizeAtLeastAccessibilityMedium
        let isIPhoneWithoutNotch = UIDevice.current.isIphoneAndLandscape && !UIDevice.current.hasNotch
        return isIPhoneWithoutNotch && isAccessibilityCategory
    }

    private func layoutCorrectQRCode(centeringBy cameraFrame: UIView, on viewController: UIViewController) {
        let correctQRCenterYAnchor = correctQRFeedback.centerYAnchor.constraint(equalTo: cameraFrame.topAnchor)
        correctQRCenterYAnchor.priority = .defaultLow
        if isAccessibilityDeviceWithoutNotch && configuration.bottomNavigationBarEnabled {
            // Use .required (1000) to strongly prevent vertical compression — keep correctQRFeedback fully visible
            correctQRFeedback.setContentCompressionResistancePriority(.required, for: .vertical)
        } else {
            // Use .defaultHigh (750) to resist compression but allow it if space is tight
            correctQRFeedback.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        }

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

    private func layoutLoadingIndicator(centeringBy cameraFrame: UIView,
                                        on viewController: UIViewController) {

        guard let educationLoadingView else {
            layoutDefaultLoadingView(cameraFrame: cameraFrame)
            return
        }

        let isAccessibilityCategory = GiniAccessibility.isFontSizeAtLeastAccessibilityMedium
        // Check if is iPhone and landscape orientation and 200% font size enabled
        if isAccessibilityCategory && UIDevice.current.isIphoneAndLandscape {
            // For iPhone landscape mode with large font size, educationLoadingView is added to the viewController
            layoutEducationLoadingView(educationLoadingView,
                                       cameraFrame: cameraFrame,
                                       on: viewController)
        } else {
            layoutEducationLoadingView(educationLoadingView,
                                       cameraFrame: cameraFrame)
        }

    }
    private var educationLoadingConstraints: [NSLayoutConstraint] = []

    private func layoutEducationLoadingView(_ view: UIView,
                                            cameraFrame: UIView,
                                            on viewController: UIViewController? = nil) {
        NSLayoutConstraint.deactivate(educationLoadingConstraints)
        educationLoadingConstraints.removeAll()

        var constraints: [NSLayoutConstraint] = [
            view.centerXAnchor.constraint(equalTo: cameraFrame.centerXAnchor),
            view.centerYAnchor.constraint(equalTo: cameraFrame.centerYAnchor)
        ]

        if let viewController = viewController {
            var horizontalPadding: CGFloat = 0
            if UIDevice.current.isIphoneAndLandscape {
                horizontalPadding = Constants.educationLoadingHorizontalPadding
            }
            constraints.append(view.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor,
                                                             constant: horizontalPadding))
            constraints.append(view.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor,
                                                              constant: -horizontalPadding))
            constraints.append(view.topAnchor.constraint(equalTo: correctQRFeedback.bottomAnchor))
        } else {
            constraints.append(view.leadingAnchor.constraint(equalTo: cameraFrame.leadingAnchor))
            constraints.append(view.trailingAnchor.constraint(equalTo: cameraFrame.trailingAnchor))
            constraints.append(view.topAnchor.constraint(greaterThanOrEqualTo: correctQRFeedback.bottomAnchor))
        }

        educationLoadingConstraints = constraints
        NSLayoutConstraint.activate(constraints)
    }

    private func layoutDefaultLoadingView(cameraFrame: UIView) {
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
            educationLoadingView?.isHidden = false
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
        if let educationLoadingView {
            educationLoadingView.isHidden = true
        } else {
            loadingContainer.isHidden = true
            if let customIndicator = configuration.customLoadingIndicator {
                customIndicator.stopAnimation()
            } else {
                loadingIndicatorView.stopAnimating()
            }
        }
    }

    private struct Constants {
        static let spacing: CGFloat = 8
        static let cornerRadius: CGFloat = 8
        static let educationLoadingViewPadding: CGFloat = 28
        static let educationLoadingViewTopPadding: CGFloat = 6
        static let topSpacing: CGFloat = 2
        static let expandedSpacing: CGFloat = 16
        static let iconSize = CGSize(width: 56, height: 56)
        static let educationLoadingHorizontalPadding: CGFloat = 56
        static let stackViewMargins = UIEdgeInsets(top: expandedSpacing,
                                                   left: expandedSpacing,
                                                   bottom: expandedSpacing,
                                                   right: expandedSpacing)
    }

    private struct Strings {
        static let loadingIndicatorText = NSLocalizedStringPreferredFormat("ginicapture.QRscanning.loading",
                                                                           comment: "Retrievenig invoice")
    }

    private struct Images {
        static let checkMark = UIImageNamedPreferred(named: "greenCheckMark")
    }
}
