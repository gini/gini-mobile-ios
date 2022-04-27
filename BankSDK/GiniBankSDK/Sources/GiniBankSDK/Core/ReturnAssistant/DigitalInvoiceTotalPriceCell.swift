//
//  DigitalInvoiceTotalPriceCell.swift
// GiniBank
//
//  Created by Maciej Trybilo on 11.12.19.
//

import Foundation
import UIKit

protocol DigitalInvoiceTotalPriceCellDelegate: AnyObject {
    func didTapAddArticleButton()
}

class DigitalInvoiceTotalPriceCell: UITableViewCell {
    weak var delegate: DigitalInvoiceTotalPriceCellDelegate?
    
    var returnAssistantConfiguration: ReturnAssistantConfiguration? {
        didSet {
            setup()
            updateTotalPriceLabel()
        }
    }
    
    private var totalCaptionLabel = UILabel()
    private var totalPriceLabel = UILabel()
    private var addArticleButton = UIButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    var totalPrice: Price? {
        didSet {
            updateTotalPriceLabel()
        }
    }
    
    private func setup() {
        
        selectionStyle = .none
        
        totalCaptionLabel.text = .ginibankLocalized(resource: DigitalInvoiceStrings.totalCaptionLabel)
        totalCaptionLabel.font = returnAssistantConfiguration?.digitalInvoiceTotalCaptionLabelFont ?? ReturnAssistantConfiguration.shared.digitalInvoiceTotalCaptionLabelFont
        
        totalCaptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(totalCaptionLabel)
        
        totalCaptionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 55).isActive = true
        totalCaptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        totalCaptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    
        totalPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(totalPriceLabel)
        
        totalPriceLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 55).isActive = true
        totalPriceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        totalPriceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        backgroundColor = UIColor.from(giniColor: returnAssistantConfiguration?.digitalInvoiceBackgroundColor ?? ReturnAssistantConfiguration.shared.digitalInvoiceBackgroundColor)
        
        contentView.addSubview(addArticleButton)
        addArticleButton.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
        addArticleButton.setTitle(.ginibankLocalized(resource: DigitalInvoiceStrings.addArticleButton), for: .normal)
        addArticleButton.setImage(prefferedImage(named: "plus-icon"), for: .normal)
        addArticleButton.setTitleColor(returnAssistantConfiguration?.digitalInvoiceFooterAddArticleButtonTintColor ?? ReturnAssistantConfiguration.shared.digitalInvoiceFooterAddArticleButtonTintColor, for: .normal)
        addArticleButton.tintColor = returnAssistantConfiguration?.digitalInvoiceFooterAddArticleButtonTintColor ?? ReturnAssistantConfiguration.shared.digitalInvoiceFooterAddArticleButtonTintColor
        addArticleButton.semanticContentAttribute = .forceRightToLeft
        addArticleButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 2, right: 0)
        addArticleButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            addArticleButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            addArticleButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -22)
        ])
    }
    
    @objc func didTapAddButton() {
        delegate?.didTapAddArticleButton()
    }
    
    private func updateTotalPriceLabel() {
        guard let totalPrice = totalPrice else { return }
        
        guard let totalPriceString = totalPrice.string else { return }
        
        let attributedString =
            NSMutableAttributedString(string: totalPriceString,
                                      attributes: [NSAttributedString.Key.foregroundColor: returnAssistantConfiguration?.digitalInvoiceTotalPriceColor ?? ReturnAssistantConfiguration.shared.digitalInvoiceTotalPriceColor,
                                                   NSAttributedString.Key.font: returnAssistantConfiguration?.digitalInvoiceTotalPriceMainUnitFont ?? ReturnAssistantConfiguration.shared.digitalInvoiceTotalPriceMainUnitFont])
        
        attributedString.setAttributes([NSAttributedString.Key.foregroundColor: returnAssistantConfiguration?.digitalInvoiceTotalPriceColor ?? ReturnAssistantConfiguration.shared.digitalInvoiceTotalPriceColor,
                                        NSAttributedString.Key.baselineOffset: 9,
                                        NSAttributedString.Key.font: returnAssistantConfiguration?.digitalInvoiceTotalPriceFractionalUnitFont ?? ReturnAssistantConfiguration.shared.digitalInvoiceTotalPriceFractionalUnitFont],
                                       range: NSRange(location: totalPriceString.count - 3, length: 3))
        
        totalPriceLabel.attributedText = attributedString
        
        let format = DigitalInvoiceStrings.totalAccessibilityLabel.localizedGiniBankFormat
        totalPriceLabel.accessibilityLabel = String.localizedStringWithFormat(format,
                                                                              totalPriceString)
    }
}
