//
//  InfoView.swift
// GiniBank
//
//  Created by David Kyslenko on 09.04.2021.
//

import UIKit

protocol InfoViewDelegate: AnyObject {
    func didExpandButton(expanded: Bool)
    func didTapSkipButton()
}

class InfoView: UIView {
    private var contentView = UIView()
    
    private var infoLabel = UILabel()
    private var warningLabel = UILabel()
    private var skipLabel = UILabel()
    
    private var contentViewHeightConstraint = NSLayoutConstraint()
    private var contentViewWidthConstraint = NSLayoutConstraint()
    private var infoLabelTrailingConstraint = NSLayoutConstraint()
    private var infoLabelCenterXConstraint = NSLayoutConstraint()
    
    private var expandButton = UIButton()
    private var okButton = UIButton()
    private var skipButton = UIButton()
    
    private var illustrationImageView = UIImageView(image: prefferedImage(named: "ra-warning-illustration"))
    private lazy var actionButtonsStackView = UIStackView(arrangedSubviews: [okButton, skipButton])
    private var chevronImageView = UIImageView(image:prefferedImage(named: "chevron-up-icon"))
    
    weak var delegate: InfoViewDelegate?
    private var isExpanded = false

    var returnAssistantConfiguration: ReturnAssistantConfiguration? {
        didSet {
            setup()
        }
    }

