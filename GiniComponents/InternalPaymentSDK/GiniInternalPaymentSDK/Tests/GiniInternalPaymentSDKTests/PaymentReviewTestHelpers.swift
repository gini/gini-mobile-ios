//
//  PaymentReviewTestHelpers.swift
//  GiniInternalPaymentSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import UIKit
import GiniHealthAPILibrary
import GiniUtilites
@testable import GiniInternalPaymentSDK

// MARK: - Test factories

extension PaymentProvider {
    static var test: PaymentProvider {
        PaymentProvider(id: "test-provider-id",
                        name: "Test Bank",
                        appSchemeIOS: "testbank://",
                        minAppVersion: nil,
                        colors: ProviderColors(background: "#FFFFFF", text: "#000000"),
                        iconData: Data(),
                        appStoreUrlIOS: nil,
                        universalLinkIOS: "https://testbank.example",
                        index: 0,
                        gpcSupportedPlatforms: [],
                        openWithSupportedPlatforms: [])
    }

    static func fixture(id: String = "provider-id",
                     name: String = "Test Bank",
                     appSchemeIOS: String = "testbank://",
                     index: Int? = nil,
                     gpcSupportedPlatforms: [PlatformSupported] = [.ios],
                     openWithSupportedPlatforms: [PlatformSupported] = []) -> PaymentProvider {
        PaymentProvider(id: id,
                        name: name,
                        appSchemeIOS: appSchemeIOS,
                        minAppVersion: nil,
                        colors: ProviderColors(background: "#FFFFFF", text: "#000000"),
                        iconData: Data(),
                        appStoreUrlIOS: nil,
                        universalLinkIOS: "https://testbank.example",
                        index: index,
                        gpcSupportedPlatforms: gpcSupportedPlatforms,
                        openWithSupportedPlatforms: openWithSupportedPlatforms)
    }
}

extension TextFieldConfiguration {
    static var test: TextFieldConfiguration {
        TextFieldConfiguration(backgroundColor: .white,
                               borderColor: .systemGray4,
                               textColor: .label,
                               textFont: .systemFont(ofSize: 14),
                               cornerRadius: 8,
                               borderWidth: 1,
                               placeholderForegroundColor: .placeholderText)
    }
}

extension ButtonConfiguration {
    static var test: ButtonConfiguration {
        ButtonConfiguration(backgroundColor: .systemBlue,
                            borderColor: .clear,
                            titleColor: .white,
                            titleFont: .systemFont(ofSize: 16, weight: .semibold),
                            shadowColor: .clear,
                            cornerRadius: 8,
                            borderWidth: 0,
                            shadowRadius: 0,
                            withBlurEffect: false)
    }
}

extension PoweredByGiniConfiguration {
    static var test: PoweredByGiniConfiguration {
        PoweredByGiniConfiguration(poweredByGiniLabelFont: .systemFont(ofSize: 12),
                                   poweredByGiniLabelAccentColor: .label,
                                   giniIcon: UIImage())
    }
}

extension PoweredByGiniStrings {
    static var test: PoweredByGiniStrings {
        PoweredByGiniStrings(poweredByGiniText: "Powered by Gini")
    }
}

extension BottomSheetConfiguration {
    static var test: BottomSheetConfiguration {
        BottomSheetConfiguration(backgroundColor: .white,
                                 rectangleColor: .systemGray4,
                                 dimmingBackgroundColor: UIColor.black.withAlphaComponent(0.5))
    }
}

extension PaymentReviewContainerStrings {
    static func test(keyboardDoneButtonTitle: String = "Done") -> PaymentReviewContainerStrings {
        let placeholders = PaymentReviewFieldPlaceholders(recipient: "Recipient",
                                                          iban: "IBAN",
                                                          amount: "Amount",
                                                          usage: "Usage")
        let errors = PaymentReviewFieldErrors(ibanCheck: "Invalid IBAN",
                                              recipient: "Invalid recipient",
                                              iban: "IBAN required",
                                              amount: "Amount required",
                                              purpose: "Purpose required")
        let accessibility = PaymentReviewBankSelectionAccessibility(payInvoiceHint: "Pay invoice",
                                                                     selectBankText: "Select bank",
                                                                     selectBankHint: "Hint")
        return PaymentReviewContainerStrings(fieldPlaceholders: placeholders,
                                             fieldErrors: errors,
                                             bankSelectionAccessibility: accessibility,
                                             payInvoiceLabelText: "Pay invoice",
                                             infoBarMessage: "Info",
                                             keyboardDoneButtonTitle: keyboardDoneButtonTitle)
    }
}

