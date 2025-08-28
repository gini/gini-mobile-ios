//
//  SkontoExpiryDateView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniCaptureSDK

protocol SkontoExpiryDateViewDelegate: AnyObject {
    func expiryDateTextFieldTapped()
}

class SkontoExpiryDateView: UIView, GiniInputAccessoryViewPresentable {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = title
        label.numberOfLines = 1
        label.enableScaling()
        label.font = configuration.textStyleFonts[.footnote]
        label.textColor = .giniColorScheme().text.secondary.uiColor()
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var textField: TextFieldActionsDisabled = {
        let textField = TextFieldActionsDisabled()
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
        imageView.tintColor = .giniColorScheme().placeholder.tint.uiColor()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.giniColorScheme().textField.border.uiColor().cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = Constants.cornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let title = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.withdiscount.expirydate.title",
                                                                 comment: "Due date")
    private let configuration = GiniBankConfiguration.shared

    private var viewModel: SkontoViewModel

    /// This is needed to avoid the circular reference between this element and its container
    private var privateInputAccessoryView: UIView?

    override var inputAccessoryView: UIView? {
        get {
            privateInputAccessoryView
        }

        set {
            privateInputAccessoryView = newValue
            textField.inputAccessoryView = newValue
        }
    }

    override var isFirstResponder: Bool {
        textField.isFirstResponder
    }

    weak var delegate: SkontoExpiryDateViewDelegate?

    init(viewModel: SkontoViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func becomeFirstResponder() -> Bool {
        textField.becomeFirstResponder()
    }

    override func resignFirstResponder() -> Bool {
        textField.resignFirstResponder()
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        isAccessibilityElement = true
        backgroundColor = .giniColorScheme().textField.background.uiColor()
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(textField)
        containerView.addSubview(calendarImageView)
        setupConstraints()
        textField.addTarget(self, action: #selector(textFieldTapped), for: .editingDidBegin)
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

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard self.bounds.contains(point), viewModel.isSkontoApplied else {
            return super.hitTest(point, with: event)
        }

        return textField
    }

    private func bindViewModel() {
        configure()
        viewModel.addStateChangeHandler { [weak self] in
            guard let self else { return }
            self.configure()
        }
    }

    private func configure() {
        let dueDateString = viewModel.dueDate.currentShortString
        accessibilityValue = "\(title): \(dueDateString)"
        let isSkontoApplied = viewModel.isSkontoApplied
        containerView.layer.borderWidth = isSkontoApplied ? 1 : 0
        textField.isUserInteractionEnabled = isSkontoApplied
        calendarImageView.isHidden = !isSkontoApplied
        textField.text = dueDateString
        configureAccessibility(isSkontoApplied)
    }

    private func configureAccessibility(_ isSkontoApplied: Bool) {
        if isSkontoApplied {
            accessibilityHint = Strings.accessibilityHint
            // Marks the element as editable and frequently updated for VoiceOver
            accessibilityTraits = [.updatesFrequently]
        } else {
            accessibilityHint = nil
            // Marks the element as static and disabled for VoiceOver
            accessibilityTraits = [.staticText, .notEnabled]
        }
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
        dateComponent.month = Constants.numberOfMonths
        let endDate = Calendar.current.date(byAdding: dateComponent, to: currentDate)
        datePicker.minimumDate = currentDate
        datePicker.maximumDate = endDate
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        textField.inputView = datePicker
    }

    @objc private func dateChanged(_ datePicker: UIDatePicker) {
        viewModel.setExpiryDate(datePicker.date)
    }

    @objc private func textFieldTapped() {
        delegate?.expiryDateTextFieldTapped()
    }
}

private extension SkontoExpiryDateView {
    enum Constants {
        static let padding: CGFloat = 12
        static let imageHorizontalPadding: CGFloat = 10
        static let imageSize: CGFloat = 22
        static let cornerRadius: CGFloat = 8
        static let numberOfMonths = 6
    }

    struct Strings {
        static let withoutDiscountHintKey: String = "ginibank.skonto.editableField.accessibility"
        static let withoutDiscountHintComment: String = "Double tap to edit"
        static let accessibilityHint = NSLocalizedStringPreferredGiniBankFormat(withoutDiscountHintKey,
                                                                                comment: withoutDiscountHintComment)
    }
}
