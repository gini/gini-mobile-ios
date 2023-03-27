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
        view.backgroundColor = .clear
        return view
    }()

    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fill
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.layer.cornerRadius = 12
        stackView.backgroundColor = .GiniCapture.dark1.withAlphaComponent(0.3)
        return stackView
    }()

    private lazy var ultraWideButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.GiniCapture.light1, for: .normal)
        button.setTitle("0.5", for: .normal)
        button.backgroundColor = .GiniCapture.dark4.withAlphaComponent(0.3)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 18
        return button
    }()

    private lazy var wideButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.GiniCapture.light1, for: .normal)
        button.setTitle("1x", for: .normal)
        button.backgroundColor = .GiniCapture.dark4.withAlphaComponent(0.3)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 18
        return button
    }()

    private lazy var teleButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.GiniCapture.light1, for: .normal)
        button.setTitle("2x", for: .normal)
        button.backgroundColor = .GiniCapture.dark4.withAlphaComponent(0.3)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 18
        return button
    }()

    private var selectedLens: CameraLensesAvailable = .wide
    private let availableLenses: [CameraLensesAvailable]

    weak var delegate: CameraLensSwitcherViewDelegate?

    init(availableLenses: [CameraLensesAvailable]) {
        self.availableLenses = availableLenses
        super.init(frame: .zero)
        setupView()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        addSubview(buttonContainerView)
        buttonContainerView.addSubview(buttonsStackView)

        buttonsStackView.addArrangedSubview(UIView())

        if availableLenses.contains(.ultraWide) {
            ultraWideButton.addTarget(self, action: #selector(ultraWideButtonTapped), for: .touchUpInside)
            buttonsStackView.addArrangedSubview(ultraWideButton)
        }

        if availableLenses.contains(.wide) {
            wideButton.addTarget(self, action: #selector(wideButtonTapped), for: .touchUpInside)
            buttonsStackView.addArrangedSubview(wideButton)
        }

        if availableLenses.contains(.tele) {
            teleButton.addTarget(self, action: #selector(teleButtonTapped), for: .touchUpInside)
            buttonsStackView.addArrangedSubview(teleButton)
        }

        buttonsStackView.addArrangedSubview(UIView())
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            teleButton.widthAnchor.constraint(equalTo: teleButton.heightAnchor),
            ultraWideButton.widthAnchor.constraint(equalTo: ultraWideButton.heightAnchor),
            wideButton.widthAnchor.constraint(equalTo: wideButton.heightAnchor),

            buttonContainerView.topAnchor.constraint(equalTo: topAnchor),
            buttonContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            buttonContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            buttonContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),

            buttonsStackView.centerXAnchor.constraint(equalTo: buttonContainerView.centerXAnchor),
            buttonsStackView.topAnchor.constraint(equalTo: buttonContainerView.topAnchor),
            buttonsStackView.bottomAnchor.constraint(equalTo: buttonContainerView.bottomAnchor),
            buttonsStackView.leadingAnchor.constraint(greaterThanOrEqualTo: buttonContainerView.leadingAnchor)
        ])
    }

    @objc
    private func ultraWideButtonTapped() {
        delegate?.cameraLensSwitcherDidSwitchTo(lens: .ultraWide, on: self)
    }

    @objc
    private func wideButtonTapped() {
        delegate?.cameraLensSwitcherDidSwitchTo(lens: .wide, on: self)
    }

    @objc
    private func teleButtonTapped() {
        delegate?.cameraLensSwitcherDidSwitchTo(lens: .tele, on: self)
    }
}
