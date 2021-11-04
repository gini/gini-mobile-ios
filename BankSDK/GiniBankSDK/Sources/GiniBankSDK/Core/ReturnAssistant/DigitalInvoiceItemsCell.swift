//
//  DigitalInvoiceItemsCell.swift
//  GiniPayBank
//
//  Created by Maciej Trybilo on 11.12.19.
//

import Foundation
class ButtonWithImage: UIButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if imageView != nil {
            imageView?.contentMode = .scaleAspectFit
            imageEdgeInsets = UIEdgeInsets(top: 5, left: (bounds.width), bottom: 0, right: 25)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
        }
    }
}

struct DigitalInvoiceItemsCellViewModel {
    
    let itemsLabelText: String
    let itemsLabelAccessibilityLabelText: String
    
    init(invoice: DigitalInvoice) {
        
        itemsLabelText = String.localizedStringWithFormat(DigitalInvoiceStrings.items.localizedGiniPayFormat,
                                                          invoice.numSelected,
                                                          invoice.numTotal)
        
        itemsLabelAccessibilityLabelText = String.localizedStringWithFormat(DigitalInvoiceStrings.itemsAccessibilityLabel.localizedGiniPayFormat,
                                                                            invoice.numSelected,
                                                                            invoice.numTotal)
    }
}

class DigitalInvoiceItemsCell: UITableViewCell {
    
    var returnAssistantConfiguration: ReturnAssistantConfiguration? {
        didSet {
            setup()
        }
    }
    
    private var itemsLabel: UILabel? = UILabel()
    
    var viewModel: DigitalInvoiceItemsCellViewModel? {
        didSet {
            itemsLabel?.text = viewModel?.itemsLabelText
            itemsLabel?.accessibilityLabel = viewModel?.itemsLabelAccessibilityLabelText
        }
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
        backgroundColor = UIColor.from(giniColor: returnAssistantConfiguration?.digitalInvoiceBackgroundColor ?? ReturnAssistantConfiguration.shared.digitalInvoiceBackgroundColor)
        itemsLabel?.translatesAutoresizingMaskIntoConstraints = false
        itemsLabel?.font = returnAssistantConfiguration?.digitalInvoiceItemsSectionHeaderTextFont ??
            ReturnAssistantConfiguration.shared.digitalInvoiceItemsSectionHeaderTextFont
        itemsLabel?.textColor = UIColor.from(giniColor:returnAssistantConfiguration?.digitalInvoiceItemsSectionHeaderTextColor ??
                                                ReturnAssistantConfiguration.shared.digitalInvoiceItemsSectionHeaderTextColor)
        
        contentView.addSubview(itemsLabel ?? UILabel())
        
        itemsLabel?.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        itemsLabel?.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
    
}
