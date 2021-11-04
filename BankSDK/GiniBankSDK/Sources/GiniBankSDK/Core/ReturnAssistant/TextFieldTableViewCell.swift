//
//  TextFieldTableViewCell.swift
// GiniBank
//
//  Created by Maciej Trybilo on 20.11.19.
//

import UIKit

protocol TextFieldTableViewCellDelegate: AnyObject {
    func valueDidChange(viewModel: TextFieldTableViewCellViewModel)
}

struct TextFieldTableViewCellViewModel {
    
    let id: Int?
    let placeholder: String?
    let text: String?
}

class TextFieldTableViewCell: UITableViewCell {
    
    private let textField = UITextField(frame: CGRect.zero)
    
    private var id: Int?
    
    var viewModel: TextFieldTableViewCellViewModel {
        set {
            id = newValue.id
            textField.placeholder = newValue.placeholder
            textField.text = newValue.text
        }
        
        get {
            return TextFieldTableViewCellViewModel(id: id,
                                                   placeholder: textField.placeholder,
                                                   text: textField.text)
        }
    }
    
    weak var delegate: TextFieldTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    private func setup() {
        
        selectionStyle = .none
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(textField)
        
        textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        textField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4).isActive = true
        textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -3).isActive = true
        
        textField.heightAnchor.constraint(equalToConstant: 49).isActive = true
        
        textField.borderStyle = .roundedRect
        
        textField.font = UIFont.systemFont(ofSize: 14)
        
        textField.delegate = self
    }
}

extension TextFieldTableViewCell: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.valueDidChange(viewModel: viewModel)
    }
}
