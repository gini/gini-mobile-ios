//
//  PaymentComponentViewModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniHealthAPILibrary

/**
 Delegate to inform about the actions happened of the custom payment component view.
 You may find out when the user tapped on more information area, on the payment provider picker or on the pay invoice button

 */
public protocol PaymentComponentViewProtocol: AnyObject {
    /**
     Called when the user tapped on the more information actionable label or the information icon

     - parameter documentId: Id of document
     */
    func didTapOnMoreInformation(documentId: String?)

    /**
     Called when the user tapped on payment provider picker to change the selected payment provider or install it

     - parameter documentId: Id of document
     */
    func didTapOnBankPicker(documentId: String?)

    /**
     Called when the user tapped on the pay the invoice button to pay the invoice/document
     - parameter documentId: Id of document
     */
    func didTapOnPayInvoice(documentId: String?)
}

/**
 Helping extension for using the PaymentComponentViewProtocol methods without the document ID. This should be kept by the document view model and passed hierarchically from there.

 */
extension PaymentComponentViewProtocol {
    public func didTapOnMoreInformation() {
        didTapOnMoreInformation(documentId: nil)
    }
    public func didTapOnBankPicker() {
        didTapOnBankPicker(documentId: nil)
    }
    public func didTapOnPayInvoice() {
        didTapOnPayInvoice(documentId: nil)
    }
}

final class PaymentComponentViewModel {
    let giniHealthConfiguration: GiniHealthConfiguration

    let backgroundColor: UIColor = UIColor.from(giniColor: GiniColor(lightModeColor: .clear, 
                                                                     darkModeColor: .clear))

    // More information part
    let moreInformationAccentColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark2, 
                                                        darkModeColor: UIColor.GiniHealthColors.light2).uiColor()
    let moreInformationLabelTextColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark4,
                                                        darkModeColor: UIColor.GiniHealthColors.light4).uiColor()
    let moreInformationLabelText = GiniLocalized.string("ginihealth.paymentcomponent.moreInformation.label", 
                                                                    comment: "Text for more information label")
    let moreInformationActionablePartText = GiniLocalized.string("ginihealth.paymentcomponent.moreInformation.underlined.part",
                                                                             comment: "Text for more information actionable part from the label")
    var moreInformationLabelFont: UIFont
    var moreInformationLabelLinkFont: UIFont
    let moreInformationIconName = "info.circle"
    
    // Select bank label
    let selectYourBankLabelText = GiniLocalized.string("ginihealth.paymentcomponent.selectYourBank.label", 
                                                                   comment: "Text for the select your bank label that's above the payment provider picker")
    let selectYourBankLabelFont: UIFont
    let selectYourBankAccentColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark1,
                                                       darkModeColor: UIColor.GiniHealthColors.light1).uiColor()
    
    // Bank image icon
    private var bankImageIconData: Data?
    var bankImageIcon: UIImage? {
        guard let bankImageIconData else { return nil }
        return UIImage(data: bankImageIconData)
    }

    // Primary button
    let notInstalledBankTextColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark4,
                                                       darkModeColor: UIColor.GiniHealthColors.light4).uiColor()
    let placeholderBankNameText: String = GiniLocalized.string("ginihealth.paymentcomponent.selectBank.label",
                                                                                   comment: "Placeholder text used when there isn't a payment provider app installed")
    
    let chevronDownIconName: String = "iconChevronDown"
    let chevronDownIconColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.light7,
                                                  darkModeColor: UIColor.GiniHealthColors.light1).uiColor()
    
    // Payment provider colors
    var paymentProviderColors: ProviderColors?

    // Pay invoice label
    let payInvoiceLabelText: String = GiniLocalized.string("ginihealth.paymentcomponent.payInvoice.label", 
                                                                       comment: "Title label used for the pay invoice button")

    private var paymentProviderScheme: String?

    weak var delegate: PaymentComponentViewProtocol?
    
    var documentId: String?
    
    var minimumButtonsHeight: CGFloat
    
    var hasBankSelected: Bool

    var paymentComponentConfiguration: PaymentComponentConfiguration?

    var shouldShowBrandedView: Bool {
        paymentComponentConfiguration?.isPaymentComponentBranded ?? true
    }

    init(paymentProvider: PaymentProvider?, giniHealthConfiguration: GiniHealthConfiguration, paymentComponentConfiguration: PaymentComponentConfiguration?) {
        self.giniHealthConfiguration = giniHealthConfiguration
        let defaultRegularFont: UIFont = UIFont.systemFont(ofSize: 13, weight: .regular)
        let defaultBoldFont: UIFont = UIFont.systemFont(ofSize: 14, weight: .bold)
        let defaultMediumFont: UIFont = UIFont.systemFont(ofSize: 14, weight: .medium)
        self.moreInformationLabelFont = giniHealthConfiguration.textStyleFonts[.caption1] ?? defaultRegularFont
        self.moreInformationLabelLinkFont = giniHealthConfiguration.textStyleFonts[.linkBold] ?? defaultBoldFont
        self.selectYourBankLabelFont = giniHealthConfiguration.textStyleFonts[.subtitle2] ?? defaultMediumFont
        
        self.hasBankSelected = paymentProvider != nil
        self.bankImageIconData = paymentProvider?.iconData
        self.paymentProviderColors = paymentProvider?.colors
        self.paymentProviderScheme = paymentProvider?.appSchemeIOS
        
        self.minimumButtonsHeight = giniHealthConfiguration.paymentComponentButtonsHeight

        self.paymentComponentConfiguration = paymentComponentConfiguration
    }
    
    func tapOnMoreInformation() {
        delegate?.didTapOnMoreInformation(documentId: documentId)
    }
    
    func tapOnBankPicker() {
        delegate?.didTapOnBankPicker(documentId: documentId)
    }
    
    func tapOnPayInvoiceView() {
        savePaymentComponentViewUsageStatus()
        delegate?.didTapOnPayInvoice(documentId: documentId)
    }
    
    // Function to check if Payment was used at least once
    func isPaymentComponentUsed() -> Bool {
        return UserDefaults.standard.bool(forKey: Constants.paymentComponentViewUsedKey)
    }
    
    // Function to save the boolean value indicating whether Payment was used
    private func savePaymentComponentViewUsageStatus() {
        UserDefaults.standard.set(true, forKey: Constants.paymentComponentViewUsedKey)
    }
}

extension PaymentComponentViewModel {
    private enum Constants {
        static let paymentComponentViewUsedKey = "kPaymentComponentViewUsed"
    }
}
