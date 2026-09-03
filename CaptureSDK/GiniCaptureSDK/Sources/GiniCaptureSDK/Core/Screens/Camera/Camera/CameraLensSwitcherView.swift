//
//  CameraLensSwitcherView.swift
//  
//
//  Created by David Vizaknai on 24.03.2023.
//

import UIKit

enum CameraLensesAvailable {
    case ultraWide
    case wide
    case tele
}

private enum LayoutPairs {
    case single
    case wideAndUltraWide
    case wideAndTele
    case triple
}

protocol CameraLensSwitcherViewDelegate: AnyObject {
    func cameraLensSwitcherDidSwitchTo(lens: CameraLensesAvailable, on: CameraLensSwitcherView)
}

final class CameraLensSwitcherView: UIView {
    private lazy var buttonContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .GiniCapture.dark1.withAlphaComponent(Constants.inactiveStateAlpha)
        view.layer.cornerRadius = Constants.containerRadius
        return view
    }()

    private lazy var ultraWideButton: UIButton = {
        let button = UIButton()
        button.isHidden = true
        button.setTitleColor(.GiniCapture.light1, for: .normal)
        button.backgroundColor = .GiniCapture.dark4.withAlphaComponent(Constants.inactiveStateAlpha)
        button.isExclusiveTouch = true
        button.translatesAutoresizingMaskIntoConstraints = false
        if let font = GiniConfiguration.shared.textStyleFonts[.caption2] {
            if font.pointSize > Constants.maxFontSize {
                button.titleLabel?.font = font.withSize(Constants.maxFontSize)
            } else {
                button.titleLabel?.font = font
            }
        }
        return button
    }()

    private lazy var wideButton: UIButton = {
        let button = UIButton()
        button.isHidden = true
        button.setTitleColor(.GiniCapture.light1, for: .normal)
        button.backgroundColor = .GiniCapture.dark4.withAlphaComponent(Constants.inactiveStateAlpha)
        button.isExclusiveTouch = true
        button.translatesAutoresizingMaskIntoConstraints = false
        if let font = GiniConfiguration.shared.textStyleFonts[.caption2] {
            if font.pointSize > Constants.maxFontSize {
                button.titleLabel?.font = font.withSize(Constants.maxFontSize)
            } else {
                button.titleLabel?.font = font
            }
        }
        return button
    }()

    private lazy var teleButton: UIButton = {
        let button = UIButton()
        button.isHidden = true
        button.setTitleColor(.GiniCapture.light1, for: .normal)
        button.backgroundColor = .GiniCapture.dark4.withAlphaComponent(Constants.inactiveStateAlpha)
        button.isExclusiveTouch = true
        button.translatesAutoresizingMaskIntoConstraints = false
        if let font = GiniConfiguration.shared.textStyleFonts[.caption2] {
            if font.pointSize > Constants.maxFontSize {
                button.titleLabel?.font = font.withSize(Constants.maxFontSize)
            } else {
                button.titleLabel?.font = font
            }
        }
        return button
    }()

    private lazy var ultraWideButtonHeightConstraint = ultraWideButton.heightAnchor
                                                        .constraint(equalToConstant: Constants.inactiveButtonHeight)
    private lazy var wideButtonHeightConstraint = wideButton.heightAnchor
                                                        .constraint(equalToConstant: Constants.inactiveButtonHeight)
    private lazy var teleButtonHeightConstraint = teleButton.heightAnchor
                                                        .constraint(equalToConstant: Constants.inactiveButtonHeight)

    private var selectedLens: CameraLensesAvailable = .wide
    private let availableLenses: [CameraLensesAvailable]
    private var layout: LayoutPairs = .single

    weak var delegate: CameraLensSwitcherViewDelegate?

    init(availableLenses: [CameraLensesAvailable]) {
        self.availableLenses = availableLenses
        switch availableLenses.count {
        case 1:
            self.layout = .single
        case 2:
            if availableLenses.contains(.ultraWide) {
                self.layout = .wideAndUltraWide
            } else if availableLenses.contains(.tele) {
                self.layout = .wideAndTele
            }
        case 3:
            self.layout = .triple
        default:
            self.layout = .single
        }
        super.init(frame: .zero)

        if layout == .single {
            isUserInteractionEnabled = false
            isHidden = true
            return
        }
        setupView()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        addSubview(buttonContainerView)
        buttonContainerView.addSubview(ultraWideButton)
        buttonContainerView.addSubview(wideButton)
        buttonContainerView.addSubview(teleButton)

        if availableLenses.contains(.ultraWide) {
            ultraWideButton.addTarget(self, action: #selector(ultraWideButtonTapped), for: .touchUpInside)
            ultraWideButton.isHidden = false
        }

        if availableLenses.contains(.wide) {
            wideButton.addTarget(self, action: #selector(wideButtonTapped), for: .touchUpInside)
            wideButton.isHidden = false
        }

        if availableLenses.contains(.tele) {
            teleButton.addTarget(self, action: #selector(teleButtonTapped), for: .touchUpInside)
            teleButton.isHidden = false
        }

        resetButtonsState()
        setButtonState(for: wideButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            ultraWideButtonHeightConstraint,
            wideButtonHeightConstraint,
            teleButtonHeightConstraint,
            teleButton.widthAnchor.constraint(equalTo: teleButton.heightAnchor),
            ultraWideButton.widthAnchor.constraint(equalTo: ultraWideButton.heightAnchor),
            wideButton.widthAnchor.constraint(equalTo: wideButton.heightAnchor)
        ])

        if UIDevice.current.isIpad {
            NSLayoutConstraint.activate([
                buttonContainerView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
                buttonContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
                buttonContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
                buttonContainerView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
                buttonContainerView.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                buttonContainerView.topAnchor.constraint(equalTo: topAnchor),
                buttonContainerView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
                buttonContainerView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
                buttonContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),
                buttonContainerView.centerXAnchor.constraint(equalTo: centerXAnchor)
            ])
        }

        switch layout {
        case .single:
            break
        case .wideAndUltraWide:
            NSLayoutConstraint.activate(wideAndUltraWideLayoutButtonConstraints)
        case .wideAndTele:
            NSLayoutConstraint.activate(wideAndTeleLayoutButtonConstraints)
        case .triple:
            NSLayoutConstraint.activate(tripleLayoutButtonConstraints)
        }
    }

    // Constraints for the 3 buttons
    // swiftlint:disable line_length
    private lazy var tripleLayoutButtonConstraints: [NSLayoutConstraint] = {
        if UIDevice.current.isIpad {
            return [ultraWideButton.centerXAnchor.constraint(equalTo: buttonContainerView.centerXAnchor),
                    ultraWideButton.trailingAnchor.constraint(lessThanOrEqualTo: buttonContainerView.trailingAnchor, constant: -Constants.buttonPadding),
                    ultraWideButton.topAnchor.constraint(equalTo: buttonContainerView.topAnchor, constant: Constants.interButtonSpacing),
                    ultraWideButton.leadingAnchor.constraint(greaterThanOrEqualTo: buttonContainerView.leadingAnchor, constant: Constants.buttonPadding),
                    wideButton.centerXAnchor.constraint(equalTo: buttonContainerView.centerXAnchor),

                    wideButton.trailingAnchor.constraint(lessThanOrEqualTo: buttonContainerView.trailingAnchor, constant: -Constants.buttonPadding),
                    wideButton.leadingAnchor.constraint(greaterThanOrEqualTo: buttonContainerView.leadingAnchor, constant: Constants.buttonPadding),
                    wideButton.topAnchor.constraint(equalTo: ultraWideButton.bottomAnchor, constant: Constants.interButtonSpacing),
                    teleButton.centerXAnchor.constraint(equalTo: buttonContainerView.centerXAnchor),

                    teleButton.topAnchor.constraint(equalTo: wideButton.bottomAnchor, constant: Constants.interButtonSpacing),
                    teleButton.trailingAnchor.constraint(lessThanOrEqualTo: buttonContainerView.trailingAnchor, constant: -Constants.buttonPadding),
                    teleButton.leadingAnchor.constraint(greaterThanOrEqualTo: buttonContainerView.leadingAnchor, constant: Constants.buttonPadding),
                    teleButton.bottomAnchor.constraint(equalTo: buttonContainerView.bottomAnchor, constant: -Constants.interButtonSpacing)]
        } else {
            return [ultraWideButton.centerYAnchor.constraint(equalTo: buttonContainerView.centerYAnchor),
                    ultraWideButton.leadingAnchor.constraint(equalTo: buttonContainerView.leadingAnchor, constant: Constants.interButtonSpacing),
                    ultraWideButton.topAnchor.constraint(greaterThanOrEqualTo: buttonContainerView.topAnchor, constant: Constants.buttonPadding),
                    ultraWideButton.bottomAnchor.constraint(lessThanOrEqualTo: buttonContainerView.bottomAnchor, constant: -Constants.buttonPadding),

                    wideButton.centerYAnchor.constraint(equalTo: buttonContainerView.centerYAnchor),
                    wideButton.leadingAnchor.constraint(equalTo: ultraWideButton.trailingAnchor, constant: Constants.interButtonSpacing),
                    wideButton.topAnchor.constraint(greaterThanOrEqualTo: buttonContainerView.topAnchor, constant: Constants.buttonPadding),
                    wideButton.bottomAnchor.constraint(lessThanOrEqualTo: buttonContainerView.bottomAnchor, constant: -Constants.buttonPadding),

                    teleButton.centerYAnchor.constraint(equalTo: buttonContainerView.centerYAnchor),
                    teleButton.leadingAnchor.constraint(equalTo: wideButton.trailingAnchor, constant: Constants.interButtonSpacing),
                    teleButton.topAnchor.constraint(greaterThanOrEqualTo: buttonContainerView.topAnchor, constant: Constants.buttonPadding),
                    teleButton.bottomAnchor.constraint(lessThanOrEqualTo: buttonContainerView.bottomAnchor, constant: -Constants.buttonPadding),
                    teleButton.trailingAnchor.constraint(equalTo: buttonContainerView.trailingAnchor, constant: -Constants.interButtonSpacing)]
        }
    }()

    // Constraints for wide and ultra wide button pair
    private lazy var wideAndUltraWideLayoutButtonConstraints: [NSLayoutConstraint] = {
        if UIDevice.current.isIpad {
            return [ultraWideButton.centerXAnchor.constraint(equalTo: buttonContainerView.centerXAnchor),
                    ultraWideButton.trailingAnchor.constraint(lessThanOrEqualTo: buttonContainerView.trailingAnchor,
                                                              constant: -Constants.buttonPadding),
                    ultraWideButton.topAnchor.constraint(equalTo: buttonContainerView.topAnchor,
                                                         constant: Constants.interButtonSpacing),
                    ultraWideButton.leadingAnchor.constraint(greaterThanOrEqualTo: buttonContainerView.leadingAnchor,
                                                             constant: Constants.buttonPadding),
                    wideButton.centerXAnchor.constraint(equalTo: buttonContainerView.centerXAnchor),

                    wideButton.trailingAnchor.constraint(lessThanOrEqualTo: buttonContainerView.trailingAnchor,
                                                         constant: -Constants.buttonPadding),
                    wideButton.leadingAnchor.constraint(greaterThanOrEqualTo: buttonContainerView.leadingAnchor,
                                                        constant: Constants.buttonPadding),
                    wideButton.topAnchor.constraint(equalTo: ultraWideButton.bottomAnchor,
                                                    constant: Constants.interButtonSpacing),
                    wideButton.bottomAnchor.constraint(equalTo: buttonContainerView.bottomAnchor,
                                                       constant: -Constants.interButtonSpacing)]
        } else {
            return [ultraWideButton.centerYAnchor.constraint(equalTo: buttonContainerView.centerYAnchor),
                    ultraWideButton.leadingAnchor.constraint(equalTo: buttonContainerView.leadingAnchor,
                                                             constant: Constants.interButtonSpacing),
                    ultraWideButton.topAnchor.constraint(greaterThanOrEqualTo: buttonContainerView.topAnchor,
                                                         constant: Constants.buttonPadding),
                    ultraWideButton.bottomAnchor.constraint(lessThanOrEqualTo: buttonContainerView.bottomAnchor,
                                                            constant: -Constants.buttonPadding),

                    wideButton.centerYAnchor.constraint(equalTo: buttonContainerView.centerYAnchor),
                    wideButton.leadingAnchor.constraint(equalTo: ultraWideButton.trailingAnchor,
                                                        constant: Constants.interButtonSpacing),
                    wideButton.topAnchor.constraint(greaterThanOrEqualTo: buttonContainerView.topAnchor,
                                                    constant: Constants.buttonPadding),
                    wideButton.bottomAnchor.constraint(lessThanOrEqualTo: buttonContainerView.bottomAnchor,
                                                       constant: -Constants.buttonPadding),

                    wideButton.trailingAnchor.constraint(equalTo: buttonContainerView.trailingAnchor,
                                                         constant: -Constants.interButtonSpacing)]
        }
    }()

    // Constraints for wide and tele button pair
    private lazy var wideAndTeleLayoutButtonConstraints: [NSLayoutConstraint] = {
        if UIDevice.current.isIpad {
            return [wideButton.topAnchor.constraint(equalTo: buttonContainerView.topAnchor,
                                                         constant: Constants.interButtonSpacing),
                    wideButton.centerXAnchor.constraint(equalTo: buttonContainerView.centerXAnchor),

                    wideButton.trailingAnchor.constraint(lessThanOrEqualTo: buttonContainerView.trailingAnchor,
                                                         constant: -Constants.buttonPadding),
                    wideButton.leadingAnchor.constraint(greaterThanOrEqualTo: buttonContainerView.leadingAnchor,
                                                        constant: Constants.buttonPadding),
                    teleButton.centerXAnchor.constraint(equalTo: buttonContainerView.centerXAnchor),

                    teleButton.topAnchor.constraint(equalTo: wideButton.bottomAnchor,
                                                    constant: Constants.interButtonSpacing),
                    teleButton.trailingAnchor.constraint(lessThanOrEqualTo: buttonContainerView.trailingAnchor,
                                                         constant: -Constants.buttonPadding),
                    teleButton.leadingAnchor.constraint(greaterThanOrEqualTo: buttonContainerView.leadingAnchor,
                                                        constant: Constants.buttonPadding),
                    teleButton.bottomAnchor.constraint(equalTo: buttonContainerView.bottomAnchor,
                                                       constant: -Constants.interButtonSpacing)]
        } else {
            return [wideButton.leadingAnchor.constraint(equalTo: buttonContainerView.leadingAnchor,
                                                             constant: Constants.interButtonSpacing),
                    wideButton.centerYAnchor.constraint(equalTo: buttonContainerView.centerYAnchor),
                    wideButton.leadingAnchor.constraint(equalTo: ultraWideButton.trailingAnchor,
                                                        constant: Constants.interButtonSpacing),
                    wideButton.topAnchor.constraint(greaterThanOrEqualTo: buttonContainerView.topAnchor,
                                                    constant: Constants.buttonPadding),
                    wideButton.bottomAnchor.constraint(lessThanOrEqualTo: buttonContainerView.bottomAnchor,
                                                       constant: -Constants.buttonPadding),

                    teleButton.centerYAnchor.constraint(equalTo: buttonContainerView.centerYAnchor),
                    teleButton.leadingAnchor.constraint(equalTo: wideButton.trailingAnchor,
                                                        constant: Constants.interButtonSpacing),
                    teleButton.topAnchor.constraint(greaterThanOrEqualTo: buttonContainerView.topAnchor,
                                                    constant: Constants.buttonPadding),
                    teleButton.bottomAnchor.constraint(lessThanOrEqualTo: buttonContainerView.bottomAnchor,
                                                       constant: -Constants.buttonPadding),
                    teleButton.trailingAnchor.constraint(equalTo: buttonContainerView.trailingAnchor,
                                                         constant: -Constants.interButtonSpacing)]
        }
    }()

    private func setButtonState(for button: UIButton) {
        switch selectedLens {
        case .ultraWide:
            ultraWideButton.setTitle("0,5x", for: .normal)
            ultraWideButtonHeightConstraint.constant = Constants.activeButtonHeight
        case .wide:
            wideButton.setTitle("1x", for: .normal)
            wideButtonHeightConstraint.constant = Constants.activeButtonHeight
        case .tele:
            teleButton.setTitle("2x", for: .normal)
            teleButtonHeightConstraint.constant = Constants.activeButtonHeight
        }

        NSLayoutConstraint.activate([
            ultraWideButtonHeightConstraint,
            wideButtonHeightConstraint,
            teleButtonHeightConstraint
        ])

        button.setTitleColor(.GiniCapture.warning3, for: .normal)
        button.backgroundColor = .GiniCapture.dark1.withAlphaComponent(Constants.activeStateAlpha)

        UIView.animate(withDuration: Constants.animationDuration) { [weak self] in
            self?.layoutIfNeeded()
        }
        UIViewPropertyAnimator(duration: Constants.animationDuration, curve: .easeIn) {
            button.layer.cornerRadius = Constants.activeButtonCornerRadius
        }.startAnimation()
    }

    private func resetButtonsState() {
        [ultraWideButton, wideButton, teleButton].forEach { button in
            button.setTitleColor(.GiniCapture.light1, for: .normal)
            button.backgroundColor = .GiniCapture.dark1.withAlphaComponent(Constants.inactiveStateAlpha)
        }

        NSLayoutConstraint.deactivate([
            ultraWideButtonHeightConstraint,
            wideButtonHeightConstraint,
            teleButtonHeightConstraint
        ])

        ultraWideButtonHeightConstraint.constant = Constants.inactiveButtonHeight
        wideButtonHeightConstraint.constant = Constants.inactiveButtonHeight
        teleButtonHeightConstraint.constant = Constants.inactiveButtonHeight

        ultraWideButton.setTitle("0,5", for: .normal)
        wideButton.setTitle("1", for: .normal)
        teleButton.setTitle("2", for: .normal)

        UIViewPropertyAnimator(duration: Constants.animationDuration, curve: .easeIn) { [weak self] in
            self?.ultraWideButton.layer.cornerRadius = Constants.inactiveButtonCornerRadius
            self?.wideButton.layer.cornerRadius = Constants.inactiveButtonCornerRadius
            self?.teleButton.layer.cornerRadius = Constants.inactiveButtonCornerRadius
        }.startAnimation()
    }

    @objc
    private func ultraWideButtonTapped() {
        guard selectedLens != .ultraWide else { return }
        resetButtonsState()
        selectedLens = .ultraWide
        setButtonState(for: ultraWideButton)
        delegate?.cameraLensSwitcherDidSwitchTo(lens: .ultraWide, on: self)
    }

    @objc
    private func wideButtonTapped() {
        guard selectedLens != .wide else { return }
        resetButtonsState()
        selectedLens = .wide
        setButtonState(for: wideButton)
        delegate?.cameraLensSwitcherDidSwitchTo(lens: .wide, on: self)
    }

    @objc
    private func teleButtonTapped() {
        guard selectedLens != .tele else { return }
        resetButtonsState()
        selectedLens = .tele
        setButtonState(for: teleButton)
        delegate?.cameraLensSwitcherDidSwitchTo(lens: .tele, on: self)
    }
}

private extension CameraLensSwitcherView {
    enum Constants {
        static let containerRadius: CGFloat = 20
        static let inactiveButtonCornerRadius: CGFloat = 12
        static let activeButtonCornerRadius: CGFloat = 18
        static let interButtonSpacing: CGFloat = 8
        static let buttonPadding: CGFloat = 3
        static let inactiveButtonHeight: CGFloat = 24
        static let activeButtonHeight: CGFloat = 34
        static let inactiveStateAlpha: CGFloat = 0.24
        static let activeStateAlpha: CGFloat = 0.54
        static let animationDuration: CGFloat = 0.3
        static let maxFontSize: CGFloat = 17
    }
}
// swiftlint:enable type_body_length
