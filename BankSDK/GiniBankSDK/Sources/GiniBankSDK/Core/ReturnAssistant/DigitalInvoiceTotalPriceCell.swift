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
    private let margin: CGFloat = 5

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
    
    private func configureAddArticleButton() {
        addArticleButton.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
        addArticleButton.setTitle(.ginibankLocalized(resource: DigitalInvoiceStrings.addArticleButton), for: .normal)
        addArticleButton.setImage(prefferedImage(named: "plus-icon"), for: .normal)
        addArticleButton.setTitleColor(returnAssistantConfiguration?.digitalInvoiceFooterAddArticleButtonTintColor ?? ReturnAssistantConfiguration.shared.digitalInvoiceFooterAddArticleButtonTintColor, for: .normal)
        addArticleButton.tintColor = returnAssistantConfiguration?.digitalInvoiceFooterAddArticleButtonTintColor ?? ReturnAssistantConfiguration.shared.digitalInvoiceFooterAddArticleButtonTintColor
        addArticleButton.titleLabel?.font = returnAssistantConfiguration?.digitalInvoiceFooterAddArticleButtonTitleFont ?? ReturnAssistantConfiguration.shared.digitalInvoiceFooterAddArticleButtonTitleFont
        addArticleButton.semanticContentAttribute = .forceRightToLeft
        addArticleButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 2, right: 0)
        addArticleButton.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
        } else {
            let labelAndIconMargin: CGFloat = 10
            addArticleButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12 + labelAndIconMargin, bottom: 2, right: 12)
            addArticleButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -labelAndIconMargin, bottom: 2, right: labelAndIconMargin)
        }
        
        NSLayoutConstraint.activate([
            addArticleButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            addArticleButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -22)
        ])
    }
    
    private func configureTotalPriceLabel() {
        totalPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        totalPriceLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 55).isActive = true
        totalPriceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        totalPriceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        totalPriceLabel.leadingAnchor.constraint(greaterThanOrEqualTo: totalCaptionLabel.trailingAnchor, constant: margin).isActive = true
    }
    
    private func configureTotalCaptionLabel() {
        totalCaptionLabel.text = .ginibankLocalized(resource: DigitalInvoiceStrings.totalCaptionLabel)
        totalCaptionLabel.font = returnAssistantConfiguration?.digitalInvoiceTotalCaptionLabelFont ?? ReturnAssistantConfiguration.shared.digitalInvoiceTotalCaptionLabelFont
        totalCaptionLabel.textColor = UIColor.from(giniColor: returnAssistantConfiguration?.digitalInvoiceTotalCaptionLabelTextColor ?? ReturnAssistantConfiguration.shared.digitalInvoiceTotalCaptionLabelTextColor)
        
        totalCaptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        totalCaptionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 55).isActive = true
        totalCaptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        totalCaptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    private func setup() {
        
        selectionStyle = .none
        backgroundColor = UIColor.from(giniColor: returnAssistantConfiguration?.digitalInvoiceBackgroundColor ?? ReturnAssistantConfiguration.shared.digitalInvoiceBackgroundColor)
        
        contentView.addSubview(totalCaptionLabel)
        contentView.addSubview(totalPriceLabel)
        contentView.addSubview(addArticleButton)

        configureTotalCaptionLabel()
        configureTotalPriceLabel()
        configureAddArticleButton()
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