extension PaymentReviewContainerConfiguration {
    static var test: PaymentReviewContainerConfiguration {
        let errorLabel = PaymentReviewErrorLabelConfiguration(textColor: .systemRed,
                                                              font: .systemFont(ofSize: 12))
        let banksPicker = PaymentReviewBanksPickerConfiguration(lockIcon: UIImage(),
                                                                lockedFields: false,
                                                                showBanksPicker: true,
                                                                chevronDownIcon: nil,
                                                                chevronDownIconColor: nil)
        let infoBar = PaymentReviewInfoBarConfiguration(labelTextColor: .label,
                                                        labelFont: .systemFont(ofSize: 12),
                                                        backgroundColor: .systemBlue,
                                                        containerBackgroundColor: .systemBackground)
        return PaymentReviewContainerConfiguration(errorLabel: errorLabel,
                                                   banksPicker: banksPicker,
                                                   infoBar: infoBar,
                                                   popupAnimationDuration: 3.0,
                                                   keyboardDoneButtonTintColor: .systemBlue)
    }
}

extension PaymentReviewContainerViewModel {
    static func test(paymentInfo: PaymentInfo? = nil,
                     extractions: [Extraction]? = nil,
                     keyboardDoneButtonTitle: String = "Done") -> PaymentReviewContainerViewModel {
        let paymentData = PaymentReviewContainerPaymentData(extractions: extractions,
                                                            document: nil,
                                                            paymentInfo: paymentInfo,
                                                            selectedPaymentProvider: .test,
                                                            displayMode: .bottomSheet)
        let buttons = PaymentReviewContainerButtonsConfiguration(primaryButton: .test,
                                                                  secondaryButton: .test)
        let inputFields = PaymentReviewContainerInputFieldsConfiguration(defaultStyle: .test,
                                                                          errorStyle: .test,
                                                                          selectionStyle: .test)
        let poweredByGini = PoweredByGiniViewModel(configuration: .test, strings: .test)
        return PaymentReviewContainerViewModel(paymentData: paymentData,
                                               configuration: .test,
                                               strings: .test(keyboardDoneButtonTitle: keyboardDoneButtonTitle),
                                               buttonsConfiguration: buttons,
                                               inputFieldsConfiguration: inputFields,
                                               poweredByGiniViewModel: poweredByGini,
                                               clientConfiguration: nil)
    }
}

extension PaymentReviewStrings {
    static var test: PaymentReviewStrings {
        PaymentReviewStrings(alertOkButtonTitle: "OK",
                             infoBarMessage: "Info",
                             defaultErrorMessage: "Error",
                             createPaymentErrorMessage: "Payment error",
                             invoiceImageAccessibilityLabel: "Invoice",
                             closeButtonAccessibilityLabel: "Close",
                             closeButtonAccessibilityHint: "Close",
                             sheetGrabberAccessibilityLabel: "Sheet",
                             sheetGrabberAccessibilityHint: "Drag")
    }
}

extension PaymentReviewConfiguration {
    static var test: PaymentReviewConfiguration {
        PaymentReviewConfiguration(loadingIndicatorStyle: .medium,
                                   loadingIndicatorColor: .systemBlue,
                                   infoBarLabelTextColor: .label,
                                   infoBarBackgroundColor: .systemBlue,
                                   mainViewBackgroundColor: .systemBackground,
                                   infoContainerViewBackgroundColor: .systemBackground,
                                   paymentReviewClose: UIImage(),
                                   backgroundColor: .systemBackground,
                                   rectangleColor: .systemGray4,
                                   infoBarLabelFont: .systemFont(ofSize: 12),
                                   statusBarStyle: .default,
                                   pageIndicatorTintColor: .systemGray,
                                   currentPageIndicatorTintColor: .systemBlue,
                                   isInfoBarHidden: true,
                                   popupAnimationDuration: 3.0)
    }
}

extension Document {
    static func testDocument(id: String = "test-doc-id",
                             pageCount: Int = 1) -> Document {
        let links = Document.Links(giniAPIDocumentURL: URL(string: "https://api.example.com/documents/\(id)")!)
        return Document(creationDate: Date(),
                        id: id,
                        name: "test.pdf",
                        links: links,
                        pageCount: pageCount,
                        sourceClassification: .native,
                        expirationDate: nil)
    }
}

