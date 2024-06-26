//
//  SkontoDateView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniCaptureSDK

public class SkontoAppliedDateView: UIView {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.info.date.title",
                                                              comment: "Fälligkeitsdatum")
        label.font = configuration.textStyleFonts[.footnote]
        // TODO: in some places invertive color is dark7
        label.textColor = GiniColor(light: .GiniBank.dark6, dark: .GiniBank.light6).uiColor()
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.text = "11.11.1111"
        textField.textColor = GiniColor(light: .GiniBank.dark1, dark: .GiniBank.light1).uiColor()
        textField.font = configuration.textStyleFonts[.body]
        textField.borderStyle = .none
        textField.adjustsFontForContentSizeCategory = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private lazy var calendarImageView: UIImageView = {
        let imageView = UIImageView(image: GiniImages.calendar.image)
        // TODO: template image will be better
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.borderColor = GiniColor(light: .GiniBank.light3, dark: .GiniBank.dark4).uiColor().cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let configuration = GiniBankConfiguration.shared

    private var viewModel: SkontoViewModel

    public init(viewModel: SkontoViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = GiniColor(light: .GiniBank.light1, dark: .GiniBank.dark3).uiColor()
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(textField)
        containerView.addSubview(calendarImageView)
        setupConstraints()
        configureDatePicker()
        bindViewModel()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Constants.padding),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.padding),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.padding),

            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            textField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.padding),
            textField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Constants.padding),

            calendarImageView.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
            calendarImageView.leadingAnchor.constraint(equalTo: textField.trailingAnchor, constant: Constants.imageHorizontalPadding),
            calendarImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.padding),
            calendarImageView.widthAnchor.constraint(equalToConstant: Constants.imageSize),
            calendarImageView.heightAnchor.constraint(equalToConstant: Constants.imageSize)
        ])
    }

    private func bindViewModel() {
        configure(isSkontoApplied: viewModel.isSkontoApplied)
        viewModel.addObserver { [weak self] isSkontoApplied in
            self?.configure(isSkontoApplied: isSkontoApplied)
        }
    }

    private func configure(isSkontoApplied: Bool) {
        let isSkontoApplied = viewModel.isSkontoApplied
        containerView.layer.borderWidth = isSkontoApplied ? 1 : 0
        textField.isUserInteractionEnabled = isSkontoApplied
        calendarImageView.isHidden = isSkontoApplied ? false : true
    }

    private func configureDatePicker() {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        textField.inputView = datePicker
    }

    @objc private func dateChanged(_ datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        textField.text = dateFormatter.string(from: datePicker.date)
    }
}

private extension SkontoAppliedDateView {
    enum Constants {
        static let padding: CGFloat = 12
        static let imageHorizontalPadding: CGFloat = 10
        static let imageSize: CGFloat = 22
    }
}
