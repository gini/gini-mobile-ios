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
        button.setTitleColor(.GiniCapture.light1, for: .normal)
        button.setTitle("0.5", for: .normal)
        button.titleLabel?.font = GiniConfiguration.shared.textStyleFonts[.caption2]
        button.backgroundColor = .GiniCapture.dark4.withAlphaComponent(Constants.inactiveStateAlpha)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = Constants.cornerRadius
        return button
    }()

    private lazy var wideButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.GiniCapture.light1, for: .normal)
        button.setTitle("1x", for: .normal)
        button.titleLabel?.font = GiniConfiguration.shared.textStyleFonts[.caption2]
        button.backgroundColor = .GiniCapture.dark4.withAlphaComponent(Constants.inactiveStateAlpha)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 18
        return button
    }()

    private lazy var teleButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.GiniCapture.light1, for: .normal)
        button.setTitle("2x", for: .normal)
        button.titleLabel?.font = GiniConfiguration.shared.textStyleFonts[.caption2]
        button.backgroundColor = .GiniCapture.dark4.withAlphaComponent(Constants.inactiveStateAlpha)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = Constants.cornerRadius
        return button
    }()

    private var selectedLens: CameraLensesAvailable = .wide
    private let availableLenses: [CameraLensesAvailable]

    weak var delegate: CameraLensSwitcherViewDelegate?

    init(availableLenses: [CameraLensesAvailable]) {
        self.availableLenses = availableLenses
        super.init(frame: .zero)

        if availableLenses.count <= 1 {
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

        if availableLenses.contains(.ultraWide) {
            ultraWideButton.addTarget(self, action: #selector(ultraWideButtonTapped), for: .touchUpInside)
            buttonContainerView.addSubview(ultraWideButton)
        }

        if availableLenses.contains(.wide) {
            setButtonState(for: wideButton)
            wideButton.addTarget(self, action: #selector(wideButtonTapped), for: .touchUpInside)
            buttonContainerView.addSubview(wideButton)
        }

        if availableLenses.contains(.tele) {
            teleButton.addTarget(self, action: #selector(teleButtonTapped), for: .touchUpInside)
            buttonContainerView.addSubview(teleButton)
        }
    }

    private lazy var ultraWideButtonHeightConstraint = ultraWideButton.heightAnchor.constraint(equalToConstant: 24)
    private lazy var wideButtonHeightConstraint = wideButton.heightAnchor.constraint(equalToConstant: 24)
    private lazy var teleButtonHeightConstraint = teleButton.heightAnchor.constraint(equalToConstant: 24)

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            ultraWideButtonHeightConstraint,
            wideButtonHeightConstraint,
            teleButtonHeightConstraint,
            teleButton.widthAnchor.constraint(equalTo: teleButton.heightAnchor),
            ultraWideButton.widthAnchor.constraint(equalTo: ultraWideButton.heightAnchor),
            wideButton.widthAnchor.constraint(equalTo: wideButton.heightAnchor),

            ultraWideButton.centerYAnchor.constraint(equalTo: buttonContainerView.centerYAnchor),
            ultraWideButton.leadingAnchor.constraint(equalTo: buttonContainerView.leadingAnchor, constant: 8),
            ultraWideButton.topAnchor.constraint(greaterThanOrEqualTo: buttonContainerView.topAnchor, constant: 3),
            ultraWideButton.bottomAnchor.constraint(lessThanOrEqualTo: buttonContainerView.bottomAnchor, constant: -3),

            wideButton.centerYAnchor.constraint(equalTo: buttonContainerView.centerYAnchor),
            wideButton.leadingAnchor.constraint(equalTo: ultraWideButton.trailingAnchor, constant: 8),
            wideButton.topAnchor.constraint(greaterThanOrEqualTo: buttonContainerView.topAnchor, constant: 3),
            wideButton.bottomAnchor.constraint(lessThanOrEqualTo: buttonContainerView.bottomAnchor, constant: -3),

            teleButton.centerYAnchor.constraint(equalTo: buttonContainerView.centerYAnchor),
            teleButton.leadingAnchor.constraint(equalTo: wideButton.trailingAnchor, constant: 8),
            teleButton.topAnchor.constraint(greaterThanOrEqualTo: buttonContainerView.topAnchor, constant: 3),
            teleButton.bottomAnchor.constraint(lessThanOrEqualTo: buttonContainerView.bottomAnchor, constant: -3),
            teleButton.trailingAnchor.constraint(equalTo: buttonContainerView.trailingAnchor, constant: -8),

            buttonContainerView.topAnchor.constraint(equalTo: topAnchor),
            buttonContainerView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            buttonContainerView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            buttonContainerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func setButtonState(for button: UIButton) {
        NSLayoutConstraint.deactivate([
            ultraWideButtonHeightConstraint,
            wideButtonHeightConstraint,
            teleButtonHeightConstraint
        ])

        ultraWideButtonHeightConstraint.constant = 24
        wideButtonHeightConstraint.constant = 24
        teleButtonHeightConstraint.constant = 24

        ultraWideButton.setTitle("0.5", for: .normal)
        wideButton.setTitle("1", for: .normal)
        teleButton.setTitle("2", for: .normal)

        UIViewPropertyAnimator(duration: 0.3, curve: .easeIn) { [weak self] in
            self?.ultraWideButton.layer.cornerRadius = 12
            self?.wideButton.layer.cornerRadius = 12
            self?.teleButton.layer.cornerRadius = 12
        }.startAnimation()

        switch selectedLens {
        case .ultraWide:
            ultraWideButton.setTitle("0.5x", for: .normal)
            ultraWideButtonHeightConstraint.constant = 34
        case .wide:
            wideButton.setTitle("1x", for: .normal)
            wideButtonHeightConstraint.constant = 34
        case .tele:
            teleButton.setTitle("2x", for: .normal)
            teleButtonHeightConstraint.constant = 34
        }

        NSLayoutConstraint.activate([
            ultraWideButtonHeightConstraint,
            wideButtonHeightConstraint,
            teleButtonHeightConstraint
        ])

        button.setTitleColor(.yellow, for: .normal)
        button.backgroundColor = .GiniCapture.dark1.withAlphaComponent(Constants.activeStateAlpha)

        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.layoutIfNeeded()
        }
        UIViewPropertyAnimator(duration: 0.3, curve: .easeIn) {
            button.layer.cornerRadius = 18
        }.startAnimation()
    }

    private func resetButtonsState() {
        [ultraWideButton, wideButton, teleButton].forEach { button in
            button.setTitleColor(.GiniCapture.light1, for: .normal)
            button.backgroundColor = .GiniCapture.dark1.withAlphaComponent(Constants.inactiveStateAlpha)
        }
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
        static let cornerRadius: CGFloat = 12
        static let stackViewSpacing: CGFloat = 4
        static let inactiveStateAlpha: CGFloat = 0.24
        static let activeStateAlpha: CGFloat = 0.8
    }
}
