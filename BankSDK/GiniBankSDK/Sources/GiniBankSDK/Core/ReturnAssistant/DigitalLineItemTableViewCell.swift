//
//  DigitalLineItemTableViewCell.swift
// GiniBank
//
//  Created by Maciej Trybilo on 22.11.19.
//

import UIKit
import GiniCaptureSDK

struct DigitalLineItemViewModel {
    
    var lineItem: DigitalInvoice.LineItem
    let returnAssistantConfiguration : ReturnAssistantConfiguration

    let index: Int
    let invoiceNumTotal: Int
    let invoiceLineItemsCount: Int
    
    var name: String? {
        return lineItem.name
    }
    
    var quantityString: String {
        return String.localizedStringWithFormat(DigitalInvoiceStrings.lineItemQuantity.localizedGiniBankFormat,
                                                lineItem.quantity)
    }
    
    var quantityFont: UIFont {
        return returnAssistantConfiguration.digitalInvoiceLineItemQuantityFont
    }
    
    var quantityColor: UIColor {
        switch lineItem.selectedState {
        case .selected:
            return UIColor.from(giniColor: returnAssistantConfiguration.digitalInvoiceLineItemQuantityColor)
        case .deselected:
            if #available(iOS 13.0, *) {
                return .secondaryLabel
            } else {
                return .gray
            }
        }
    }
    
    var outilneViewColor: UIColor {
        switch lineItem.selectedState {
        case .selected:
            return returnAssistantConfiguration.lineItemTintColor
        case .deselected:
            return UIColor.gray
        }
    }
    
    var countLabelColor: UIColor {
        return returnAssistantConfiguration.lineItemCountLabelColor
    }
    
    var countLabelFont: UIFont {
        return returnAssistantConfiguration.lineItemCountLabelFont
    }
    
    var totalPriceString: String? {
        return lineItem.totalPrice.string
    }
    
    var modeSwitchTintColor: UIColor {
        
        switch lineItem.selectedState {
        case .selected:
            return returnAssistantConfiguration.lineItemTintColor
        case .deselected:
            return .white
        }
    }
    
    var editButtonTintColor: UIColor {
        switch lineItem.selectedState {
        case .selected:
            return returnAssistantConfiguration.lineItemTintColor
        case .deselected:
            if #available(iOS 13.0, *) {
                return .secondaryLabel
            } else {
                return .gray
            }
        }
    }
    
    var deleButtonTintColor: UIColor {
        return returnAssistantConfiguration.lineItemTintColor
    }
    
    var primaryTextColor: UIColor {
        switch lineItem.selectedState {
        case .selected:
            if #available(iOS 13.0, *) {
                return .label
            } else {
                return .black
            }
        case .deselected:
            if #available(iOS 13.0, *) {
                return .secondaryLabel
            } else {
                return .gray
            }
        }
    }
    
    var priceMainUnitFont: UIFont {
        return returnAssistantConfiguration.digitalInvoiceLineItemPriceMainUnitFont
    }
    
    var priceFractionalUnitFont: UIFont {
        return returnAssistantConfiguration.digitalInvoiceLineItemPriceFractionalUnitFont
    }
    
    var nameLabelFont: UIFont {
        return returnAssistantConfiguration.digitalInvoiceLineItemNameFont
    }
    
    var editButtonTitleFont: UIFont {
        return returnAssistantConfiguration.digitalInvoiceLineItemEditButtonTitleFont
    }
    
    var cellShadowColor: UIColor {
        switch lineItem.selectedState {
        case .selected:
            return .black
        case .deselected:
            return .clear
        }
    }
    
    var cellBorderColor: UIColor {
        switch lineItem.selectedState {
        case .selected:
            return returnAssistantConfiguration.lineItemTintColor
        case .deselected:
            if #available(iOS 13.0, *) {
                return .secondaryLabel
            } else {
                return .gray
            }
        }
    }
}

protocol DigitalLineItemTableViewCellDelegate: AnyObject {
    func modeSwitchValueChanged(cell: DigitalLineItemTableViewCell, viewModel: DigitalLineItemViewModel)
    func editTapped(cell: DigitalLineItemTableViewCell, viewModel: DigitalLineItemViewModel)
    func deleteTapped(cell: DigitalLineItemTableViewCell, viewModel: DigitalLineItemViewModel)
}

class DigitalLineItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var shadowCastView: UIView!
    @IBOutlet weak var modeSwitch: UISwitch!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var outilneView: UIView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    var viewModel: DigitalLineItemViewModel? {
        didSet {
            
            nameLabel.text = viewModel?.name
            quantityLabel.text = viewModel?.quantityString
            quantityLabel.font = viewModel?.quantityFont
            
            quantityLabel.textColor = viewModel?.quantityColor
            outilneView.layer.borderColor = viewModel?.outilneViewColor.cgColor

            if let viewModel = viewModel, let priceString = viewModel.totalPriceString {
                
                let attributedString =
                    NSMutableAttributedString(string: priceString,
                                              attributes: [NSAttributedString.Key.foregroundColor: viewModel.primaryTextColor,
                                                           NSAttributedString.Key.font: viewModel.priceMainUnitFont])
                
                attributedString.setAttributes([NSAttributedString.Key.foregroundColor: viewModel.primaryTextColor,
                                                NSAttributedString.Key.baselineOffset: 6,
                                                NSAttributedString.Key.font: viewModel.priceFractionalUnitFont],
                                               range: NSRange(location: priceString.count - 3, length: 3))
                
                priceLabel.attributedText = attributedString
                
                let format = DigitalInvoiceStrings.totalAccessibilityLabel.localizedGiniBankFormat
                priceLabel.accessibilityLabel = String.localizedStringWithFormat(format, priceString)
                
                countLabel.text = String.localizedStringWithFormat(DigitalInvoiceStrings.items.localizedGiniBankFormat,
                                                                   viewModel.index.advanced(by: 1),
                                                                   viewModel.invoiceLineItemsCount)
                countLabel.font = viewModel.countLabelFont
                countLabel.textColor = viewModel.countLabelColor
                modeSwitch.isHidden = viewModel.lineItem.isUserInitiated
                deleteButton.isHidden = !viewModel.lineItem.isUserInitiated
                deleteButton.tintColor = viewModel.deleButtonTintColor
            }
            
            modeSwitch.addTarget(self, action: #selector(modeSwitchValueChange(sender:)), for: .valueChanged)
            modeSwitch.onTintColor = viewModel?.modeSwitchTintColor
            
            editButton.setTitleColor(viewModel?.editButtonTintColor ?? .black, for: .normal)
            editButton.titleLabel?.font = viewModel?.editButtonTitleFont
            editButton.tintColor = viewModel?.editButtonTintColor ?? .black
            
            editButton.setTitle(.ginibankLocalized(resource: DigitalInvoiceStrings.lineItemEditButtonTitle), for: .normal)
            
            nameLabel.textColor = viewModel?.primaryTextColor

            nameLabel.font = viewModel?.nameLabelFont
            
            
            if let viewModel = viewModel {
                switch viewModel.lineItem.selectedState {
                case .selected:
                    modeSwitch.isOn = true
                case .deselected:
                    modeSwitch.isOn = false
                }
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
        backgroundColor = UIColor.from(giniColor: viewModel?.returnAssistantConfiguration.digitalInvoiceBackgroundColor ?? ReturnAssistantConfiguration.shared.digitalInvoiceBackgroundColor)
        selectionStyle = .none
        
        outilneView.layer.borderWidth = 2
        outilneView.layer.cornerRadius = 5
        
        shadowCastView.layer.backgroundColor = UIColor.from(giniColor: viewModel?.returnAssistantConfiguration.digitalInvoiceLineItemsBackgroundColor ?? ReturnAssistantConfiguration.shared.digitalInvoiceLineItemsBackgroundColor).cgColor
    }
    
    @objc func modeSwitchValueChange(sender: UISwitch) {
        if let viewModel = viewModel {
            delegate?.modeSwitchValueChanged(cell: self, viewModel: viewModel)
        }
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        
        if let viewModel = viewModel {
            delegate?.deleteTapped(cell: self, viewModel: viewModel)
        }
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
        
        if let viewModel = viewModel {
            delegate?.editTapped(cell: self, viewModel: viewModel)
        }
    }
}
