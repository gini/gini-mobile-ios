//
//  SkontoDateView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

class SkontoAppliedDateView: UIView {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        let title = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.withdiscount.expirydate.title",
                                                             comment: "Due date")
        label.text = title
        label.accessibilityValue = title
        label.font = configuration.textStyleFonts[.footnote]
        label.textColor = .giniColorScheme().text.secondary.uiColor()
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.text = viewModel.dueDate.currentShortString
        textField.textColor = .giniColorScheme().text.primary.uiColor()
        textField.font = configuration.textStyleFonts[.body]
        textField.borderStyle = .none
        textField.adjustsFontForContentSizeCategory = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private lazy var calendarImageView: UIImageView = {
        let imageView = UIImageView(image: GiniImages.calendar.image)
        imageView.tintColor = .giniColorScheme().icons.standardTertiary.uiColor()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.giniColorScheme().bg.border.uiColor().cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = Constants.cornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let configuration = GiniBankConfiguration.shared

    private var viewModel: SkontoViewModel

    init(viewModel: SkontoViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .giniColorScheme().bg.inputUnfocused.uiColor()
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(textField)
        containerView.addSubview(calendarImageView)
        setupConstraints()
        addTapGestureRecognizer()
        configureDatePicker()
        bindViewModel()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor,
                                            constant: Constants.padding),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,
                                                constant: Constants.padding),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,
                                                 constant: -Constants.padding),

            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            textField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,
                                               constant: Constants.padding),
            textField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor,
                                              constant: -Constants.padding),

            calendarImageView.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
            calendarImageView.leadingAnchor.constraint(equalTo: textField.trailingAnchor,
                                                       constant: Constants.imageHorizontalPadding),
            calendarImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,
                                                        constant: -Constants.padding),
            calendarImageView.widthAnchor.constraint(equalToConstant: Constants.imageSize),
            calendarImageView.heightAnchor.constraint(equalToConstant: Constants.imageSize)
        ])
    }

    private func addTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGestureRecognizer)
    }

    @objc private func handleTap() {
        guard viewModel.isSkontoApplied  else { return }
        textField.becomeFirstResponder()
    }

    private func bindViewModel() {
        configure()
        viewModel.addStateChangeHandler { [weak self] in
            guard let self else { return }
            self.configure()
        }
    }

    private func configure() {
        let isSkontoApplied = viewModel.isSkontoApplied
        containerView.layer.borderWidth = isSkontoApplied ? 1 : 0
        textField.isUserInteractionEnabled = isSkontoApplied
        calendarImageView.isHidden = !isSkontoApplied
        textField.text = viewModel.dueDate.currentShortString
    }

    private func configureDatePicker() {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.date = viewModel.dueDate
        let currentDate = Date().inBerlinTimeZone
        var dateComponent = DateComponents()
        dateComponent.month = 6
        let endDate = Calendar.current.date(byAdding: dateComponent, to: currentDate)
        datePicker.minimumDate = currentDate
        datePicker.maximumDate = endDate
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        textField.inputView = datePicker
    }

    @objc private func dateChanged(_ datePicker: UIDatePicker) {
        viewModel.set(date: datePicker.date)
    }
}

private extension SkontoAppliedDateView {
    enum Constants {
        static let padding: CGFloat = 12
        static let imageHorizontalPadding: CGFloat = 10
        static let imageSize: CGFloat = 22
        static let cornerRadius: CGFloat = 8
    }
}
