//
//  GiniHealth+PaymentComponentsStringsProvider.swift
//  GiniHealthSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import GiniPaymentComponents

extension GiniHealth: PaymentComponentsStringsProvider {
    public var paymentReviewContainerStrings: PaymentReviewContainerStrings {
        PaymentReviewContainerStrings(
            emptyCheckErrorMessage: NSLocalizedStringPreferredFormat("gini.health.errors.failed.default.textfield.validation.check",
                                                                     comment: "the field failed non empty check"),
            ibanCheckErrorMessage: NSLocalizedStringPreferredFormat("gini.health.errors.failed.iban.validation.check",
                                                                    comment: "iban failed validation check"),
            recipientFieldPlaceholder: NSLocalizedStringPreferredFormat("gini.health.reviewscreen.recipient.placeholder",
                                                                        comment: "placeholder text for recipient input field"),
            ibanFieldPlaceholder: NSLocalizedStringPreferredFormat("gini.health.reviewscreen.iban.placeholder",
                                                                   comment: "placeholder text for iban input field"),
            amountFieldPlaceholder: NSLocalizedStringPreferredFormat("gini.health.reviewscreen.amount.placeholder",
                                                                     comment: "placeholder text for amount input field"),
            usageFieldPlaceholder: NSLocalizedStringPreferredFormat("gini.health.reviewscreen.usage.placeholder",
                                                                    comment: "placeholder text for usage input field"),
            recipientErrorMessage: NSLocalizedStringPreferredFormat("gini.health.errors.failed.recipient.non.empty.check",
                                                                    comment: "recipient failed non empty check"),
            ibanErrorMessage: NSLocalizedStringPreferredFormat("gini.health.errors.failed.iban.non.empty.check",
                                                               comment: "iban failed non empty check"),
            amountErrorMessage: NSLocalizedStringPreferredFormat("gini.health.errors.failed.amount.non.empty.check",
                                                                 comment: "amount failed non empty check"),
            purposeErrorMessage: NSLocalizedStringPreferredFormat("gini.health.errors.failed.purpose.non.empty.check",
                                                                  comment: "purpose failed non empty check"),
            payInvoiceLabelText: NSLocalizedStringPreferredFormat("gini.health.reviewscreen.banking.app.button.label",
                                                                  comment: "Title label used for the pay invoice button default")
        )
    }

    public var paymentComponentsStrings: PaymentComponentsStrings {
        PaymentComponentsStrings(
            selectYourBankLabelText: NSLocalizedStringPreferredFormat("gini.health.paymentcomponent.select.your.bank.label",
                                                                      comment: "Text for the select your bank label that's above the payment provider picker"),
            placeholderBankNameText: NSLocalizedStringPreferredFormat("gini.health.paymentcomponent.select.bank.label",
                                                                      comment: "Placeholder text used when there isn't a payment provider app installed"),
            ctaLabelText: GiniHealthConfiguration.shared.showPaymentReviewScreen ?
                NSLocalizedStringPreferredFormat("gini.health.paymentcomponent.continue.to.overview.label",
                                             comment: "Title label used for the pay invoice button when overview is available") :
                NSLocalizedStringPreferredFormat("gini.health.paymentcomponent.to.banking.app.label",
                                                 comment: "Title label used for the pay invoice button when you jump to the banking app")
        )
    }

    public var installAppStrings: InstallAppStrings {
        InstallAppStrings(
            titlePattern: NSLocalizedStringPreferredFormat("gini.health.paymentcomponent.install.app.bottom.sheet.title",
                                                           comment: "Install App Bottom sheet title"),
            moreInformationTipPattern: NSLocalizedStringPreferredFormat("gini.health.paymentcomponent.install.app.bottom.sheet.tip.description",
                                                                        comment: "Text for tip information label"),
            moreInformationNotePattern: NSLocalizedStringPreferredFormat("gini.health.paymentcomponent.install.app.bottom.sheet.notes.description",
                                                                         comment: "Text for notes information label"),
            continueLabelText: NSLocalizedStringPreferredFormat("gini.health.paymentcomponent.install.app.bottom.sheet.continue.button.text",
                                                                comment: "Title label used for the Continue button")
        )
    }

    public var shareInvoiceStrings: ShareInvoiceStrings {
        ShareInvoiceStrings(
            tipActionablePartText: NSLocalizedStringPreferredFormat("gini.health.paymentcomponent.share.invoice.bottom.sheet.tip.underlined.part",
                                                                    comment: "Text for tip actionable part from the label"),
            continueLabelText: NSLocalizedStringPreferredFormat("gini.health.paymentcomponent.share.invoice.bottom.sheet.continue.button.text",
                                                                comment: "Title label used for the Continue button"),
            singleAppTitle: NSLocalizedStringPreferredFormat("gini.health.paymentcomponent.share.invoice.bottom.sheet.app",
                                                             comment: "Text for the sigle App"),
            singleAppMore: NSLocalizedStringPreferredFormat("gini.health.paymentcomponent.share.invoice.bottom.sheet.more",
                                                            comment: "Text for the single App more"),
            titleTextPattern: NSLocalizedStringPreferredFormat("gini.health.paymentcomponent.share.invoice.bottom.sheet.title",
                                                               comment: "Share Invoice Bottom sheet title"),
            descriptionTextPattern: NSLocalizedStringPreferredFormat("gini.health.paymentcomponent.share.invoice.bottom.sheet.description",
                                                                     comment: "Text description for share bottom sheet"),
            tipLabelPattern: NSLocalizedStringPreferredFormat("gini.health.paymentcomponent.share.invoice.bottom.sheet.tip.description",
                                                              comment: "Text for tip label")
        )
    }

