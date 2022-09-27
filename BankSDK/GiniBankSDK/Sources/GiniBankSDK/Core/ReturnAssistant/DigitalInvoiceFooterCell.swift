//
//  DigitalInvoiceFooterCell.swift
// GiniBank
//
//  Created by Maciej Trybilo on 11.12.19.
//

import UIKit
class DigitalInvoiceFooterCell: UITableViewCell {
    var returnAssistantConfiguration: ReturnAssistantConfiguration? {
        didSet {
            updateUI()
        }
    }
    
    let messageLabel = UILabel()
    let payButton = UIButton(type: .system)
    let skipButton = UIButton(type: .system)
    
    private var totalCaptionExplanationLabel = UILabel()
    private var payButtonBottomConstraint = NSLayoutConstraint()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupView()
        self.updateUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    var setupConstraints = false
    
    private func setupView() {
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        totalCaptionExplanationLabel.translatesAutoresizingMaskIntoConstraints = false
        payButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(totalCaptionExplanationLabel)
        contentView.addSubview(messageLabel)
        contentView.addSubview(payButton)
        let payButtonHeight: CGFloat = 48
        let margin: CGFloat = 16
        let multiplier = 322 / bounds.height
        let contentHeight = bounds.height * multiplier
        contentView.heightAnchor.constraint(equalToConstant: contentHeight).isActive = true
        
        totalCaptionExplanationLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2).isActive = true
        totalCaptionExplanationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        let messageLabelYConstraint = NSLayoutConstraint(item: messageLabel, attribute: .centerY, relatedBy: .equal, toItem: self.contentView, attribute: .centerY, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([messageLabelYConstraint])
        messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40).isActive = true
        messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40).isActive = true
        payButton.heightAnchor.constraint(equalToConstant: payButtonHeight).isActive = true
        payButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin).isActive = true
        payButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin).isActive = true
        payButtonBottomConstraint = payButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -28)
        payButtonBottomConstraint.isActive = true
        
    }

    private func updateUI() {
        let configuration = returnAssistantConfiguration ?? ReturnAssistantConfiguration.shared
        selectionStyle = .none
        backgroundColor = UIColor.from(giniColor: configuration.digitalInvoiceBackgroundColor)
        totalCaptionExplanationLabel.text = .ginibankLocalized(resource: DigitalInvoiceStrings.totalExplanationLabel)
        totalCaptionExplanationLabel.font = configuration.digitalInvoiceTotalExplanationLabelFont
        totalCaptionExplanationLabel.textColor = UIColor.from(giniColor: configuration.digitalInvoiceTotalExplanationLabelTextColor)
        
        messageLabel.text = .ginibankLocalized(resource: DigitalInvoiceStrings.footerMessage)
        messageLabel.numberOfLines = 0
        messageLabel.font = configuration.digitalInvoiceFooterMessageTextFont
        messageLabel.textColor = UIColor.from(giniColor:configuration.digitalInvoiceFooterMessageTextColor)
        messageLabel.textAlignment = .center
        
        payButton.layer.cornerRadius = 7
        payButton.backgroundColor = configuration.payButtonBackgroundColor
        payButton.setTitleColor(configuration.payButtonTitleTextColor, for: .normal)
        payButton.titleLabel?.font = configuration.payButtonTitleFont

        payButton.layer.shadowColor = UIColor.black.cgColor
        payButton.layer.shadowRadius = 4
        payButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        payButton.layer.shadowOpacity = 0.15
    }
    
    func enableButtons(_ newValue: Bool) {
        payButton.isEnabled = newValue
        skipButton.isEnabled = newValue
        
        let configuration = returnAssistantConfiguration ?? ReturnAssistantConfiguration.shared
        let payButtonBackgroundColor = newValue ? configuration.payButtonBackgroundColor : UIColor.lightGray
        payButton.backgroundColor = payButtonBackgroundColor
        skipButton.alpha = newValue ? 1.0 : 0.3
    }
    
    func shouldSetUIForInaccurateResults(_ bool: Bool) {
        let configuration = returnAssistantConfiguration ?? ReturnAssistantConfiguration.shared
        guard setupConstraints == false else {
            return
        }
        setupConstraints = true
        if bool {
            skipButton.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(skipButton)
            let skipButtonHeight: CGFloat = 48
            let margin: CGFloat = 16

            NSLayoutConstraint.activate([
                skipButton.heightAnchor.constraint(equalToConstant: skipButtonHeight),
                skipButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
                skipButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),
                skipButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
            ])

            skipButton.layer.cornerRadius = 7
            skipButton.backgroundColor = configuration.skipButtonBackgroundColor
            skipButton.setTitleColor(configuration.skipButtonTitleTextColor, for: .normal)
            skipButton.titleLabel?.font = configuration.skipButtonTitleFont
            skipButton.layer.borderColor = configuration.skipButtonBorderColor.cgColor
            skipButton.layer.borderWidth = 1
            payButtonBottomConstraint.isActive = false
            payButton.bottomAnchor.constraint(equalTo: skipButton.topAnchor, constant: -8).isActive = true
        } else {
            skipButton.removeFromSuperview()
            payButtonBottomConstraint.isActive = true
        }
    }
}
