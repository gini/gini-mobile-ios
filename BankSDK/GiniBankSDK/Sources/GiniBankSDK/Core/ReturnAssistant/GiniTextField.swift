//
//  GiniTextField.swift
// GiniBank
//
//  Created by Maciej Trybilo on 18.12.19.
//

import UIKit

protocol GiniTextFieldDelegate: AnyObject {
    
    func textDidChange(_ giniTextField: GiniTextField)
}

class GiniTextField: UIView {

    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    private let textFieldContainer = UIStackView()
    private let prefixLabel = UILabel()
    private let separatorView = UILabel()
    private let textField = UITextField()
    private let underscoreView = UIView()
    
    enum TextFieldType: Int {
        case amountFieldTag
        case other
    }
    
    weak var delegate: GiniTextFieldDelegate?
    
    var textFieldType: TextFieldType = .other
    var shouldAllowLetters = false
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    var titleFont: UIFont {
        
        set {
            titleLabel.font = newValue
        }
        
        get {
            return titleLabel.font
        }
    }
    
    var titleTextColor: UIColor {
        
        set {
            titleLabel.textColor = newValue
        }
        
        get {
            return titleLabel.textColor
        }
    }
    
    var text: String? {
        
        set {
            textField.text = newValue
        }
        
        get {
            return textField.text
        }
    }
    
    var prefixText: String? {
        
        didSet {
            
            if prefixText != nil {
                
                prefixLabel.isHidden = false
                separatorView.isHidden = false
                
            } else {
                prefixLabel.isHidden = true
                separatorView.isHidden = true
            }
            
            prefixLabel.text = prefixText
        }
    }
    
    var textFont: UIFont {
        
        set {
            textField.font = newValue
            prefixLabel.font = newValue
        }
        
        get {
            return prefixLabel.font
        }
    }
    
    var textColor: UIColor {
        
        set {
            textField.textColor = newValue
            prefixLabel.textColor = newValue
        }
        
        get {
            return prefixLabel.textColor
        }
    }
    
    var textFieldFirstBaselineAnchor: NSLayoutYAxisAnchor {
        return textField.firstBaselineAnchor
    }
    
    var textFieldLastBaselineAnchor: NSLayoutYAxisAnchor {
        return textField.lastBaselineAnchor
    }
    
    var keyboardType: UIKeyboardType {
        
        set {
            textField.keyboardType = newValue
        }
        
        get {
            return textField.keyboardType
        }
    }
    
    var underscoreColor: UIColor? = nil
    
    private func underscoreColor(for isFirstResponder: Bool) -> UIColor {
        
        if isFirstResponder {
            return underscoreColor ?? tintColor
        } else {
            if #available(iOS 13.0, *) {
                return .separator
            } else {
                return .gray
            }
        }
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        textFieldContainer.translatesAutoresizingMaskIntoConstraints = false
        prefixLabel.translatesAutoresizingMaskIntoConstraints = false
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        underscoreView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stackView)
        
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        stackView.axis = .vertical
        stackView.spacing = 10
        
        separatorView.widthAnchor.constraint(equalToConstant: 1).isActive = true
        if #available(iOS 13.0, *) {
            separatorView.backgroundColor = .separator
        } else {
            separatorView.backgroundColor = .gray
        }
        
        prefixLabel.setContentHuggingPriority(.required, for: .horizontal)
        prefixLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        textFieldContainer.axis = .horizontal
        textFieldContainer.spacing = 5
        textFieldContainer.addArrangedSubview(prefixLabel)
        textFieldContainer.addArrangedSubview(separatorView)
        textFieldContainer.addArrangedSubview(textField)
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(textFieldContainer)
        stackView.addArrangedSubview(underscoreView)
        
        textField.delegate = self
        textField.clearButtonMode = .whileEditing
        
        underscoreView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        underscoreView.backgroundColor = underscoreColor(for: false)
        
        accessibilityElements = [titleLabel, prefixLabel, textField]
    }
    
    override func resignFirstResponder() -> Bool {
        textField.resignFirstResponder()
    }
    
    override func becomeFirstResponder() -> Bool {
        textField.becomeFirstResponder()
    }
}

extension GiniTextField: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        underscoreView.backgroundColor = underscoreColor(for: true)
        if textFieldType == .amountFieldTag, let text = textField.text, text.count > 0 {
            let trimmedText = textField.text?.trimmingCharacters(in: .whitespaces)
            textField.text = trimmedText
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        underscoreView.backgroundColor = underscoreColor(for: false)
        delegate?.textDidChange(self)
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        guard let text = textField.text, !text.isEmpty else { return false }
        return true
    }
    
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        if shouldAllowLetters { return true }
        if textFieldType == .amountFieldTag,
           let text = textField.text,
           let textRange = Range(range, in: text) {
                let updatedText = text.replacingCharacters(in: textRange, with: string)
                if let newAmount = Price.formatAmountString(newText: updatedText) {
                     // Save the selected text range to restore the cursor position after replacing the text
                     let selectedRange = textField.selectedTextRange
                     textField.text = newAmount
                     // Move the cursor position after the inserted character
                     if let selectedRange = selectedRange {
                         let countDelta = newAmount.count - text.count
                         let offset = countDelta == 0 ? 1 : countDelta
                         textField.moveSelectedTextRange(from: selectedRange.start, to: offset)
                     }
                }
            return false
        } else {
            guard CharacterSet(charactersIn: "0123456789,.").isSuperset(of: CharacterSet(charactersIn: string)) else {
                return false
            }
            return true
        }
    }
}

public extension UITextField {
    
    func moveSelectedTextRange(from position: UITextPosition, to offset: Int) {
        if let newSelectedRangeFromTo = self.position(from: position, offset: offset),
           let newSelectedRange = self.textRange(from: newSelectedRangeFromTo, to: newSelectedRangeFromTo) {
            self.selectedTextRange = newSelectedRange
        }
    }
}
