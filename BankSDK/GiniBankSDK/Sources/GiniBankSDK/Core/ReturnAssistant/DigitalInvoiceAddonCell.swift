//
//  DigitalInvoiceAddonCell.swift
// GiniBank
//
//  Created by Alpár Szotyori on 02.09.20.
//

import Foundation
import UIKit
import GiniCaptureSDK
class DigitalInvoiceAddonCell: UITableViewCell {
    
    var returnAssistantConfiguration : ReturnAssistantConfiguration? {
        didSet {
           updateAddonPriceLabel()
           updateAddonNameLabel()
        }
    }
    
    private var addonNameLabel = UILabel()
    
    private var addonPriceLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    var addonName: String = "" {
        didSet {
            updateAddonNameLabel()
        }
    }
    
    var addonPrice: Price? {
        didSet {
            updateAddonPriceLabel()
        }
    }
    
    private func setup() {
        
        selectionStyle = .none
        
        addonPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(addonPriceLabel)
        
        Constraints.active(item: addonPriceLabel, attr: .top, relatedBy: .equal, to: contentView, attr: .top, constant: 10)
        Constraints.active(item: addonPriceLabel, attr: .trailing, relatedBy: .equal, to: contentView, attr: .trailing, constant: -16)
        Constraints.active(item: addonPriceLabel, attr: .bottom, relatedBy: .equal, to: contentView, attr: .bottom)
        
        addonNameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(addonNameLabel)
        
        Constraints.active(item: addonNameLabel, attr: .trailing, relatedBy: .equal, to: contentView, attr: .trailing, constant: -100)
        Constraints.active(item: addonNameLabel, attr: .firstBaseline, relatedBy: .equal, to: addonPriceLabel, attr: .firstBaseline)
    }
    
    private func updateAddonPriceLabel() {
        let config = returnAssistantConfiguration ?? ReturnAssistantConfiguration.shared
        guard let addonPrice = addonPrice else { return }
        guard let addonPriceString = addonPrice.string else { return }

        let attributedString =
            NSMutableAttributedString(string: addonPriceString,
                                      attributes: [NSAttributedString.Key.foregroundColor: config.digitalInvoiceAddonPriceColor,
                                                   NSAttributedString.Key.font: config.digitalInvoiceAddonPriceMainUnitFont])
        attributedString.setAttributes([NSAttributedString.Key.foregroundColor: config.digitalInvoiceAddonPriceColor,
                                        NSAttributedString.Key.baselineOffset: 5,
                                        NSAttributedString.Key.font: config.digitalInvoiceAddonPriceFractionalUnitFont],
                                       range: NSRange(location: addonPriceString.count - 3, length: 3))
        
        addonPriceLabel.attributedText = attributedString
    }
    
    private func updateAddonNameLabel() {
        let config = returnAssistantConfiguration ?? ReturnAssistantConfiguration.shared
        let attributedString =
            NSMutableAttributedString(string: "\(addonName):",
                                      attributes: [NSAttributedString.Key.font: config.digitalInvoiceAddonLabelFont,
                                                   NSAttributedString.Key.foregroundColor: config.digitalInvoiceAddonLabelColor.uiColor()])
        
        addonNameLabel.attributedText = attributedString
    }
}