    public var paymentInfoStrings: PaymentInfoStrings {
        PaymentInfoStrings(
            giniWebsiteText: NSLocalizedStringPreferredFormat("gini.health.paymentcomponent.payment.info.pay.bills.description.clickable.text",
                                                              comment: "Word range that's clickable in pay bills description"),
            giniURLText: NSLocalizedStringPreferredFormat("gini.health.paymentcomponent.payment.info.gini.link",
                                                          comment: "Gini website link url"),
            questionsTitleText: NSLocalizedStringPreferredFormat("gini.health.paymentcomponent.payment.info.questions.title.label",
                                                                 comment: "Payment Info questions title label text"),
            answerPrivacyPolicyText: NSLocalizedStringPreferredFormat("gini.health.paymentcomponent.payment.info.questions.answer.clickable.text",
                                                                      comment: "Payment info answers clickable privacy policy"),
            privacyPolicyURLText: NSLocalizedStringPreferredFormat("gini.health.paymentcomponent.payment.info.gini.privacypolicy.link",
                                                                   comment: "Gini privacy policy link url"),
            titleText: NSLocalizedStringPreferredFormat("gini.health.paymentcomponent.payment.info.title.label",
                                                        comment: "Payment Info title label text"),
            payBillsTitleText: NSLocalizedStringPreferredFormat("gini.health.paymentcomponent.payment.info.pay.bills.title.label",
                                                                comment: "Payment Info pay bills title label text"),
            payBillsDescriptionText: NSLocalizedStringPreferredFormat("gini.health.paymentcomponent.payment.info.pay.bills.description.label",
                                                                      comment: "Payment Info pay bills description text"),
            answers: [NSLocalizedStringPreferredFormat("gini.health.paymentcomponent.payment.info.questions.answer.1",
                                                       comment: "Answers description"),
                      NSLocalizedStringPreferredFormat("gini.health.paymentcomponent.payment.info.questions.answer.2",
                                                       comment: "Answers description"),
                      NSLocalizedStringPreferredFormat("gini.health.paymentcomponent.payment.info.questions.answer.3",
                                                       comment: "Answers description"),
                      NSLocalizedStringPreferredFormat("gini.health.paymentcomponent.payment.info.questions.answer.4",
                                                       comment: "Answers description"),
                      NSLocalizedStringPreferredFormat("gini.health.paymentcomponent.payment.info.questions.answer.5",
                                                       comment: "Answers description"),
                      NSLocalizedStringPreferredFormat("gini.health.paymentcomponent.payment.info.questions.answer.6",
                                                       comment: "Answers description")],
            questions: [NSLocalizedStringPreferredFormat("gini.health.paymentcomponent.payment.info.questions.question.1",
                                                         comment: "Questions titles"),
                        NSLocalizedStringPreferredFormat("gini.health.paymentcomponent.payment.info.questions.question.2",
                                                         comment: "Questions titles"),
                        NSLocalizedStringPreferredFormat("gini.health.paymentcomponent.payment.info.questions.question.3",
                                                         comment: "Questions titles"),
                        NSLocalizedStringPreferredFormat("gini.health.paymentcomponent.payment.info.questions.question.4",
                                                         comment: "Questions titles"),
                        NSLocalizedStringPreferredFormat("gini.health.paymentcomponent.payment.info.questions.question.5",
                                                         comment: "Questions titles"),
                        NSLocalizedStringPreferredFormat("gini.health.paymentcomponent.payment.info.questions.question.6",
                                                         comment: "Questions titles")]
        )
    }

    public var banksBottomStrings: BanksBottomStrings {
        BanksBottomStrings(
            selectBankTitleText: NSLocalizedStringPreferredFormat("gini.health.paymentcomponent.select.bank.label",
                                                                  comment: "Select bank text from the top label on payment providers bottom sheet"),
            descriptionText: NSLocalizedStringPreferredFormat("gini.health.paymentcomponent.payment.providers.list.description",
                                                              comment: "Top description text on payment providers bottom sheet")
        )
    }

    public var paymentReviewStrings: PaymentReviewStrings {
        PaymentReviewStrings(
            alertOkButtonTitle: NSLocalizedStringPreferredFormat("gini.health.alert.ok.title",
                                                                 comment: "ok title for action"),
            infoBarMessage: NSLocalizedStringPreferredFormat("gini.health.reviewscreen.infobar.message",
                                                             comment: "info bar message"),
            defaultErrorMessage: NSLocalizedStringPreferredFormat("gini.health.errors.default",
                                                                  comment: "default error message"),
            createPaymentErrorMessage: NSLocalizedStringPreferredFormat("gini.health.errors.failed.payment.request.creation",
                                                                        comment: "error for creating payment request")
        )
    }

    public var poweredByGiniStrings: PoweredByGiniStrings {
        PoweredByGiniStrings(
            poweredByGiniText: NSLocalizedStringPreferredFormat("gini.health.paymentcomponent.powered.by.gini.label", comment: "")
        )
    }

    public var moreInformationStrings: MoreInformationStrings {
        MoreInformationStrings(
            moreInformationActionablePartText: NSLocalizedStringPreferredFormat("gini.health.paymentcomponent.more.information.underlined.part",
                                                                                comment: "Text for more information actionable part from the label")
        )
    }
}
