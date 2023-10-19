//
//  IBANsDetectionOverlay.swift
//
//
//  Created by Valentina Iancu on 11.10.23.
//

import UIKit

final class IBANsDetectionOverlay: UIView {
    private let configuration = GiniConfiguration.shared
    private let textContainer = IBANsTextContainer()

    init() {
        super.init(frame: .zero)
        addSubview(textContainer)
        setupTextContainer()

        configureOverlay(hidden: true)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupTextContainer() {
        textContainer.translatesAutoresizingMaskIntoConstraints = false
        textContainer.backgroundColor = .GiniCapture.success2
        textContainer.layer.cornerRadius = Constants.cornerRadius
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            textContainer.centerXAnchor.constraint(equalTo: centerXAnchor),
            textContainer.topAnchor.constraint(greaterThanOrEqualTo: topAnchor,
                                               constant: Constants.margins),
            textContainer.bottomAnchor.constraint(equalTo: bottomAnchor,
                                                  constant: Constants.margins)
        ])
    }

    private func layout(centeringBy cameraFrame: UIView, on viewController: UIViewController) {
        NSLayoutConstraint.activate([
            textContainer.centerXAnchor.constraint(equalTo: cameraFrame.centerXAnchor),
            textContainer.topAnchor.constraint(greaterThanOrEqualTo: cameraFrame.topAnchor,
                                               constant: Constants.margins),
            textContainer.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor,
                                                   constant: 8)
        ])
    }

    func layoutViews(centeringBy cameraFrame: UIView, on viewController: UIViewController) {
        layout(centeringBy: cameraFrame, on: viewController)
    }

    func setupView(with IBANs: [String]) {
        let takePhotoString = NSLocalizedStringPreferredFormat("ginicapture.IBANDetection.takePhoto",
                                                               comment: "IBAN Detection")
        if IBANs.count == 1 {
            let iban = IBANs[0].split(every: 4)
            textContainer.setTitle("\(iban)\n\n\(takePhotoString)")
        } else {
            let ibanDetectedString = NSLocalizedStringPreferredFormat("ginicapture.IBANDetection.multipleIBANsDetected",
                                                                      comment: "Multiple IBAN detected")
            textContainer.setTitle("\(ibanDetectedString)\n\n\(takePhotoString)")
        }
    }

    func configureOverlay(hidden: Bool) {
        textContainer.isHidden = hidden
    }

    func viewWillDisappear() {
        configureOverlay(hidden: true)
    }

    private enum Constants {
        static let margins: CGFloat = 16
        static let cornerRadius: CGFloat = 8
    }
}
