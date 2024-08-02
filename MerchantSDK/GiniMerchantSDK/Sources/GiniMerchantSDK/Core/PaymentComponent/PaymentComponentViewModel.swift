//
//  PaymentComponentViewModel.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniUtilites
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
    let giniMerchantConfiguration: GiniMerchantConfiguration

    let backgroundColor: UIColor = UIColor.from(giniColor: GiniColor(lightModeColor: .clear,
                                                                     darkModeColor: .clear))

    // More information part
    let moreInformationAccentColor: UIColor = GiniColor.standard2.uiColor()
    let moreInformationLabelTextColor: UIColor = GiniColor.standard4.uiColor()
    let moreInformationLabelText = NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.more.information.label",
                                                                    comment: "Text for more information label")
    let moreInformationActionablePartText = NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.more.information.underlined.part",
                                                                             comment: "Text for more information actionable part from the label")
    var moreInformationLabelFont: UIFont
    var moreInformationLabelLinkFont: UIFont

    // Select bank label
    let selectYourBankLabelText = NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.select.your.bank.label",
                                                                   comment: "Text for the select your bank label that's above the payment provider picker")
    let selectYourBankLabelFont: UIFont
    let selectYourBankAccentColor: UIColor = GiniColor.standard1.uiColor()

    // Bank image icon
    private var bankImageIconData: Data?
    var bankImageIcon: UIImage? {
        guard let bankImageIconData else { return nil }
        return UIImage(data: bankImageIconData)
    }

    // Primary button
    let notInstalledBankTextColor: UIColor = GiniColor.standard4.uiColor()
    private let placeholderBankNameText: String = NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.select.bank.label",
                                                                                   comment: "Placeholder text used when there isn't a payment provider app installed")
    var selectBankButtonText: String {
        showPaymentComponentInOneRow ? placeholderBankNameText : bankName ?? placeholderBankNameText
    }

    let chevronDownIcon: UIImage = GiniMerchantImage.chevronDown.preferredUIImage()
    let chevronDownIconColor: UIColor = GiniColor(lightModeColorName: .light7, darkModeColorName: .light1).uiColor()

    // Payment provider colors
    var paymentProviderColors: ProviderColors?

    // CTA button
    private let goToBankingAppLabelText: String = NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.to.banking.app.label",
                                                                                   comment: "Title label used for the cta button when review screen is not present")
    private let continueToOverviewLabelText: String = NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.continue.to.overview.label",
                                                                                       comment: "Title label used for the cta button when review screen is present")

    var ctaButtonText: String {
        isReviewScreenOn ? continueToOverviewLabelText : goToBankingAppLabelText
    }

    private var paymentProviderScheme: String?

    weak var delegate: PaymentComponentViewProtocol?
    
    var documentId: String?
    
    var minimumButtonsHeight: CGFloat
    
    var hasBankSelected: Bool

    private var bankName: String?
    private var isReviewScreenOn: Bool
    
    private var paymentComponentConfiguration: PaymentComponentConfiguration?
    var shouldShowBrandedView: Bool {
        paymentComponentConfiguration?.isPaymentComponentBranded ?? true
    }
    var showPaymentComponentInOneRow: Bool {
        paymentComponentConfiguration?.showPaymentComponentInOneRow ?? false
    }
    var hideInfoForReturningUser: Bool {
        paymentComponentConfiguration?.hideInfoForReturningUser ?? false
    }
    
    init(paymentProvider: PaymentProvider?,
         giniMerchantConfiguration: GiniMerchantConfiguration,
         paymentComponentConfiguration: PaymentComponentConfiguration? = nil) {
        self.giniMerchantConfiguration = giniMerchantConfiguration

        self.moreInformationLabelFont = giniMerchantConfiguration.font(for: .captions1)
        self.moreInformationLabelLinkFont = giniMerchantConfiguration.font(for: .linkBold)
        self.selectYourBankLabelFont = giniMerchantConfiguration.font(for: .subtitle2)

        self.hasBankSelected = paymentProvider != nil
        self.bankImageIconData = paymentProvider?.iconData
        self.paymentProviderColors = paymentProvider?.colors
        self.paymentProviderScheme = paymentProvider?.appSchemeIOS
        self.bankName = paymentProvider?.name
        self.isReviewScreenOn = giniMerchantConfiguration.showPaymentReviewScreen

        self.minimumButtonsHeight = giniMerchantConfiguration.paymentComponentButtonsHeight

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
