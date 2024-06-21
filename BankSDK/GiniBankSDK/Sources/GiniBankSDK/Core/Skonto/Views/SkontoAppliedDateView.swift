//
//  SkontoDateView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniCaptureSDK

public class SkontoAppliedDateView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.info.date.title",
                                                              comment: "Fälligkeitsdatum")
        label.font = GiniBankConfiguration.shared.textStyleFonts[.footnote]
        // TODO: in some places invertive color is dark7
        label.textColor = GiniColor(light: .GiniBank.dark6, dark: .GiniBank.light6).uiColor()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let textField: UITextField = {
        let textField = UITextField()
        textField.text = "11.11.1111"
        textField.textColor = GiniColor(light: .GiniBank.dark1, dark: .GiniBank.light1).uiColor()
        textField.font = GiniBankConfiguration.shared.textStyleFonts[.body]
        textField.borderStyle = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let calendarImageView: UIImageView = {
        let imageView = UIImageView(image: GiniImages.calendar.image)
        // TODO: template image will be better
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.layer.borderColor = GiniColor(light: .GiniBank.light3, dark: .GiniBank.dark4).uiColor().cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = GiniColor(light: .GiniBank.light1, dark: .GiniBank.dark3).uiColor()
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(textField)
        containerView.addSubview(calendarImageView)
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0),
            textField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            textField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            
            calendarImageView.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
            calendarImageView.leadingAnchor.constraint(equalTo: textField.trailingAnchor, constant: 10),
            calendarImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            calendarImageView.widthAnchor.constraint(equalToConstant: 22),
            calendarImageView.heightAnchor.constraint(equalToConstant: 22)
        ])
    }
}
