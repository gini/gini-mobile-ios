//
//  TextFieldWithLabelView.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniUtilites

public final class TextFieldWithLabelView: UIView {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontProvider().font(for: .footnote)
        label.enableScaling()
        return label
    }()

    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.adjustsFontForContentSizeCategory = true
        return textField
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupConstraints()
    }

    private func setupView() {
        addSubview(titleLabel)
        addSubview(textField)
    }
    
    func configure(configuration: TextFieldConfiguration) {
        self.layer.cornerRadius = configuration.cornerRadius
        self.layer.borderWidth = configuration.borderWidth
        self.layer.borderColor = configuration.borderColor.cgColor
        self.backgroundColor = configuration.backgroundColor
        self.textField.textColor = isUserInteractionEnabled ? configuration.textColor : configuration.placeholderForegroundColor
        self.textField.font = configuration.textFont
        self.textField.attributedPlaceholder = NSAttributedString(string: "",
                                                                  attributes: [.foregroundColor: configuration.placeholderForegroundColor])
        
        self.titleLabel.textColor = configuration.placeholderForegroundColor
    }
    
    func customConfigure(labelTitle: NSAttributedString) {
        titleLabel.attributedText = labelTitle
    }

    func customConfigure(labelTitle: String) {
        titleLabel.text = labelTitle
    }

    func setInputAccesoryView(view: UIView?) {
        textField.inputAccessoryView = view
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.topBottomPadding),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.leftRightPadding),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -Constants.leftRightPadding),

            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.textFieldTopPadding),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.leftRightPadding),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.leftRightPadding),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.topBottomPadding)
        ])
    }

    func setKeyboardType(keyboardType: UIKeyboardType) {
        textField.keyboardType = keyboardType
    }
}

public extension TextFieldWithLabelView {
    var text: String? {
        get {
            return textField.text
        }
        set {
            textField.text = newValue
            textField.accessibilityValue = newValue
        }
    }

    var hasText: Bool {
        textField.hasText
    }

    var isReallyEmpty: Bool {
        return textField.isReallyEmpty
    }

    override var tag: Int {
        get {
            return textField.tag
        }
        set {
            textField.tag = newValue
        }
    }

    var delegate: UITextFieldDelegate? {
        get {
            return textField.delegate
        }
        set {
            textField.delegate = newValue
        }
    }

    override func endEditing(_ force: Bool) -> Bool {
        textField.endEditing(true)
    }

    override func resignFirstResponder() -> Bool {
        textField.resignFirstResponder()
    }
}

private extension TextFieldWithLabelView {
    enum Constants {
        static let leftRightPadding: CGFloat = 12
        static let topBottomPadding: CGFloat = 8
        static let textFieldTopPadding: CGFloat = 0
    }
}


#if DEBUG
@available(iOS 17, *)
#Preview {
    let frame = CGRect(x: 16, y: 200, width: 300, height: 60)
    let textFieldWithLabelView = TextFieldWithLabelView(frame: frame)
    let configuration = TextFieldConfiguration(backgroundColor: .systemBackground,
                                               borderColor: .lightGray,
                                               textColor: .black,
                                               textFont: FontProvider().font(for: .body1),
                                               cornerRadius: 12.0,
                                               borderWidth: 1.0,
                                               placeholderForegroundColor: .lightGray)
                                               
    textFieldWithLabelView.configure(configuration: configuration)
    textFieldWithLabelView.customConfigure(labelTitle: "IBAN")
    
    return textFieldWithLabelView
}
#endif