    private func setup() {
        let configuration = returnAssistantConfiguration ?? ReturnAssistantConfiguration.shared

        addSubview(contentView)
        contentView.backgroundColor = configuration.digitalInvoiceInfoViewBackgroundColor
        contentView.layer.cornerRadius = 10
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.topAnchor.constraint(equalTo: self.topAnchor, constant: 15).isActive = true
        contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
        
        contentViewHeightConstraint = contentView.heightAnchor.constraint(equalToConstant: 54)
        contentViewHeightConstraint.isActive = true
        
        contentViewWidthConstraint = contentView.widthAnchor.constraint(equalToConstant: 115)
        contentViewWidthConstraint.isActive = true
        
        contentView.addSubview(chevronImageView)
        chevronImageView.tintColor = configuration.digitalInvoiceInfoViewChevronImageViewTintColor
        chevronImageView.transform = chevronImageView.transform.rotated(by: .pi)
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        
        chevronImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 11).isActive = true
        chevronImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15).isActive = true
        chevronImageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        chevronImageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        
        contentView.addSubview(infoLabel)
        infoLabel.text = .ginibankLocalized(resource: DigitalInvoiceStrings.warningViewTopTitle)
        infoLabel.textAlignment = .center
        infoLabel.font = configuration.digitalInvoiceInfoViewTopLabelFont
        infoLabel.textColor = configuration.digitalInvoiceInfoViewWarningLabelsTextColor
        
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15).isActive = true
        infoLabelTrailingConstraint = infoLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -11)
        infoLabelTrailingConstraint.isActive = true
        infoLabelCenterXConstraint = infoLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0)
        infoLabelCenterXConstraint.isActive = false

        contentView.addSubview(expandButton)
        expandButton.addTarget(self, action: #selector(didTapExpandButton), for: .touchUpInside)
        
        expandButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            expandButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            expandButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            expandButton.heightAnchor.constraint(equalToConstant: 54),
            expandButton.widthAnchor.constraint(equalToConstant: 115)
        ])
        
        contentView.addSubview(warningLabel)
        warningLabel.alpha = 0
        warningLabel.font = configuration.digitalInvoiceInfoViewMiddleLabelFont
        warningLabel.textColor = configuration.digitalInvoiceInfoViewWarningLabelsTextColor
        warningLabel.textAlignment = .center
        warningLabel.numberOfLines = 0
        warningLabel.text = .ginibankLocalized(resource: DigitalInvoiceStrings.warningViewMiddleTitle)
        
        warningLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            warningLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 40),
            warningLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -40),
            warningLabel.topAnchor.constraint(equalTo: chevronImageView.bottomAnchor, constant: 7),
        ])
        
        contentView.addSubview(illustrationImageView)
        illustrationImageView.alpha = 0
        
        illustrationImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            illustrationImageView.topAnchor.constraint(equalTo: warningLabel.bottomAnchor, constant: -3),
            illustrationImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
            illustrationImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.46),
            illustrationImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.69)
        ])
        
        contentView.addSubview(skipLabel)
        skipLabel.alpha = 0
        skipLabel.font = configuration.digitalInvoiceInfoViewBottomLabelFont
        skipLabel.textColor = configuration.digitalInvoiceInfoViewWarningLabelsTextColor
        skipLabel.textAlignment = .center
        skipLabel.numberOfLines = 0
        skipLabel.text = .ginibankLocalized(resource: DigitalInvoiceStrings.warningViewBottomTitle)
        
        skipLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            skipLabel.topAnchor.constraint(equalTo: illustrationImageView.bottomAnchor, constant: -15),
            skipLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 40),
            skipLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -40),
        ])
        
        contentView.addSubview(actionButtonsStackView)
        actionButtonsStackView.alpha = 0
        actionButtonsStackView.axis = .horizontal
        actionButtonsStackView.spacing = 15
        actionButtonsStackView.distribution = .fillEqually
        
        actionButtonsStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            actionButtonsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            actionButtonsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            actionButtonsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            actionButtonsStackView.heightAnchor.constraint(equalToConstant: 50)
        ])

        okButton.setTitle(.ginibankLocalized(resource: DigitalInvoiceStrings.warningViewLeftButtonTitle), for: .normal)
        okButton.backgroundColor = configuration.digitalInvoiceInfoViewLeftButtonBackgroundColor
        okButton.layer.cornerRadius = 13
        okButton.layer.borderWidth = 2
        okButton.layer.borderColor = configuration.digitalInvoiceInfoViewLeftButtonBorderColor.cgColor
        okButton.setTitleColor(configuration.digitalInvoiceInfoViewLeftkButtonTitleColor, for: .normal)
        okButton.titleLabel?.font = configuration.digitalInvoiceInfoViewButtonsFont
        okButton.addTarget(self, action: #selector(didTapOkButton), for: .touchUpInside)
        
        skipButton.setTitle(.ginibankLocalized(resource: DigitalInvoiceStrings.warningViewRightButtonTitle), for: .normal)
        skipButton.backgroundColor = configuration.digitalInvoiceInfoViewRightButtonBackgroundColor
        skipButton.layer.cornerRadius = 13
        skipButton.layer.borderWidth = 2
        skipButton.layer.borderColor = configuration.digitalInvoiceInfoViewRightButtonBorderColor.cgColor
        skipButton.setTitleColor(configuration.digitalInvoiceInfoViewRightButtonTitleColor, for: .normal)
        skipButton.titleLabel?.font = configuration.digitalInvoiceInfoViewButtonsFont
        skipButton.addTarget(self, action: #selector(didTapSkipButton), for: .touchUpInside)
        
    }
    
    func enableSkipButton(_ value: Bool) {
        skipButton.isEnabled = value
        skipButton.alpha = value ? 1.0 : 0.3
    }
    
    @objc func animate() {
        contentViewHeightConstraint.constant =  isExpanded ? 54 : 400
        contentViewWidthConstraint.constant = isExpanded ? 115 : UIScreen.main.bounds.width - 18
        infoLabelCenterXConstraint.isActive = !isExpanded
        infoLabelTrailingConstraint.isActive = isExpanded
        let alphaAnimationDuration = isExpanded ? 0.2 : 0.6
        
        UIView.animate(withDuration: 0.4) {
            self.chevronImageView.transform = self.chevronImageView.transform.rotated(by: .pi)
            self.layoutIfNeeded()
            self.contentView.layoutIfNeeded()
        }
        
        UIView.animate(withDuration: alphaAnimationDuration) {
            self.actionButtonsStackView.alpha = self.isExpanded ? 0 : 1
            self.warningLabel.alpha = self.isExpanded ? 0 : 1
            self.illustrationImageView.alpha = self.isExpanded ? 0 : 1
            self.skipLabel.alpha = self.isExpanded ? 0 : 1
        }
        
        isExpanded = !isExpanded
    }
    
    @objc private func didTapOkButton() {
        didTapExpandButton()
    }
    
    @objc private func didTapSkipButton() {
        delegate?.didTapSkipButton()
    }
    
    @objc func didTapExpandButton() {
        delegate?.didExpandButton(expanded: isExpanded)
    }

}


