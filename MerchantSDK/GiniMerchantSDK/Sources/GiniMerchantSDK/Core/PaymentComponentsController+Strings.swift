//
//  File.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation

extension PaymentComponentsController {
    func generatePaymentReviewStrings() -> PaymentReviewStrings {
        PaymentReviewStrings(
            alertOkButtonTitle: NSLocalizedStringPreferredFormat("gini.merchant.alert.ok.title", comment: "ok title for action"),
            infoBarMessage: NSLocalizedStringPreferredFormat("gini.merchant.reviewscreen.infobar.message", comment: "info bar message"),
            defaultErrorMessage: NSLocalizedStringPreferredFormat("gini.merchant.errors.default", comment: "default error message"),
            createPaymentErrorMessage: NSLocalizedStringPreferredFormat("gini.merchant.errors.failed.payment.request.creation", comment: "error for creating payment request")
        )
    }

    func generateInstallAppStrings() -> InstallAppStrings {
        InstallAppStrings(
            titlePattern: NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.installAppBottomSheet.title", comment: "Install App Bottom sheet title"),
            moreInformationTipPattern: NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.installAppBottomSheet.tip.description",
                                                                        comment: "Text for tip information label"),
            moreInformationNotePattern: NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.installAppBottomSheet.notes.description",
                                                                         comment: "Text for notes information label"),
            continueLabelText: NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.installAppBottomSheet.continue.button.text",
                                                                comment: "Title label used for the Continue button")
        )
    }

    func generateBanksBottomStrings() -> BanksBottomStrings {
        BanksBottomStrings(
            selectBankTitleText: NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.selectBank.label",
                                                                  comment: "Select bank text from the top label on payment providers bottom sheet"),
            descriptionText: NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.paymentproviderslist.description",
                                                              comment: "Top description text on payment providers bottom sheet")
        )
    }

    func generatePaymentComponentsStrings() -> PaymentComponentsStrings {
        PaymentComponentsStrings(
            selectYourBankLabelText: NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.selectYourBank.label",
                                                                      comment: "Text for the select your bank label that's above the payment provider picker"),
            placeholderBankNameText: NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.selectBank.label",
                                                                      comment: "Placeholder text used when there isn't a payment provider app installed"),
            payInvoiceLabelText: NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.payInvoice.label",
                                                                  comment: "Title label used for the pay invoice button")
        )
    }

    func generatePaymentInfoStrings() -> PaymentInfoStrings {
        PaymentInfoStrings(
            giniWebsiteText: NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.paymentinfo.payBills.description.clickable.text",
                                                              comment: "Word range that's clickable in pay bills description"),
            giniURLText: NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.paymentinfo.gini.link",
                                                          comment: "Gini website link url"),
            questionsTitleText: NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.paymentinfo.questions.title.label",
                                                                 comment: "Payment Info questions title label text"),
            answerPrivacyPolicyText: NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.paymentinfo.questions.answer.clickable.text",
                                                                      comment: "Payment info answers clickable privacy policy"),
            privacyPolicyURLText: NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.paymentinfo.gini.privacypolicy.link",
                                                                   comment: "Gini privacy policy link url"),
            titleText: NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.paymentinfo.title.label",
                                                        comment: "Payment Info title label text"),
            payBillsTitleText: NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.paymentinfo.payBills.title.label",
                                                                comment: "Payment Info pay bills title label text"),
            payBillsDescriptionText: NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.paymentinfo.payBills.description.label",
                                                                      comment: "Payment Info pay bills description text")
        )
    }

    func generateShareInvoiceStrings() -> ShareInvoiceStrings  {
        ShareInvoiceStrings(
            tipActionablePartText: NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.shareInvoiceBottomSheet.tip.underlined.part",
                                                                    comment: "Text for tip actionable part from the label"),
            continueLabelText: NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.shareInvoiceBottomSheet.continue.button.text",
                                                                comment: "Title label used for the Continue button"),
            singleAppTitle: NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.shareInvoiceBottomSheet.app", comment: ""),
            singleAppMore: NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.shareInvoiceBottomSheet.more", comment: ""),
            titleTextPattern: NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.shareInvoiceBottomSheet.title",
                                                               comment: "Share Invoice Bottom sheet title"),
            descriptionTextPattern: NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.shareInvoiceBottomSheet.description",
                                                                     comment: "Text description for share bottom sheet"),
            tipLabelPattern: NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.shareInvoiceBottomSheet.tip.description",
                                                              comment: "Text for tip label")
        )
    }

    func generatePoweredByGiniStrings() -> PoweredByGiniStrings {
        PoweredByGiniStrings(
            poweredByGiniText: NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.poweredByGini.label", comment: "")
        )
    }

    func generateMoreInformationStrings() -> MoreInformationStrings {
        MoreInformationStrings(
            moreInformationActionablePartText: NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.moreInformation.underlined.part",
                                                                                comment: "Text for more information actionable part from the label")
        )
    }
}
