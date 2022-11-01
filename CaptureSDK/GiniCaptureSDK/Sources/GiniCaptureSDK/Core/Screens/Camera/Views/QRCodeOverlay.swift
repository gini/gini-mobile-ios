//
//  QRCodeOverlay.swift
//  
//
//  Created by David Vizaknai on 01.11.2022.
//

import UIKit

final class QRCodeOverlay: UIView {
    private let configuration = GiniConfiguration.shared

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = configuration.textStyleFonts[.caption2]
        label.textAlignment = .center
        label.textColor = .GiniCapture.light1
        label.text = "QR code detected"
        return label
    }()

    private lazy var textContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 6
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var checkMarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImageNamedPreferred(named: "greenCheckMark")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    init() {
        super.init(frame: .zero)
        addSubview(textContainerView)
        addSubview(titleLabel)
        addSubview(checkMarkImageView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func layoutViews(centeringBy cameraFrame: UIView) {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            textContainerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            textContainerView.centerYAnchor.constraint(equalTo: cameraFrame.topAnchor),
            textContainerView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 16),
            textContainerView.widthAnchor.constraint(greaterThanOrEqualToConstant: 106),
            textContainerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 26),

            titleLabel.centerXAnchor.constraint(equalTo: textContainerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: textContainerView.centerYAnchor),
            titleLabel.topAnchor.constraint(equalTo: textContainerView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor),

            checkMarkImageView.centerXAnchor.constraint(equalTo: cameraFrame.centerXAnchor),
            checkMarkImageView.centerYAnchor.constraint(equalTo: cameraFrame.centerYAnchor),
            checkMarkImageView.heightAnchor.constraint(equalToConstant: 56),
            checkMarkImageView.widthAnchor.constraint(equalToConstant: 56)
        ])
    }

    func configureQrCodeOverlay(withCorrectQrCode isQrCodeCorrect: Bool) {
        if isQrCodeCorrect {
            backgroundColor = .black.withAlphaComponent(0.7)
            titleLabel.text = "QR code detected"
            textContainerView.backgroundColor = .GiniCapture.success2
        } else {
            backgroundColor = .clear
            titleLabel.text = "UnknownQR code"
            textContainerView.backgroundColor = .GiniCapture.warning3
        }
    }
}
