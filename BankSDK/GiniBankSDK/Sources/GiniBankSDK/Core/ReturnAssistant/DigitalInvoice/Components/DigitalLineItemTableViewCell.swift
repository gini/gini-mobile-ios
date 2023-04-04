//
//  DigitalLineItemTableViewCell.swift
// GiniBank
//
//  Created by Maciej Trybilo on 22.11.19.
//

import UIKit
import GiniCaptureSDK

protocol DigitalLineItemTableViewCellDelegate: AnyObject {
    func modeSwitchValueChanged(cell: DigitalLineItemTableViewCell, lineItemViewModel: DigitalLineItemTableViewCellViewModel)
    func editTapped(cell: DigitalLineItemTableViewCell, lineItemViewModel: DigitalLineItemTableViewCellViewModel)
}

class DigitalLineItemTableViewCell: UITableViewCell {
    static let reuseIdentifier = "DigitalLineItemTableViewCell"
    @IBOutlet weak var modeSwitch: UISwitch!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var unitPriceLabel: UILabel!

    private let configuration = GiniBankConfiguration.shared

    var viewModel: DigitalLineItemTableViewCellViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }

            if let nameLabelString = viewModel.nameLabelString {
                nameLabel.text = nameLabelString
                nameLabel.accessibilityValue = nameLabelString
            }

            if let priceString = viewModel.totalPriceString {
                priceLabel.text = priceString
                priceLabel.accessibilityValue = priceString
                let format = DigitalInvoiceStrings.totalAccessibilityLabel.localizedGiniBankFormat
                priceLabel.accessibilityLabel = String.localizedStringWithFormat(format, priceString)
            }

            unitPriceLabel.text = viewModel.unitPriceString
            unitPriceLabel.accessibilityValue = viewModel.unitPriceString

            modeSwitch.addTarget(self, action: #selector(modeSwitchValueChange(sender:)), for: .valueChanged)

            modeSwitch.onTintColor = viewModel.modeSwitchTintColor

            [nameLabel, editButton, unitPriceLabel, priceLabel].forEach { view in
                view?.alpha = viewModel.lineItem.selectedState == .selected ? 1 : 0.5
                editButton.isEnabled = viewModel.lineItem.selectedState == .selected
            }

            switch viewModel.lineItem.selectedState {
            case .selected:
                modeSwitch.isOn = true
            case .deselected:
                modeSwitch.isOn = false
            }

            setup()
        }
    }
    
    weak var delegate: DigitalLineItemTableViewCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    private func setup() {
        backgroundColor = GiniColor(light: .GiniBank.light1, dark: .GiniBank.dark3).uiColor()
        selectionStyle = .none

        if viewModel?.index == 0 {
            clipsToBounds = true
            layer.cornerRadius = 8
            layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]

            separatorView.isHidden = true
        }

        editButton.contentHorizontalAlignment = .right
        editButton.titleLabel?.adjustsFontForContentSizeCategory = true
        let editTitle: String = .ginibankLocalized(resource: DigitalInvoiceStrings.lineItemEditButtonTitle)
        editButton.setTitle(editTitle, for: .normal)
        editButton.accessibilityValue = editTitle

        separatorView.backgroundColor = GiniColor(light: .GiniBank.light3, dark: .GiniBank.dark4).uiColor()
        unitPriceLabel.textColor = .GiniBank.dark7
        editButton.setTitleColor(.GiniBank.accent1, for: .normal)
        nameLabel.textColor = GiniColor(light: .GiniBank.dark1, dark: .GiniBank.light1).uiColor()

        priceLabel.font = configuration.textStyleFonts[.body]
        nameLabel.font = configuration.textStyleFonts[.body]
        unitPriceLabel.font = configuration.textStyleFonts[.body]
        editButton.titleLabel?.font = configuration.textStyleFonts[.body]
    }
    
    @objc func modeSwitchValueChange(sender: UISwitch) {
        if let viewModel = viewModel {
            delegate?.modeSwitchValueChanged(cell: self, lineItemViewModel: viewModel)
        }
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
        if let viewModel = viewModel {
            delegate?.editTapped(cell: self, lineItemViewModel: viewModel)
        }
    }
}