func makePaymentReviewModel(delegate: MockPaymentReviewDelegate,
                            bottomSheetsProvider: MockBottomSheetsProvider,
                            displayMode: DisplayMode = .bottomSheet) -> PaymentReviewModel {
    PaymentReviewModel(delegate: delegate,
                       bottomSheetsProvider: bottomSheetsProvider,
                       document: nil,
                       extractions: nil,
                       paymentInfo: nil,
                       selectedPaymentProvider: .test,
                       configuration: .test,
                       strings: .test,
                       containerConfiguration: .test,
                       containerStrings: .test(),
                       defaultStyleInputFieldConfiguration: .test,
                       errorStyleInputFieldConfiguration: .test,
                       selectionStyleInputFieldConfiguration: .test,
                       primaryButtonConfiguration: .test,
                       secondaryButtonConfiguration: .test,
                       poweredByGiniConfiguration: .test,
                       poweredByGiniStrings: .test,
                       bottomSheetConfiguration: .test,
                       showPaymentReviewCloseButton: true,
                       previousPaymentComponentScreenType: nil,
                       clientConfiguration: nil)
}

func makePaymentReviewModelWithDocument(delegate: MockPaymentReviewDelegate,
                                        bottomSheetsProvider: MockBottomSheetsProvider,
                                        document: Document = .testDocument(),
                                        previousPaymentComponentScreenType: PaymentComponentScreenType? = nil) -> PaymentReviewModel {
    PaymentReviewModel(delegate: delegate,
                       bottomSheetsProvider: bottomSheetsProvider,
                       document: document,
                       extractions: nil,
                       paymentInfo: nil,
                       selectedPaymentProvider: .test,
                       configuration: .test,
                       strings: .test,
                       containerConfiguration: .test,
                       containerStrings: .test(),
                       defaultStyleInputFieldConfiguration: .test,
                       errorStyleInputFieldConfiguration: .test,
                       selectionStyleInputFieldConfiguration: .test,
                       primaryButtonConfiguration: .test,
                       secondaryButtonConfiguration: .test,
                       poweredByGiniConfiguration: .test,
                       poweredByGiniStrings: .test,
                       bottomSheetConfiguration: .test,
                       showPaymentReviewCloseButton: true,
                       previousPaymentComponentScreenType: previousPaymentComponentScreenType,
                       clientConfiguration: nil)
}

// MARK: - Configuration and string test factories

extension BankSelectionConfiguration {
    static var test: BankSelectionConfiguration {
        BankSelectionConfiguration(descriptionAccentColor: .label,
                                   descriptionFont: .systemFont(ofSize: 14),
                                   selectBankAccentColor: .label,
                                   selectBankFont: .systemFont(ofSize: 16, weight: .semibold),
                                   bankCellBackgroundColor: .systemBackground,
                                   bankCellIconBorderColor: .systemGray4,
                                   bankCellNameFont: .systemFont(ofSize: 14),
                                   bankCellNameAccentColor: .label,
                                   bankCellSelectedBorderColor: .systemBlue,
                                   bankCellNotSelectedBorderColor: .systemGray4,
                                   bankCellSelectionIndicatorImage: UIImage())
    }
}

extension BanksBottomStrings {
    static var test: BanksBottomStrings {
        BanksBottomStrings(selectBankTitleText: "Select your bank",
                           descriptionText: "Description")
    }
}

extension MoreInformationConfiguration {
    static var test: MoreInformationConfiguration {
        MoreInformationConfiguration(moreInformationAccentColor: .systemBlue,
                                     moreInformationTextColor: .label,
                                     moreInformationLinkFont: .systemFont(ofSize: 12),
                                     moreInformationIcon: UIImage())
    }
}

extension MoreInformationStrings {
    static var test: MoreInformationStrings {
        MoreInformationStrings(moreInformationActionablePartText: "More information")
    }
}

extension PaymentInfoConfiguration {
    static var test: PaymentInfoConfiguration {
        PaymentInfoConfiguration(
            answerCell: .init(font: .systemFont(ofSize: 12),
                              textColor: .label,
                              linkColor: .systemBlue),
            questionHeader: .init(font: .systemFont(ofSize: 14, weight: .medium),
                                  titleColor: .label,
                                  minusIcon: UIImage(),
                                  plusIcon: UIImage(),
                                  iconTintColor: .label),
            questionsTitle: .init(font: .systemFont(ofSize: 16, weight: .semibold),
                                  color: .label),
            payBills: .init(titleFont: .systemFont(ofSize: 18, weight: .bold),
                            titleColor: .label,
                            descriptionFont: .systemFont(ofSize: 14)),
            links: .init(giniFont: .systemFont(ofSize: 14),
                         font: .systemFont(ofSize: 12),
                         color: .systemBlue),
            layout: .init(bankCellBorderColor: .systemGray4,
                          separatorColor: .systemGray5,
                          backgroundColor: .systemBackground)
        )
    }
}

