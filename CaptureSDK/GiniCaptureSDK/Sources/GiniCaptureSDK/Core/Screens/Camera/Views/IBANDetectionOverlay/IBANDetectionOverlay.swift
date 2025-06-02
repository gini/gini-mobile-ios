//
//  IBANDetectionOverlay.swift
//
//
//  Created by Valentina Iancu on 11.10.23.
//

import UIKit

final class IBANDetectionOverlay: UIView {
    private let configuration = GiniConfiguration.shared
    private let textContainer = IBANTextContainer()
    private var previousTitle: String?

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

    private func layout(centeringBy cameraFrame: UIView, on viewController: UIViewController) {
        NSLayoutConstraint.activate([
            textContainer.centerXAnchor.constraint(equalTo: cameraFrame.centerXAnchor),
            textContainer.topAnchor.constraint(greaterThanOrEqualTo: cameraFrame.topAnchor),
            textContainer.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor,
                                                   constant: Constants.leadingMargin)
        ])
    }

    func layoutViews(centeringBy cameraFrame: UIView, on viewController: UIViewController) {
        layout(centeringBy: cameraFrame, on: viewController)
    }

    func setupView(with IBANs: [String]) {
        let title: String
        let takePhotoString = NSLocalizedStringPreferredFormat("ginicapture.ibandetection.takephoto",
                                                               comment: "IBAN Detection")
        
        if IBANs.count == 1 {
            let iban = IBANs[0].split(every: 4)
            title = "\(iban)\n\n\(takePhotoString)"
        } else {
            let ibanDetectedString = NSLocalizedStringPreferredFormat("ginicapture.ibandetection.multipleibansdetected",
                                                                      comment: "Multiple IBAN detected")
            title = "\(ibanDetectedString)\n\n\(takePhotoString)"
        }

        textContainer.setTitle(title)
        postVoiceOverAnnouncementIfNeeded(title)
    }

    func configureOverlay(hidden: Bool) {
        textContainer.isHidden = hidden

        if hidden {
            previousTitle = nil
        }
    }

    func viewWillDisappear() {
        configureOverlay(hidden: true)
    }

    private func postVoiceOverAnnouncementIfNeeded(_ title: String) {
        guard previousTitle != title else {
            return
        }

        previousTitle = title
        UIAccessibility.post(notification: .announcement, argument: title)
    }

    private enum Constants {
        static let cornerRadius: CGFloat = 8
        static let leadingMargin: CGFloat = 8
    }
}
