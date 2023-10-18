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
        let textContainerCenterYAnchor = textContainer.centerYAnchor.constraint(equalTo: cameraFrame.topAnchor)
        textContainerCenterYAnchor.priority = .defaultLow

        let textContainerWidthConstraint = widthAnchor.constraint(equalToConstant: 189)
        textContainerWidthConstraint.priority = .init(999)

        let textContainerLeadingConstraint = textContainer.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                                                   constant: Constants.margins)
        textContainerLeadingConstraint.priority = .defaultHigh

        //TODO: needs to be fixed!!! width is to big
        NSLayoutConstraint.activate([
//            textContainer.centerXAnchor.constraint(equalTo: cameraFrame.centerXAnchor),
//            textContainerCenterYAnchor,
//            textContainer.topAnchor.constraint(greaterThanOrEqualTo: viewController.view.topAnchor,
//                                               constant: Constants.margins),
//            textContainerWidthConstraint,
//            textContainerLeadingConstraint

            textContainer.centerXAnchor.constraint(equalTo: cameraFrame.centerXAnchor),
            textContainerCenterYAnchor,
            textContainer.topAnchor.constraint(greaterThanOrEqualTo: viewController.view.topAnchor,
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
            textContainer.setTitle("\(IBANs[0])\n\n\(takePhotoString)")
        } else {
            textContainer.setTitle("IBAN Detected\n\n\(takePhotoString)")
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