extension PaymentInfoStrings {
    static var test: PaymentInfoStrings {
        PaymentInfoStrings(giniLink: .init(websiteText: "Gini website",
                                           urlText: "https://gini.net"),
                           supportedBanksText: "Supported banks",
                           titleText: "Payment information",
                           payBillsTitleText: "Pay bills",
                           payBillsDescriptionText: "Description",
                           privacyPolicy: .init(text: "Privacy policy",
                                                urlText: "https://gini.net/privacy"),
                           faq: .init(titleText: "Questions",
                                      questions: [],
                                      answers: [],
                                      accessibilityExpandedText: "Expanded",
                                      accessibilityCollapsedText: "Collapsed"))
    }
}

extension PaymentComponentsConfiguration {
    static var test: PaymentComponentsConfiguration {
        PaymentComponentsConfiguration(selectYourBankLabelFont: .systemFont(ofSize: 14),
                                       selectYourBankAccentColor: .label,
                                       chevronDownIcon: UIImage(),
                                       chevronDownIconColor: .label,
                                       notInstalledBankTextColor: .secondaryLabel)
    }
}

extension PaymentComponentsStrings {
    static var test: PaymentComponentsStrings {
        PaymentComponentsStrings(selectYourBankLabelText: "Select your bank",
                                 placeholderBankNameText: "Select bank",
                                 ctaLabelText: "Continue",
                                 selectYourBankAccessibilityHint: "Tap to select")
    }
}

extension ShareInvoiceConfiguration {
    static var test: ShareInvoiceConfiguration {
        ShareInvoiceConfiguration(titleFont: .systemFont(ofSize: 18, weight: .bold),
                                  titleAccentColor: .label,
                                  descriptionFont: .systemFont(ofSize: 14),
                                  descriptionTextColor: .label,
                                  descriptionAccentColor: .systemBlue,
                                  paymentInfoBorderColor: .systemGray4,
                                  titlePaymentInfoTextColor: .label,
                                  subtitlePaymentInfoTextColor: .secondaryLabel,
                                  titlepaymentInfoFont: .systemFont(ofSize: 14, weight: .semibold),
                                  subtitlePaymentInfoFont: .systemFont(ofSize: 12))
    }
}

extension ShareInvoiceStrings {
    static var test: ShareInvoiceStrings {
        ShareInvoiceStrings(continueLabelText: "Continue with [BANK]",
                            titleTextPattern: "Share with [BANK]",
                            descriptionTextPattern: "Open [BANK] to pay",
                            recipientLabelText: "Recipient",
                            amountLabelText: "Amount",
                            ibanLabelText: "IBAN",
                            purposeLabelText: "Purpose",
                            accessibilityQRCodeImageText: "QR code")
    }
}

extension InstallAppConfiguration {
    static var test: InstallAppConfiguration {
        InstallAppConfiguration(titleAccentColor: .label,
                                titleFont: .systemFont(ofSize: 18, weight: .bold),
                                moreInformationFont: .systemFont(ofSize: 14),
                                moreInformationTextColor: .label,
                                moreInformationAccentColor: .systemBlue,
                                moreInformationIcon: UIImage(),
                                appStoreIcon: UIImage(),
                                bankIconBorderColor: .systemGray4)
    }
}

extension InstallAppStrings {
    static var test: InstallAppStrings {
        InstallAppStrings(titlePattern: "Install [BANK]",
                          moreInformationTipPattern: "Tip: open [BANK]",
                          moreInformationNotePattern: "Note: install [BANK]",
                          continueLabelText: "Continue",
                          accessibilityAppStoreText: "App Store",
                          accessibilityBankLogoText: "Bank logo")
    }
}

extension ClientConfiguration {
    static func test(ingredientBrandType: GiniHealthAPILibrary.IngredientBrandTypeEnum = .invisible) -> ClientConfiguration {
        ClientConfiguration(ingredientBrandType: ingredientBrandType)
    }
}
