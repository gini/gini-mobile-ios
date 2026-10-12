//
//  CorrectQRCodeTextContainer.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit
import GiniUtilites

final class CorrectQRCodeTextContainer: UIView {
    private let configuration = GiniConfiguration.shared

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = configuration.textStyleFonts[.caption2]
        label.textAlignment = .center
        label.textColor = .GiniCapture.light1
        label.text = Strings.title
        label.enableScaling()
        return label
    }()

    init() {
        super.init(frame: .zero)
        backgroundColor = .GiniCapture.success2
        addSubview(titleLabel)
        setupConstraints()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupConstraints() {
        titleLabel.giniMakeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.top.equalToSuperview().constant(Constants.spacing / 2)
            $0.leading.equalToSuperview().constant(Constants.spacing)
        }
    }

    private enum Constants {
        static let spacing: CGFloat = 8
    }

    private struct Strings {
        static let title = NSLocalizedStringPreferredFormat("ginicapture.QRscanning.correct",
                                                            comment: "QR Detected")
    }
}
