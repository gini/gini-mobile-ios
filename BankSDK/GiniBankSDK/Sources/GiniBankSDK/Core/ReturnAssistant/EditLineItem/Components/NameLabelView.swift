//
//  NameLabelView.swift
//  
//
//  Created by David Vizaknai on 07.03.2023.
//

import GiniCaptureSDK
import UIKit

protocol NameLabelViewDelegate: AnyObject {
    func nameLabelViewTextFieldDidChange(on: NameLabelView)
}

final class NameLabelView: UIView {
    private lazy var configuration = GiniBankConfiguration.shared
    weak var delegate: NameLabelViewDelegate?

    var text: String? {
        get {
            return nameTextField.text
        }
        set {
            nameTextField.text = newValue
            nameTextField.accessibilityValue = newValue
        }
    }

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = configuration.textStyleFonts[.footnote]
        label.textColor = .GiniBank.dark6
        label.adjustsFontForContentSizeCategory = true
        let title = NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.edit.name", comment: "Name")
        label.text = title
        label.accessibilityValue = title
        return label
    }()

    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.font = configuration.textStyleFonts[.body]
        textField.textColor = GiniColor(light: .GiniBank.dark1, dark: .GiniBank.light1).uiColor()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.adjustsFontForContentSizeCategory = true
        return textField
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = GiniColor(light: .GiniBank.light2, dark: .GiniBank.dark4).uiColor()
        layer.cornerRadius = Constants.cornerRadius
        addSubview(titleLabel)
        addSubview(nameTextField)

        self.nameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.padding),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.padding),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -Constants.padding),

            nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.labelPadding),
            nameTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.padding),
            nameTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.padding),
            nameTextField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.padding)
        ])
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        delegate?.nameLabelViewTextFieldDidChange(on: self)
    }
}

// MARK: - UITextFieldDelegate
extension NameLabelView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


private extension NameLabelView {
    enum Constants {
        static let cornerRadius: CGFloat = 8
        static let padding: CGFloat = 16
        static let labelPadding: CGFloat = 4
    }
}

